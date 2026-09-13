import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/ncert_book.dart';

class NcertRepository {
  static final NcertRepository _instance = NcertRepository._internal();
  factory NcertRepository() => _instance;
  NcertRepository._internal();

  Map<String, Map<String, List<NcertBook>>> _catalog = {};
  bool _isLoaded = false;

  Future<void> loadCatalog() async {
    if (_isLoaded) return;

    final jsonString = await rootBundle.loadString('assets/data.json');
    final Map<String, dynamic> rawData = jsonDecode(jsonString);

    _catalog = {};

    rawData.forEach((className, subjectsMap) {
      if (subjectsMap is Map<String, dynamic>) {
        final Map<String, List<NcertBook>> subMap = {};

        subjectsMap.forEach((subjectName, booksList) {
          if (booksList is List) {
            final List<NcertBook> books = [];
            for (final item in booksList) {
              if (item is Map<String, dynamic> && item['code'] != null && (item['code'] as String).isNotEmpty) {
                books.add(NcertBook.fromJson(item, className, subjectName));
              }
            }
            if (books.isNotEmpty) {
              subMap[subjectName] = books;
            }
          }
        });

        if (subMap.isNotEmpty) {
          _catalog[className] = subMap;
        }
      }
    });

    _isLoaded = true;
  }

  List<String> getAvailableClasses() {
    final list = _catalog.keys.toList();
    list.sort((a, b) => (int.tryParse(a) ?? 99).compareTo(int.tryParse(b) ?? 99));
    return list;
  }

  List<String> getSubjectsForClass(String className) {
    if (!_catalog.containsKey(className)) return [];
    return _catalog[className]!.keys.toList();
  }

  List<NcertBook> getBooks(String className, String subject) {
    if (!_catalog.containsKey(className)) return [];
    return _catalog[className]![subject] ?? [];
  }

  List<NcertBook> searchBooks(String query) {
    if (query.trim().isEmpty) return [];
    final q = query.toLowerCase();
    final List<NcertBook> results = [];

    _catalog.forEach((cls, subjects) {
      subjects.forEach((subj, books) {
        for (final b in books) {
          if (b.text.toLowerCase().contains(q) || b.subject.toLowerCase().contains(q) || b.className.contains(q)) {
            results.add(b);
          }
        }
      });
    });

    return results;
  }

  Future<List<NcertBook>> getAllBooks() async {
    await loadCatalog();
    final List<NcertBook> results = [];
    _catalog.forEach((cls, subjects) {
      subjects.forEach((subj, books) {
        results.addAll(books);
      });
    });
    return results;
  }

  Future<List<NcertBook>> getBooksByClass(String className) async {
    await loadCatalog();
    if (!_catalog.containsKey(className)) return [];
    final List<NcertBook> results = [];
    _catalog[className]!.forEach((subj, books) {
      results.addAll(books);
    });
    return results;
  }
}