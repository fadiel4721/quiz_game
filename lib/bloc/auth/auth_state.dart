part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

final class AuthStateInitial extends AuthState {}

final class AuthStateLoading extends AuthState {}

final class AuthStateLoginSuccess extends AuthState {
  final User? user; 

  AuthStateLoginSuccess(this.user);
}

final class AuthStateError extends AuthState {
  final String message;

  AuthStateError({required this.message});
}

final class AuthStateLoaded extends AuthState {}

final class AuthStateLogoutSuccess extends AuthState {}
