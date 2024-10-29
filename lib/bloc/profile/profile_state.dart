part of 'profile_bloc.dart';

@immutable
sealed class ProfileState {}

final class ProfileStateInitial extends ProfileState {}

final class ProfileStateLoading extends ProfileState {}

final class ProfileStateLoaded extends ProfileState {
  final UserModel userModel;

  ProfileStateLoaded(this.userModel);
}

final class ProfileStateError extends ProfileState {
  final String message;

  ProfileStateError({required this.message});
}

final class ProfileStateNameUpdated extends ProfileState {}

final class ProfileStatePickedImage extends ProfileState {
  final XFile image;

  ProfileStatePickedImage({required this.image});
}
