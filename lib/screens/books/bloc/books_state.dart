import 'package:ncert_books_app/models/ncert_book.dart';

class BooksState {
  final List<NcertBook> favoriteBooks;
  final List<String> favoriteIds;
  final bool isLoading;

  const BooksState({
    this.favoriteBooks = const [],
    this.favoriteIds = const [],
    this.isLoading = false,
  });

  BooksState copyWith({
    List<NcertBook>? favoriteBooks,
    List<String>? favoriteIds,
    bool? isLoading,
  }) {
    return BooksState(
      favoriteBooks: favoriteBooks ?? this.favoriteBooks,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
