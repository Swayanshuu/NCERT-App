import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ncert_story.dart';

class NcertNewsService extends ChangeNotifier {
  static final NcertNewsService _instance = NcertNewsService._internal();
  static NcertNewsService get instance => _instance;

  NcertNewsService._internal();

  static const String _primaryRssUrl =
      'https://timesofindia.indiatimes.com/rssfeeds/913168846.cms';
  static const String _secondaryRssUrl =
      'https://www.hindustantimes.com/feeds/rss/education/rssfeed.xml';
  static const String _cacheKey = 'ncert_stories_cache_v4';
  static const String _readIdsKey = 'ncert_read_story_ids_v1';

  List<NcertStory> _stories = [];
  bool _isLoading = false;
  Set<String> _readIds = {};
  bool _hasInitialized = false;

  List<NcertStory> get stories => List.unmodifiable(_stories);
  bool get isLoading => _isLoading;
  int get unreadCount => _stories.where((s) => !s.isRead).length;

  static const List<List<int>> _storyGradients = [
    [0xFF1E293B, 0xFF1E293B],
    [0xFF24272D, 0xFF24272D],
    [0xFF20232A, 0xFF20232A],
    [0xFF162521, 0xFF162521],
    [0xFF172033, 0xFF172033],
    [0xFF262626, 0xFF262626],
  ];

  Future<void> init() async {
    if (_hasInitialized) return;
    _hasInitialized = true;

    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Load Read IDs
      final savedReadIds = prefs.getStringList(_readIdsKey) ?? [];
      _readIds = savedReadIds.toSet();

      // 2. Load Cached Stories
      final cachedJson = prefs.getString(_cacheKey);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(cachedJson);
        final loaded = decoded
            .map((item) => NcertStory.fromJson(item as Map<String, dynamic>))
            .where((s) => !s.snippet.contains('<') && !s.snippet.contains('href='))
            .map((s) => s.copyWith(isRead: _readIds.contains(s.id)))
            .toList();
        if (loaded.isNotEmpty) {
          _stories = loaded;
          notifyListeners();
        }
      }

      // 3. Immediately auto-load real fresh news from the internet on startup
      fetchLiveNews();
    } catch (e) {
      debugPrint('Error initializing NcertNewsService: $e');
      if (_stories.isEmpty) {
        _stories = _getDefaultStories();
        notifyListeners();
      }
    }
  }

  Future<void> fetchLiveNews({bool force = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Try primary feed (Times of India Education)
      List<NcertStory> parsed = await _fetchFeed(_primaryRssUrl, 'Times of India');

      // If primary returned empty, fallback to secondary feed (Hindustan Times)
      if (parsed.isEmpty) {
        parsed = await _fetchFeed(_secondaryRssUrl, 'Hindustan Times');
      }

      if (parsed.isNotEmpty) {
        _stories = parsed
            .map((s) => s.copyWith(isRead: _readIds.contains(s.id)))
            .toList();

        // Save fresh live stories to cache
        final prefs = await SharedPreferences.getInstance();
        final encoded = jsonEncode(_stories.map((s) => s.toJson()).toList());
        await prefs.setString(_cacheKey, encoded);
      } else if (_stories.isEmpty) {
        _stories = _getDefaultStories()
            .map((s) => s.copyWith(isRead: _readIds.contains(s.id)))
            .toList();
      }
    } catch (e) {
      debugPrint('NcertNewsService: Live fetch error ($e). Using cached/default.');
      if (_stories.isEmpty) {
        _stories = _getDefaultStories()
            .map((s) => s.copyWith(isRead: _readIds.contains(s.id)))
            .toList();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<NcertStory>> _fetchFeed(String url, String sourceName) async {
    try {
      final response = await http
          .get(Uri.parse(url), headers: {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          })
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return _parseRss(response.body, sourceName);
      }
    } catch (e) {
      debugPrint('Failed to fetch feed from $url: $e');
    }
    return [];
  }

  Future<void> markAsRead(String storyId) async {
    if (_readIds.contains(storyId)) return;
    _readIds.add(storyId);

    _stories = _stories.map((s) {
      if (s.id == storyId) {
        return s.copyWith(isRead: true);
      }
      return s;
    }).toList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_readIdsKey, _readIds.toList());
    } catch (e) {
      debugPrint('Error saving read story ID: $e');
    }
  }

  List<NcertStory> _parseRss(String xml, String defaultSource) {
    final List<NcertStory> list = [];
    final items = xml.split('<item>');

    int gradientIdx = 0;

    for (int i = 1; i < items.length; i++) {
      if (list.length >= 12) break; // Keep top 12 fresh news stories
      final itemContent = items[i];

      final rawTitle = _extractField(itemContent, 'title');
      final link = _extractField(itemContent, 'link');
      final pubDate = _extractField(itemContent, 'pubDate');
      final rawDesc = _extractDescription(itemContent);
      final rawImg = _extractImage(itemContent);

      if (rawTitle.isEmpty) continue;

      final title = _stripHtml(rawTitle);
      final snippet = _stripHtml(rawDesc);

      // We ensure the snippet is real content
      if (snippet.isEmpty || snippet.length < 25) continue;

      final category = _determineCategory(title);
      final id = 'story_${title.hashCode.abs()}';
      final relativeTime = _formatPubDate(pubDate);
      final timestamp = _parseTimestamp(pubDate);

      list.add(
        NcertStory(
          id: id,
          title: title,
          snippet: snippet,
          source: defaultSource,
          link: link,
          publishedAt: relativeTime,
          timestamp: timestamp,
          category: category,
          gradientColors: _storyGradients[gradientIdx % _storyGradients.length],
          imageUrl: rawImg.isNotEmpty ? rawImg : _determineFallbackImage(category, title),
        ),
      );

      gradientIdx++;
    }

    // Sort strictly date-wise in descending order: latest news at position 1 (index 0)
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return list;
  }

  String _extractField(String itemContent, String tag) {
    // Check CDATA first: <tag><![CDATA[...]]></tag>
    final cdataPattern = RegExp('<$tag[^>]*>[\\s\\S]*?<!\\[CDATA\\[([\\s\\S]*?)\\]\\]>[\\s\\S]*?<\\/$tag>', caseSensitive: false);
    final cdataMatch = cdataPattern.firstMatch(itemContent);
    if (cdataMatch != null) {
      return cdataMatch.group(1)?.trim() ?? '';
    }

    // Standard tag: <tag>...</tag>
    final standardPattern = RegExp('<$tag[^>]*>([\\s\\S]*?)<\\/$tag>', caseSensitive: false);
    final match = standardPattern.firstMatch(itemContent);
    if (match != null) {
      return match.group(1)?.trim() ?? '';
    }
    return '';
  }

  String _extractDescription(String itemContent) {
    // 1. Look for CDATA inside description: <description>...<![CDATA[REAL CONTENT]]>...</description>
    final cdataPattern = RegExp(r'<description[^>]*>[\s\S]*?<!\[CDATA\[([\s\S]*?)\]\]>', caseSensitive: false);
    final cdataMatch = cdataPattern.firstMatch(itemContent);
    if (cdataMatch != null) {
      final content = cdataMatch.group(1)?.trim() ?? '';
      if (content.isNotEmpty) return content;
    }

    // 2. Look for regular description
    final descPattern = RegExp(r'<description[^>]*>([\s\S]*?)<\/description>', caseSensitive: false);
    final descMatch = descPattern.firstMatch(itemContent);
    if (descMatch != null) {
      return descMatch.group(1)?.trim() ?? '';
    }

    return '';
  }

  String _extractImage(String itemContent) {
    // 1. <enclosure ... url="..." />
    final enclosurePattern = RegExp(r'<enclosure[^>]+url="([^"]+)"', caseSensitive: false);
    final encMatch = enclosurePattern.firstMatch(itemContent);
    if (encMatch != null) {
      return encMatch.group(1)?.trim() ?? '';
    }

    // 2. <media:content ... url="..." />
    final mediaPattern = RegExp(r'<media:content[^>]+url="([^"]+)"', caseSensitive: false);
    final mediaMatch = mediaPattern.firstMatch(itemContent);
    if (mediaMatch != null) {
      return mediaMatch.group(1)?.trim() ?? '';
    }

    // 3. <img ... src="..." />
    final imgPattern = RegExp(r'<img[^>]+src="([^"]+)"', caseSensitive: false);
    final imgMatch = imgPattern.firstMatch(itemContent);
    if (imgMatch != null) {
      return imgMatch.group(1)?.trim() ?? '';
    }

    return '';
  }

  String _stripHtml(String raw) {
    if (raw.isEmpty) return '';
    // 1. First decode entities
    var text = raw
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'")
        .replaceAll('&#39;', "'")
        .replaceAll('&amp;', '&')
        .replaceAll('&nbsp;', ' ');
    // 2. Strip any HTML tags: <a ...>, <img ...>, <font ...>, etc.
    text = text.replaceAll(RegExp(r'<[^>]*>'), ' ');
    // 3. Remove raw URLs
    text = text.replaceAll(RegExp(r'https?:\/\/\S+'), ' ');
    // 4. Normalize whitespaces
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    return text;
  }

  String _determineCategory(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('syllabus') ||
        lower.contains('curriculum') ||
        lower.contains('framework') ||
        lower.contains('textbook') ||
        lower.contains('book')) {
      return 'Curriculum & Books';
    }
    if (lower.contains('exam') ||
        lower.contains('board') ||
        lower.contains('sample paper') ||
        lower.contains('date sheet') ||
        lower.contains('time table')) {
      return 'Exam Alert';
    }
    if (lower.contains('admission') ||
        lower.contains('registration') ||
        lower.contains('counselling') ||
        lower.contains('seat allotment') ||
        lower.contains('neet') ||
        lower.contains('cee')) {
      return 'Admissions & Results';
    }
    if (lower.contains('recruitment') ||
        lower.contains('post') ||
        lower.contains('vacancy') ||
        lower.contains('constable')) {
      return 'Career & Notice';
    }
    return 'NCERT & CBSE Brief';
  }

  String _determineFallbackImage(String category, String title) {
    final lower = '$category $title'.toLowerCase();
    if (lower.contains('exam') || lower.contains('time table') || lower.contains('date sheet')) {
      return 'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?auto=format&fit=crop&w=1000&q=80';
    }
    if (lower.contains('admission') || lower.contains('counselling') || lower.contains('college')) {
      return 'https://images.unsplash.com/photo-1523240795612-9a054b0db644?auto=format&fit=crop&w=1000&q=80';
    }
    if (lower.contains('book') || lower.contains('curriculum') || lower.contains('syllabus')) {
      return 'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?auto=format&fit=crop&w=1000&q=80';
    }
    return 'https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?auto=format&fit=crop&w=1000&q=80';
  }

  String _formatPubDate(String pubDate) {
    if (pubDate.isEmpty) return 'Today';
    try {
      if (pubDate.contains('T')) {
        // ISO format: 2026-10-24T09:45:54+05:30
        final date = DateTime.tryParse(pubDate);
        if (date != null) {
          final now = DateTime.now();
          if (date.year == now.year && date.month == now.month && date.day == now.day) {
            return 'Today';
          }
          final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
          return '${date.day} ${months[date.month - 1]}';
        }
      }
      final parts = pubDate.split(' ');
      if (parts.length >= 4) {
        return '${parts[1]} ${parts[2]}';
      }
    } catch (_) {}
    return 'Today';
  }

  int _parseTimestamp(String pubDate) {
    if (pubDate.isEmpty) return DateTime.now().millisecondsSinceEpoch;
    try {
      if (pubDate.contains('T')) {
        final iso = DateTime.tryParse(pubDate);
        if (iso != null) return iso.millisecondsSinceEpoch;
      }
      final clean = pubDate.replaceAll(RegExp(r'^[A-Za-z]+,\s*'), '');
      final parts = clean.split(' ');
      if (parts.length >= 4) {
        final day = int.tryParse(parts[0]) ?? 1;
        final monthStr = parts[1].toLowerCase();
        final year = int.tryParse(parts[2]) ?? DateTime.now().year;

        const months = {
          'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4,
          'may': 5, 'jun': 6, 'jul': 7, 'aug': 8,
          'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
        };
        final month = months[monthStr] ?? 1;

        int hour = 0;
        int minute = 0;
        int second = 0;
        if (parts[3].contains(':')) {
          final timeParts = parts[3].split(':');
          hour = int.tryParse(timeParts[0]) ?? 0;
          if (timeParts.length > 1) minute = int.tryParse(timeParts[1]) ?? 0;
          if (timeParts.length > 2) second = int.tryParse(timeParts[2]) ?? 0;
        }

        return DateTime.utc(year, month, day, hour, minute, second).millisecondsSinceEpoch;
      }
    } catch (_) {}
    return DateTime.now().millisecondsSinceEpoch;
  }

  List<NcertStory> _getDefaultStories() {
    final now = DateTime.now();
    return [
      NcertStory(
        id: 'default_story_1',
        title: 'CBSE Date Sheet 2027: Practical and Theory Examination Schedule',
        snippet:
            'The Central Board of Secondary Education is preparing to release the official date sheet for Class 10 and 12 examinations. Subject-wise schedules and practical assessment guidelines will be available online for students and affiliated schools.',
        source: 'CBSE Official',
        link: 'https://cbse.gov.in',
        publishedAt: 'Today',
        timestamp: now.subtract(const Duration(hours: 1)).millisecondsSinceEpoch,
        category: 'Exam Alert',
        gradientColors: const [0xFF1E293B, 0xFF1E293B],
        imageUrl:
            'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?auto=format&fit=crop&w=1000&q=80',
      ),
      NcertStory(
        id: 'default_story_2',
        title: 'NCERT Rationalised Textbooks & Digital Study Resources Updated',
        snippet:
            'National Council of Educational Research and Training has made all revised textbooks and exemplar modules available for direct online reading. Content focuses on experiential learning and critical thinking competencies.',
        source: 'NCERT Portal',
        link: 'https://ncert.nic.in',
        publishedAt: 'Yesterday',
        timestamp: now.subtract(const Duration(days: 1)).millisecondsSinceEpoch,
        category: 'Curriculum & Books',
        gradientColors: const [0xFF24272D, 0xFF24272D],
        imageUrl:
            'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?auto=format&fit=crop&w=1000&q=80',
      ),
      NcertStory(
        id: 'default_story_3',
        title: 'Skill Education Modules Introduced for Middle School Curriculum',
        snippet:
            'Schools will integrate hands-on skill education modules including artificial intelligence, coding, and environmental conservation into middle school classes to nurture practical student capabilities.',
        source: 'Education Times',
        link: 'https://timesofindia.indiatimes.com/education',
        publishedAt: '2d ago',
        timestamp: now.subtract(const Duration(days: 2)).millisecondsSinceEpoch,
        category: 'Curriculum & Books',
        gradientColors: const [0xFF20232A, 0xFF20232A],
        imageUrl:
            'https://images.unsplash.com/photo-1532094349884-543bc11b234d?auto=format&fit=crop&w=1000&q=80',
      ),
      NcertStory(
        id: 'default_story_4',
        title: 'Regional Institutes of Education Admission Timelines Announced',
        snippet:
            'Official application guidelines and entrance test registration criteria have been published for academic programs across Regional Institutes of Education. Candidates are advised to review eligibility rules.',
        source: 'Education Desk',
        link: 'https://ncert.nic.in',
        publishedAt: '3d ago',
        timestamp: now.subtract(const Duration(days: 3)).millisecondsSinceEpoch,
        category: 'Admissions & Results',
        gradientColors: const [0xFF162521, 0xFF162521],
        imageUrl:
            'https://images.unsplash.com/photo-1523240795612-9a054b0db644?auto=format&fit=crop&w=1000&q=80',
      ),
    ];
  }
}
