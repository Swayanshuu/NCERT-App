abstract class OnboardingEvent {}

class OnboardingAvatarSelected extends OnboardingEvent {
  final String avatar;
  OnboardingAvatarSelected(this.avatar);
}

class OnboardingClassSelected extends OnboardingEvent {
  final String targetClass;
  OnboardingClassSelected(this.targetClass);
}

class OnboardingCompleted extends OnboardingEvent {
  final String username;
  final String avatar;
  final String targetClass;
  OnboardingCompleted({
    required this.username,
    required this.avatar,
    required this.targetClass,
  });
}
