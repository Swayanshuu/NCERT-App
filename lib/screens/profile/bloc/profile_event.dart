abstract class ProfileEvent {}

class ProfileLoadRequested extends ProfileEvent {}

class ProfileNameUpdated extends ProfileEvent {
  final String name;
  ProfileNameUpdated(this.name);
}

class ProfileAvatarUpdated extends ProfileEvent {
  final String avatar;
  ProfileAvatarUpdated(this.avatar);
}

class ProfileClassUpdated extends ProfileEvent {
  final String targetClass;
  ProfileClassUpdated(this.targetClass);
}
