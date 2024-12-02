part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

class AuthEventLogin extends AuthEvent {
  final String email;
  final String password;

  AuthEventLogin({required this.email, required this.password});
}

class AuthEventGoogleLogin extends AuthEvent {}

class AuthEventLogout extends AuthEvent {}
