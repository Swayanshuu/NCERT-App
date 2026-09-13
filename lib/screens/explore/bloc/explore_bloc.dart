import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncert_books_app/services/ncert_repository.dart';
import 'package:ncert_books_app/services/gamification_service.dart';
import 'explore_event.dart';
import 'explore_state.dart';

export 'explore_event.dart';
export 'explore_state.dart';

class ExploreBloc extends Bloc<ExploreEvent, ExploreState> {
  final NcertRepository repository;
  final GamificationService gamification;

  ExploreBloc({required this.repository, required this.gamification})
      : super(const ExploreState()) {
    on<ExploreLoadRequested>(_onLoadRequested);
    on<ExploreQueryChanged>(_onQueryChanged);
    on<ExploreSubjectSelected>(_onSubjectSelected);
    on<ExploreClassChanged>(_onClassChanged);
  }

  void _onLoadRequested(ExploreLoadRequested event, Emitter<ExploreState> emit) async {
    emit(state.copyWith(isLoading: true));
    final currentClass = gamification.userClass;
    final books = await repository.getBooksByClass(currentClass);
    emit(state.copyWith(
      selectedClass: currentClass,
      books: books,
      isLoading: false,
    ));
  }

  void _onQueryChanged(ExploreQueryChanged event, Emitter<ExploreState> emit) {
    emit(state.copyWith(searchQuery: event.query));
  }

  void _onSubjectSelected(ExploreSubjectSelected event, Emitter<ExploreState> emit) {
    emit(state.copyWith(selectedSubject: event.subject));
    if (event.subject != 'All') {
      gamification.recordSubjectExplored(event.subject);
    }
  }

  void _onClassChanged(ExploreClassChanged event, Emitter<ExploreState> emit) async {
    emit(state.copyWith(isLoading: true, selectedClass: event.newClass));
    final books = await repository.getBooksByClass(event.newClass);
    emit(state.copyWith(books: books, isLoading: false));
  }
}
