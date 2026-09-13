abstract class HomeEvent {}

class HomeLoadRequested extends HomeEvent {}

class HomeTabChanged extends HomeEvent {
  final int tabIndex;
  HomeTabChanged(this.tabIndex);
}

class HomeClassChanged extends HomeEvent {
  final String newClass;
  HomeClassChanged(this.newClass);
}

class HomeSearchChanged extends HomeEvent {
  final String query;
  HomeSearchChanged(this.query);
}

class HomeMissionClaimed extends HomeEvent {
  final String missionId;
  HomeMissionClaimed(this.missionId);
}
