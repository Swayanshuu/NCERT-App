class ProgressState {
  final int xp;
  final int level;
  final int streakDays;
  final String userTitle;
  final bool isLoading;

  const ProgressState({
    this.xp = 0,
    this.level = 1,
    this.streakDays = 1,
    this.userTitle = 'Scholar',
    this.isLoading = false,
  });

  ProgressState copyWith({
    int? xp,
    int? level,
    int? streakDays,
    String? userTitle,
    bool? isLoading,
  }) {
    return ProgressState(
      xp: xp ?? this.xp,
      level: level ?? this.level,
      streakDays: streakDays ?? this.streakDays,
      userTitle: userTitle ?? this.userTitle,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
