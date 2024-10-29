part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {}

class ProfileEventGet extends ProfileEvent {
  final String uid;

  ProfileEventGet(this.uid);
}

class ProfileEventUpdateName extends ProfileEvent {
  final String name;
  final String uid;
  ProfileEventUpdateName({required this.uid, required this.name});
}

class ProfileEventUpdateImage extends ProfileEvent {
  final XFile image;
  final String uid;
  ProfileEventUpdateImage({required this.image, required this.uid});
}
