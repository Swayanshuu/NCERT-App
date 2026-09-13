import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncert_books_app/services/gamification_service.dart';
import 'progress_event.dart';
import 'progress_state.dart';

export 'progress_event.dart';
export 'progress_state.dart';

class ProgressBloc extends Bloc<ProgressEvent, ProgressState> {
  final GamificationService gamification;

  ProgressBloc({required this.gamification}) : super(const ProgressState()) {
    on<ProgressLoadRequested>(_onLoadRequested);
    on<AchievementClaimed>(_onAchievementClaimed);
  }

  void _onLoadRequested(ProgressLoadRequested event, Emitter<ProgressState> emit) {
    emit(state.copyWith(
      xp: gamification.xp,
      level: gamification.level,
      streakDays: gamification.streak,
      userTitle: gamification.levelTitle,
    ));
  }

  void _onAchievementClaimed(AchievementClaimed event, Emitter<ProgressState> emit) {
    gamification.addXp(100, 'Claimed Achievement');
    emit(state.copyWith(
      xp: gamification.xp,
      level: gamification.level,
      userTitle: gamification.levelTitle,
    ));
  }
}
