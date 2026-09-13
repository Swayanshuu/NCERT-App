import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncert_books_app/services/ncert_repository.dart';
import 'package:ncert_books_app/services/pdf_cache_service.dart';
import 'package:ncert_books_app/services/gamification_service.dart';
import 'books_event.dart';
import 'books_state.dart';

export 'books_event.dart';
export 'books_state.dart';

class BooksBloc extends Bloc<BooksEvent, BooksState> {
  final NcertRepository repository;
  final GamificationService gamification;
  final PdfCacheService pdfCache = PdfCacheService();

  BooksBloc({required this.repository, required this.gamification})
      : super(const BooksState()) {
    on<BooksLoadRequested>(_onLoadRequested);
    on<BookFavoriteToggled>(_onFavoriteToggled);
    on<BookCacheCleared>(_onCacheCleared);
  }

  void _onLoadRequested(BooksLoadRequested event, Emitter<BooksState> emit) async {
    emit(state.copyWith(isLoading: true));
    final favIds = gamification.favoriteBookCodes;
    final allBooks = await repository.getAllBooks();
    final favBooks = allBooks.where((b) => favIds.contains(b.code)).toList();
    emit(state.copyWith(
      favoriteIds: favIds,
      favoriteBooks: favBooks,
      isLoading: false,
    ));
  }

  void _onFavoriteToggled(BookFavoriteToggled event, Emitter<BooksState> emit) async {
    gamification.toggleFavorite(event.bookId);
    final favIds = gamification.favoriteBookCodes;
    final allBooks = await repository.getAllBooks();
    final favBooks = allBooks.where((b) => favIds.contains(b.code)).toList();
    emit(state.copyWith(favoriteIds: favIds, favoriteBooks: favBooks));
  }

  void _onCacheCleared(BookCacheCleared event, Emitter<BooksState> emit) async {
    await pdfCache.clearAllCache();
    add(BooksLoadRequested());
  }
}
