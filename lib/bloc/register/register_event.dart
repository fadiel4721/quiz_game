part of 'register_bloc.dart';

@immutable
abstract class RegisterEvent {}

class RegisterSubmitted extends RegisterEvent {
  final String name;
  final String email;
  final String password;
  final String role; // Tambahkan role di event

  RegisterSubmitted({
    required this.name,
    required this.email,
    required this.password,
    required this.role,  // Role akan diterima di sini
  });
}
