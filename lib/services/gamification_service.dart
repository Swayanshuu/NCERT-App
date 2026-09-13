import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/pdf_bookmark.dart';

class GamificationService extends ChangeNotifier {
  static final GamificationService _instance = GamificationService._internal();
  factory GamificationService() => _instance;
  GamificationService._internal();

  bool _isDarkMode = false;
  bool _isOnboardingCompleted = false;
  String _userClass = '10';
  String _userName = 'Student';
  int _xp = 50;
  int _streak = 1;
  String _currentAvatar = '🦉 Smart Owl';
  String _lastReadDate = '';
  String _lastDailyBonusDate = '';
  String _lastExploredDate = '';
  String _lastExploredSubject = '';
  List<String> _unlockedBadges = ['Book Explorer 🌟'];
  List<String> _favoriteBookCodes = [];
  List<PdfBookmark> _bookmarks = [];

  bool get isDarkMode => _isDarkMode;
  bool get isOnboardingCompleted => _isOnboardingCompleted;
  String get userClass => _userClass;
  String get userName => _userName;
  int get xp => _xp;
  int get level => (_xp ~/ 100) + 1;
  int get levelProgressXp => _xp % 100;
  int get streak => _streak;
  String get currentAvatar => _currentAvatar;
  List<String> get unlockedBadges => _unlockedBadges;
  List<String> get favoriteBookCodes => _favoriteBookCodes;
  List<PdfBookmark> get bookmarks => _bookmarks;

  String get levelTitle {
    final lvl = level;
    if (lvl == 1) return 'Little Scholar 🐣';
    if (lvl == 2) return 'Book Explorer 🧭';
    if (lvl == 3) return 'Knowledge Knight 🛡️';
    if (lvl == 4) return 'Master Mind 🧠';
    if (lvl == 5) return 'Wizard Scholar 🧙‍♂️';
    return 'Legendary Sage 👑';
  }

  String get levelSymbol {
    final lvl = level;
    if (lvl == 10) return '🐣';
    if (lvl == 20) return '🧭';
    if (lvl == 30) return '🛡️';
    if (lvl == 40) return '🧠';
    if (lvl == 50) return '🧙‍♂️';
    return '👑';
  }

  List<Map<String, dynamic>> get dailyQuests {
    final todayStr = DateTime.now().toIso8601String().split('T').first;
    final readDone = _lastReadDate == todayStr;
    final exploreDone = _lastExploredDate == todayStr;
    final favDone = _favoriteBookCodes.isNotEmpty || _bookmarks.isNotEmpty;

    return [
      {
        'id': 'daily_read',
        'title': 'Read 1 Chapter Today',
        'desc': 'Open and read any NCERT chapter',
        'xp': 30,
        'icon': Icons.menu_book_rounded,
        'isCompleted': readDone,
        'actionHint': 'Open any NCERT chapter to auto-complete this mission! 📖',
      },
      {
        'id': 'daily_explore',
        'title': 'Explore Subject Worlds',
        'desc': 'Browse books in any subject world',
        'xp': 40,
        'icon': Icons.calculate_rounded,
        'isCompleted': exploreDone,
        'actionHint': 'Select any subject filter above to auto-complete! 📐',
      },
      {
        'id': 'daily_fav',
        'title': 'Bookmark a Favorite Book',
        'desc': 'Tap heart icon ❤️ on any book',
        'xp': 20,
        'icon': Icons.bookmark_added_rounded,
        'isCompleted': favDone,
        'actionHint': 'Tap the heart icon ❤️ on any book card to auto-complete!',
      },
    ];
  }

  bool get canClaimDailyBonus {
    final today = DateTime.now().toIso8601String().split('T').first;
    return _lastDailyBonusDate != today;
  }

  int get hoursUntilNextBonus {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final diff = tomorrow.difference(now);
    final hours = diff.inHours;
    return hours <= 0 ? 1 : (hours > 24 ? 24 : hours);
  }

  String get timeUntilNextBonusFormatted {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final diff = tomorrow.difference(now);
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  static const List<String> avatars = [
    '🦉 Smart Owl',
    '🦊 Clever Fox',
    '🚀 Space Cadet',
    '🐼 Wise Panda',
    '🐰 Hero Bunny',
  ];

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('is_dark_mode') ?? false;
    _isOnboardingCompleted = prefs.getBool('is_onboarding_completed') ?? false;
    _userClass = prefs.getString('user_class') ?? '10';
    _userName = prefs.getString('user_name') ?? 'Student';
    _xp = prefs.getInt('user_xp') ?? 50;
    _streak = prefs.getInt('user_streak') ?? 1;
    _currentAvatar = prefs.getString('user_avatar') ?? '🦉 Smart Owl';
    _lastReadDate = prefs.getString('last_read_date') ?? '';
    _lastDailyBonusDate = prefs.getString('last_daily_bonus_date') ?? '';
    _lastExploredDate = prefs.getString('last_explored_date') ?? '';
    _lastExploredSubject = prefs.getString('last_explored_subject') ?? '';
    _unlockedBadges =
        prefs.getStringList('unlocked_badges') ?? ['Book Explorer 🌟'];
    _favoriteBookCodes = prefs.getStringList('favorite_books') ?? [];

    final rawBookmarks = prefs.getStringList('saved_pdf_bookmarks') ?? [];
    _bookmarks = rawBookmarks
        .map((str) {
          try {
            return PdfBookmark.fromJson(jsonDecode(str));
          } catch (_) {
            return null;
          }
        })
        .whereType<PdfBookmark>()
        .toList();

    _checkStreak();
    notifyListeners();
  }

  void completeOnboarding(
    String avatar,
    String selectedClass, [
    String name = 'Student',
  ]) async {
    _currentAvatar = avatar;
    _userClass = selectedClass;
    _userName = name.trim().isEmpty ? 'Student' : name.trim();
    _isOnboardingCompleted = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_onboarding_completed', true);
    await prefs.setString('user_avatar', avatar);
    await prefs.setString('user_class', selectedClass);
    await prefs.setString('user_name', _userName);
    notifyListeners();
  }

  void setUserName(String name) async {
    _userName = name.trim().isEmpty ? 'Student' : name.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _userName);
    notifyListeners();
  }

  bool claimDailyBonus() {
    final today = DateTime.now().toIso8601String().split('T').first;
    if (_lastDailyBonusDate == today) {
      return false; // Already claimed today
    }
    _lastDailyBonusDate = today;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('last_daily_bonus_date', _lastDailyBonusDate);
    });
    addXp(50, 'Claimed Daily Bonus!');
    return true;
  }

  void setUserClass(String className) async {
    _userClass = className;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_class', className);
    notifyListeners();
  }

  void recordSubjectExplored([String? subjectName]) async {
    final todayStr = DateTime.now().toIso8601String().split('T').first;
    if (_lastExploredDate != todayStr) {
      _lastExploredDate = todayStr;
      if (subjectName != null && subjectName.isNotEmpty) {
        _lastExploredSubject = subjectName;
      }
      addXp(40, 'Explored Subject World!');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_explored_date', _lastExploredDate);
      await prefs.setString('last_explored_subject', _lastExploredSubject);
      notifyListeners();
    }
  }

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', _isDarkMode);
    notifyListeners();
  }

  void setAvatar(String avatar) async {
    _currentAvatar = avatar;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_avatar', avatar);
    notifyListeners();
  }

  void toggleFavorite(String bookCode) async {
    if (_favoriteBookCodes.contains(bookCode)) {
      _favoriteBookCodes.remove(bookCode);
    } else {
      _favoriteBookCodes.add(bookCode);
      addXp(15, 'Favorited a book!');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorite_books', _favoriteBookCodes);
    notifyListeners();
  }

  bool isFavorite(String bookCode) {
    return _favoriteBookCodes.contains(bookCode);
  }

  bool isPageBookmarked(
    String bookCodeOrTitle,
    String chapterTitle,
    int pageNumber,
  ) {
    return _bookmarks.any(
      (b) =>
          (b.bookCode == bookCodeOrTitle || b.bookTitle == bookCodeOrTitle) &&
          b.chapterTitle == chapterTitle &&
          b.pageNumber == pageNumber,
    );
  }

  void toggleBookmark(PdfBookmark bookmark) async {
    final existingIdx = _bookmarks.indexWhere(
      (b) =>
          b.bookCode == bookmark.bookCode &&
          b.chapterTitle == bookmark.chapterTitle &&
          b.pageNumber == bookmark.pageNumber,
    );

    if (existingIdx >= 0) {
      _bookmarks.removeAt(existingIdx);
    } else {
      _bookmarks.insert(0, bookmark);
      addXp(10, 'Bookmarked Page!');
    }
    await _saveBookmarks();
    notifyListeners();
  }

  void removeBookmark(String id) async {
    _bookmarks.removeWhere((b) => b.id == id);
    await _saveBookmarks();
    notifyListeners();
  }

  Future<void> _saveBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = _bookmarks.map((b) => jsonEncode(b.toJson())).toList();
    await prefs.setStringList('saved_pdf_bookmarks', rawList);
  }

  void addXp(int amount, String reason) async {
    _xp += amount;
    _checkBadges();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_xp', _xp);
    notifyListeners();
  }

  void recordReadingSession() async {
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    if (_lastReadDate.isEmpty) {
      _streak = 1;
      _lastReadDate = todayStr;
      await _saveStreakData();
      addXp(25, 'First Reading Day!');
      return;
    }

    if (_lastReadDate == todayStr) {
      // Already recorded today, maintain current streak
      return;
    }

    final lastDate = DateTime.tryParse(_lastReadDate);
    if (lastDate != null) {
      final todayDate = DateTime(now.year, now.month, now.day);
      final lastReadDayDate = DateTime(
        lastDate.year,
        lastDate.month,
        lastDate.day,
      );
      final differenceInDays = todayDate.difference(lastReadDayDate).inDays;

      if (differenceInDays == 1) {
        // Consecutive calendar day reading!
        _streak++;
        addXp(25, 'Streak Extended (+1 Day)!');
      } else {
        // Missed one or more days, reset streak to 1 for today
        _streak = 1;
        addXp(25, 'New Streak Started!');
      }
    } else {
      _streak = 1;
    }

    _lastReadDate = todayStr;
    await _saveStreakData();
  }

  void _checkStreak() async {
    if (_lastReadDate.isEmpty) return;
    final lastDate = DateTime.tryParse(_lastReadDate);
    if (lastDate != null) {
      final now = DateTime.now();
      final todayDate = DateTime(now.year, now.month, now.day);
      final lastReadDayDate = DateTime(
        lastDate.year,
        lastDate.month,
        lastDate.day,
      );
      final differenceInDays = todayDate.difference(lastReadDayDate).inDays;

      if (differenceInDays > 1) {
        // Missed calendar days, reset streak to 0 until user reads
        _streak = 0;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_streak', _streak);
      }
    }
  }

  Future<void> _saveStreakData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_streak', _streak);
    await prefs.setString('last_read_date', _lastReadDate);
    notifyListeners();
  }

  void _checkBadges() async {
    final newBadges = List<String>.from(_unlockedBadges);

    if (_xp >= 100 && !newBadges.contains('Super Reader 📖')) {
      newBadges.add('Super Reader 📖');
    }
    if (_xp >= 300 && !newBadges.contains('Master Mind 🧠')) {
      newBadges.add('Master Mind 🧠');
    }
    if (_streak >= 3 && !newBadges.contains('Streak Champ 🔥')) {
      newBadges.add('Streak Champ 🔥');
    }
    if (_favoriteBookCodes.length >= 5 &&
        !newBadges.contains('Book Collector 📚')) {
      newBadges.add('Book Collector 📚');
    }

    if (newBadges.length != _unlockedBadges.length) {
      _unlockedBadges = newBadges;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('unlocked_badges', _unlockedBadges);
    }
  }
}
