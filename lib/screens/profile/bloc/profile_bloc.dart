import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncert_books_app/services/gamification_service.dart';
import 'profile_event.dart';
import 'profile_state.dart';

export 'profile_event.dart';
export 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GamificationService gamification;

  ProfileBloc({required this.gamification}) : super(const ProfileState()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileNameUpdated>(_onNameUpdated);
    on<ProfileAvatarUpdated>(_onAvatarUpdated);
    on<ProfileClassUpdated>(_onClassUpdated);
  }

  void _onLoadRequested(ProfileLoadRequested event, Emitter<ProfileState> emit) {
    emit(state.copyWith(
      username: gamification.userName,
      avatar: gamification.currentAvatar,
      targetClass: gamification.userClass,
      totalXp: gamification.xp,
      level: gamification.level,
      streakDays: gamification.streak,
    ));
  }

  void _onNameUpdated(ProfileNameUpdated event, Emitter<ProfileState> emit) {
    gamification.setUserName(event.name);
    emit(state.copyWith(username: event.name));
  }

  void _onAvatarUpdated(ProfileAvatarUpdated event, Emitter<ProfileState> emit) {
    gamification.setAvatar(event.avatar);
    emit(state.copyWith(avatar: event.avatar));
  }

  void _onClassUpdated(ProfileClassUpdated event, Emitter<ProfileState> emit) {
    gamification.setUserClass(event.targetClass);
    emit(state.copyWith(targetClass: event.targetClass));
  }
}
