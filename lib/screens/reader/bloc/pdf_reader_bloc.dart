import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncert_books_app/models/pdf_bookmark.dart';
import 'package:ncert_books_app/services/gamification_service.dart';
import 'pdf_reader_event.dart';
import 'pdf_reader_state.dart';

export 'pdf_reader_event.dart';
export 'pdf_reader_state.dart';

class PdfReaderBloc extends Bloc<PdfReaderEvent, PdfReaderState> {
  final GamificationService gamification;

  PdfReaderBloc({required this.gamification}) : super(const PdfReaderState()) {
    on<PdfReaderInit>(_onInit);
    on<PdfPageChanged>(_onPageChanged);
    on<PdfThemeChanged>(_onThemeChanged);
    on<PdfBookmarkToggled>(_onBookmarkToggled);
  }

  void _onInit(PdfReaderInit event, Emitter<PdfReaderState> emit) {
    emit(state.copyWith(totalPages: event.totalPages, currentPage: 1));
  }

  void _onPageChanged(PdfPageChanged event, Emitter<PdfReaderState> emit) {
    final isBookmarked = state.bookmarks.any((b) => b.pageNumber == event.pageNumber);
    emit(state.copyWith(currentPage: event.pageNumber, isBookmarked: isBookmarked));
    gamification.recordReadingSession();
  }

  void _onThemeChanged(PdfThemeChanged event, Emitter<PdfReaderState> emit) {
    emit(state.copyWith(themeMode: event.themeMode));
  }

  void _onBookmarkToggled(PdfBookmarkToggled event, Emitter<PdfReaderState> emit) {
    final updated = List<PdfBookmark>.from(state.bookmarks);
    final exists = updated.any((b) => b.pageNumber == event.bookmark.pageNumber);
    if (exists) {
      updated.removeWhere((b) => b.pageNumber == event.bookmark.pageNumber);
    } else {
      updated.add(event.bookmark);
    }
    emit(state.copyWith(bookmarks: updated, isBookmarked: !exists));
  }
}
