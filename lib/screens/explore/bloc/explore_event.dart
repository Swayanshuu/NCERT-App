abstract class ExploreEvent {}

class ExploreLoadRequested extends ExploreEvent {}

class ExploreQueryChanged extends ExploreEvent {
  final String query;
  ExploreQueryChanged(this.query);
}

class ExploreSubjectSelected extends ExploreEvent {
  final String subject;
  ExploreSubjectSelected(this.subject);
}

class ExploreClassChanged extends ExploreEvent {
  final String newClass;
  ExploreClassChanged(this.newClass);
}
