import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncert_books_app/services/gamification_service.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

export 'onboarding_event.dart';
export 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final GamificationService gamification;

  OnboardingBloc({required this.gamification}) : super(const OnboardingState()) {
    on<OnboardingAvatarSelected>(_onAvatarSelected);
    on<OnboardingClassSelected>(_onClassSelected);
    on<OnboardingCompleted>(_onCompleted);
  }

  void _onAvatarSelected(OnboardingAvatarSelected event, Emitter<OnboardingState> emit) {
    emit(state.copyWith(selectedAvatar: event.avatar));
  }

  void _onClassSelected(OnboardingClassSelected event, Emitter<OnboardingState> emit) {
    emit(state.copyWith(selectedClass: event.targetClass));
  }

  void _onCompleted(OnboardingCompleted event, Emitter<OnboardingState> emit) {
    gamification.completeOnboarding(event.avatar, event.targetClass, event.username);
    emit(state.copyWith(isCompleted: true));
  }
}
