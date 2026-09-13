import 'package:ncert_books_app/models/ncert_book.dart';

class ExploreState {
  final String selectedSubject;
  final String searchQuery;
  final String selectedClass;
  final List<NcertBook> books;
  final bool isLoading;

  const ExploreState({
    this.selectedSubject = 'All',
    this.searchQuery = '',
    this.selectedClass = '10',
    this.books = const [],
    this.isLoading = false,
  });

  ExploreState copyWith({
    String? selectedSubject,
    String? searchQuery,
    String? selectedClass,
    List<NcertBook>? books,
    bool? isLoading,
  }) {
    return ExploreState(
      selectedSubject: selectedSubject ?? this.selectedSubject,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedClass: selectedClass ?? this.selectedClass,
      books: books ?? this.books,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
