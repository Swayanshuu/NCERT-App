import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ncert_notice.dart';

class NcertNoticesService extends ChangeNotifier {
  static final NcertNoticesService _instance = NcertNoticesService._internal();
  static NcertNoticesService get instance => _instance;

  NcertNoticesService._internal();

  static const String _ncertUpdatesUrl = 'https://ncert.nic.in/?ln=en';
  static const String _cacheKey = 'ncert_official_notices_cache_v2';

  List<NcertNotice> _notices = [];
  bool _isLoading = false;
  bool _hasInitialized = false;

  List<NcertNotice> get notices => List.unmodifiable(_notices);
  bool get isLoading => _isLoading;
  int get noticeCount => _notices.length;

  Future<void> init() async {
    if (_hasInitialized) return;
    _hasInitialized = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_cacheKey);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(cachedJson);
        final loaded = decoded
            .map((item) => NcertNotice.fromJson(item as Map<String, dynamic>))
            .where((n) => n.title.isNotEmpty && n.pdfUrl.isNotEmpty)
            .toList();
        if (loaded.isNotEmpty) {
          _notices = loaded;
          notifyListeners();
        }
      }

      if (_notices.isEmpty) {
        _notices = _getDefaultNotices();
        notifyListeners();
      }

      // Fetch fresh notices in background
      fetchLiveNotices();
    } catch (e) {
      debugPrint('Error initializing NcertNoticesService: $e');
      if (_notices.isEmpty) {
        _notices = _getDefaultNotices();
        notifyListeners();
      }
    }
  }

  Future<void> fetchLiveNotices({bool force = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http
          .get(
            Uri.parse(_ncertUpdatesUrl),
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
              'Accept':
                  'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final parsed = _parseHtmlNotices(response.body);
        if (parsed.isNotEmpty) {
          _notices = parsed;

          // Save to cache
          final prefs = await SharedPreferences.getInstance();
          final encoded = jsonEncode(_notices.map((n) => n.toJson()).toList());
          await prefs.setString(_cacheKey, encoded);
        }
      }
    } catch (e) {
      debugPrint('NcertNoticesService: Fetch error ($e). Using cached/default.');
      if (_notices.isEmpty) {
        _notices = _getDefaultNotices();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<NcertNotice> _parseHtmlNotices(String html) {
    final List<NcertNotice> list = [];
    final pattern = RegExp(
      '<a\\s+[^>]*href=["\']([^"\']+)["\'][^>]*>([\\s\\S]*?)</a>',
      caseSensitive: false,
    );

    final matches = pattern.allMatches(html);
    final Set<String> seenUrls = {};

    int newCounter = 0;

    for (final match in matches) {
      final rawHref = match.group(1)?.trim() ?? '';
      final rawText = match.group(2)?.trim() ?? '';

      final cleanTitle = _cleanText(rawText);
      if (cleanTitle.length < 16) continue;

      // Filter for notices, announcements, circulars, press releases, PDFs
      final isRelevant = rawHref.contains('.pdf') ||
          rawHref.contains('announcement') ||
          rawHref.contains('notice') ||
          rawHref.contains('circular') ||
          cleanTitle.toLowerCase().contains('notice') ||
          cleanTitle.toLowerCase().contains('press release') ||
          cleanTitle.toLowerCase().contains('conference');

      if (!isRelevant) continue;

      // Build full URL
      String fullUrl = rawHref;
      if (!fullUrl.startsWith('http')) {
        if (fullUrl.startsWith('/')) {
          fullUrl = 'https://ncert.nic.in$fullUrl';
        } else {
          fullUrl = 'https://ncert.nic.in/$fullUrl';
        }
      }

      if (seenUrls.contains(fullUrl)) continue;
      seenUrls.add(fullUrl);

      final category = _categorizeNotice(cleanTitle);
      final id = 'notice_${cleanTitle.hashCode.abs()}';
      final isPdf = fullUrl.toLowerCase().endsWith('.pdf');

      list.add(
        NcertNotice(
          id: id,
          title: cleanTitle,
          category: category,
          pdfUrl: fullUrl,
          date: newCounter < 3 ? 'Today' : (newCounter < 8 ? 'Recent' : 'Official'),
          fileType: isPdf ? 'PDF' : 'Portal',
          isNew: newCounter < 4,
        ),
      );

      newCounter++;
      if (list.length >= 25) break; // Keep top 25 fresh notices
    }

    return list;
  }

  String _cleanText(String raw) {
    var text = raw
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');
    text = text.replaceAll(RegExp(r'<[^>]*>'), ' ');
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    // Remove leading non-alphanumeric noise
    text = text.replaceAll(RegExp(r'^[^\w\(\"\[]+'), '');
    return text;
  }

  String _categorizeNotice(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('press release') || lower.contains('media')) {
      return 'Press Release';
    }
    if (lower.contains('curriculum') ||
        lower.contains('book') ||
        lower.contains('module') ||
        lower.contains('ai') ||
        lower.contains('textbook')) {
      return 'Curriculum';
    }
    if (lower.contains('exam') ||
        lower.contains('cbt') ||
        lower.contains('test') ||
        lower.contains('admit card') ||
        lower.contains('interview')) {
      return 'Examinations';
    }
    if (lower.contains('conference') || lower.contains('workshop')) {
      return 'Conference';
    }
    if (lower.contains('post') ||
        lower.contains('vacancy') ||
        lower.contains('clerk') ||
        lower.contains('recruitment')) {
      return 'Vacancies';
    }
    return 'Official Notice';
  }

  List<NcertNotice> _getDefaultNotices() {
    return const [
      NcertNotice(
        id: 'notice_ai_module',
        title:
            'NCERT Press Release regarding An Introductory Module on AI & CT (Secondary Stage Grades 9 to 12)',
        category: 'Curriculum',
        pdfUrl:
            'https://ncert.nic.in/pdf/announcement/notices/NCERT_Press_Release_CT_AI_grade_9_12.pdf',
        date: 'Today',
        fileType: 'PDF',
        isNew: true,
      ),
      NcertNotice(
        id: 'notice_fake_book_alert',
        title:
            'NCERT Press Release regarding Class 9 Fake Textbook Social Science Part-1 "Understanding Society: India & Beyond"',
        category: 'Press Release',
        pdfUrl:
            'https://ncert.nic.in/pdf/announcement/notices/NCERT_Press_Release_book_sst.pdf',
        date: 'Today',
        fileType: 'PDF',
        isNew: true,
      ),
      NcertNotice(
        id: 'notice_grade9_books',
        title:
            'NCERT Press Release regarding Availability and Distribution of Grade 9 Revised Textbooks',
        category: 'Curriculum',
        pdfUrl:
            'https://ncert.nic.in/pdf/announcement/notices/NCERT_Press_Release_grade9.pdf',
        date: 'Recent',
        fileType: 'PDF',
        isNew: true,
      ),
      NcertNotice(
        id: 'notice_national_conference',
        title:
            'National Conference on School Libraries 2026: Enhancing Digital Access & Resource Sharing',
        category: 'Conference',
        pdfUrl:
            'https://ncert.nic.in/pdf/announcement/notices/Conference_School_Libraries_2026.pdf',
        date: 'Recent',
        fileType: 'PDF',
        isNew: false,
      ),
      NcertNotice(
        id: 'notice_typing_test',
        title:
            'Instructions/Guidelines to Candidates Appearing for Typing Test and Document Verification',
        category: 'Examinations',
        pdfUrl:
            'https://ncert.nic.in/pdf/announcement/vacancies/nonacademicvacancy/Admit_Card_Link_and_Notification_for__Computer_Typing_Test.pdf',
        date: 'Official',
        fileType: 'PDF',
        isNew: false,
      ),
      NcertNotice(
        id: 'notice_cbt_mock',
        title:
            'Mock Test Link & Advisory for Computer Based Test (CBT) Candidates',
        category: 'Examinations',
        pdfUrl:
            'https://ncert.nic.in/pdf/announcement/vacancies/nonacademicvacancy/Mock_Test_Link_Notice.pdf',
        date: 'Official',
        fileType: 'PDF',
        isNew: false,
      ),
    ];
  }
}
