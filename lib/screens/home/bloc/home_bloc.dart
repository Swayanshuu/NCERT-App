import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncert_books_app/services/gamification_service.dart';
import 'home_event.dart';
import 'home_state.dart';

export 'home_event.dart';
export 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GamificationService gamification;

  HomeBloc({required this.gamification}) : super(const HomeState()) {
    on<HomeLoadRequested>(_onLoadRequested);
    on<HomeTabChanged>(_onTabChanged);
    on<HomeClassChanged>(_onClassChanged);
    on<HomeSearchChanged>(_onSearchChanged);
    on<HomeMissionClaimed>(_onMissionClaimed);
  }

  void _onLoadRequested(HomeLoadRequested event, Emitter<HomeState> emit) {
    emit(state.copyWith(
      selectedClass: gamification.userClass,
      xp: gamification.xp,
      level: gamification.level,
      streakDays: gamification.streak,
    ));
  }

  void _onTabChanged(HomeTabChanged event, Emitter<HomeState> emit) {
    emit(state.copyWith(selectedIndex: event.tabIndex));
  }

  void _onClassChanged(HomeClassChanged event, Emitter<HomeState> emit) {
    gamification.setUserClass(event.newClass);
    emit(state.copyWith(selectedClass: event.newClass));
  }

  void _onSearchChanged(HomeSearchChanged event, Emitter<HomeState> emit) {
    emit(state.copyWith(searchQuery: event.query));
  }

  void _onMissionClaimed(HomeMissionClaimed event, Emitter<HomeState> emit) {
    gamification.addXp(40, 'Completed Mission');
    emit(state.copyWith(
      xp: gamification.xp,
      level: gamification.level,
      streakDays: gamification.streak,
    ));
  }
}
