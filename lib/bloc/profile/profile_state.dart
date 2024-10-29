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

  ProfileStateError(this.message);
}
final class ProfileStateUpdated extends ProfileState {}
final class ProfileStateImageUpdated extends ProfileState {}

