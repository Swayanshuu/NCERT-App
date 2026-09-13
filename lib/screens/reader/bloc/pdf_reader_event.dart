import 'package:ncert_books_app/models/pdf_bookmark.dart';

abstract class PdfReaderEvent {}

class PdfReaderInit extends PdfReaderEvent {
  final int totalPages;
  PdfReaderInit(this.totalPages);
}

class PdfPageChanged extends PdfReaderEvent {
  final int pageNumber;
  PdfPageChanged(this.pageNumber);
}

class PdfThemeChanged extends PdfReaderEvent {
  final String themeMode; // 'day', 'sepia', 'night'
  PdfThemeChanged(this.themeMode);
}

class PdfBookmarkToggled extends PdfReaderEvent {
  final PdfBookmark bookmark;
  PdfBookmarkToggled(this.bookmark);
}
