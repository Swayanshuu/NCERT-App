class ProfileState {
  final String username;
  final String avatar;
  final String targetClass;
  final int totalXp;
  final int level;
  final int streakDays;

  const ProfileState({
    this.username = 'Student',
    this.avatar = 'owl',
    this.targetClass = '10',
    this.totalXp = 0,
    this.level = 1,
    this.streakDays = 1,
  });

  ProfileState copyWith({
    String? username,
    String? avatar,
    String? targetClass,
    int? totalXp,
    int? level,
    int? streakDays,
  }) {
    return ProfileState(
      username: username ?? this.username,
      avatar: avatar ?? this.avatar,
      targetClass: targetClass ?? this.targetClass,
      totalXp: totalXp ?? this.totalXp,
      level: level ?? this.level,
      streakDays: streakDays ?? this.streakDays,
    );
  }
}
