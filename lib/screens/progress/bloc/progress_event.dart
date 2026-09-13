abstract class ProgressEvent {}

class ProgressLoadRequested extends ProgressEvent {}

class AchievementClaimed extends ProgressEvent {
  final String achievementId;
  AchievementClaimed(this.achievementId);
}
