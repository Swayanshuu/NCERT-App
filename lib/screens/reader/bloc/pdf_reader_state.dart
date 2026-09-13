import 'package:ncert_books_app/models/pdf_bookmark.dart';

class PdfReaderState {
  final int currentPage;
  final int totalPages;
  final String themeMode;
  final List<PdfBookmark> bookmarks;
  final bool isBookmarked;

  const PdfReaderState({
    this.currentPage = 1,
    this.totalPages = 1,
    this.themeMode = 'day',
    this.bookmarks = const [],
    this.isBookmarked = false,
  });

  PdfReaderState copyWith({
    int? currentPage,
    int? totalPages,
    String? themeMode,
    List<PdfBookmark>? bookmarks,
    bool? isBookmarked,
  }) {
    return PdfReaderState(
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      themeMode: themeMode ?? this.themeMode,
      bookmarks: bookmarks ?? this.bookmarks,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}
