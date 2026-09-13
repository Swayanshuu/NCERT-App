class OnboardingState {
  final String username;
  final String selectedAvatar;
  final String selectedClass;
  final bool isCompleted;

  const OnboardingState({
    this.username = 'Student',
    this.selectedAvatar = 'owl',
    this.selectedClass = '10',
    this.isCompleted = false,
  });

  OnboardingState copyWith({
    String? username,
    String? selectedAvatar,
    String? selectedClass,
    bool? isCompleted,
  }) {
    return OnboardingState(
      username: username ?? this.username,
      selectedAvatar: selectedAvatar ?? this.selectedAvatar,
      selectedClass: selectedClass ?? this.selectedClass,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
