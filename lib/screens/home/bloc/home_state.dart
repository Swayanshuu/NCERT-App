class HomeState {
  final int selectedIndex;
  final String selectedClass;
  final String searchQuery;
  final bool isLoading;
  final int xp;
  final int level;
  final int streakDays;

  const HomeState({
    this.selectedIndex = 0,
    this.selectedClass = '10',
    this.searchQuery = '',
    this.isLoading = false,
    this.xp = 0,
    this.level = 1,
    this.streakDays = 1,
  });

  HomeState copyWith({
    int? selectedIndex,
    String? selectedClass,
    String? searchQuery,
    bool? isLoading,
    int? xp,
    int? level,
    int? streakDays,
  }) {
    return HomeState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      selectedClass: selectedClass ?? this.selectedClass,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      streakDays: streakDays ?? this.streakDays,
    );
  }
}
