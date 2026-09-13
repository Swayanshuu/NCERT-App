abstract class BooksEvent {}

class BooksLoadRequested extends BooksEvent {}

class BookFavoriteToggled extends BooksEvent {
  final String bookId;
  BookFavoriteToggled(this.bookId);
}

class BookCacheCleared extends BooksEvent {}
