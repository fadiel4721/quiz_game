// welcome_event.dart
import 'package:equatable/equatable.dart';

// Event untuk perubahan pada nama pengguna
abstract class WelcomeEvent extends Equatable {
  const WelcomeEvent();

  @override
  List<Object> get props => [];
}

// Event ketika nama pengguna berubah
class UserNameChanged extends WelcomeEvent {
  final String userName;
  const UserNameChanged(this.userName);

  @override
  List<Object> get props => [userName];
}

// Event untuk memulai kuis
class StartQuiz extends WelcomeEvent {}
