part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {}

class ProfileEventGet extends ProfileEvent {
  final String uid;

  ProfileEventGet(this.uid);
}

class ProfileEventUpdateName extends ProfileEvent {
  final String name;
  File? file;
  final String uid;
  ProfileEventUpdateName({required this.uid, required this.name, this.file});
}

class ProfileEventPickedImage extends ProfileEvent {}
