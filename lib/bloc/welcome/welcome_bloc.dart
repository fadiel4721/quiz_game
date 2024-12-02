// welcome_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'welcome_event.dart';
import 'welcome_state.dart';

// Bloc untuk menangani event Welcome
class WelcomeBloc extends Bloc<WelcomeEvent, WelcomeState> {
  // Konstruktor
  WelcomeBloc() : super(const WelcomeState()) {
    // Menangani event UserNameChanged
    on<UserNameChanged>((event, emit) {
      // Update state dengan userName baru
      emit(state.copyWith(userName: event.userName));
    });

    // Menangani event StartQuiz
    on<StartQuiz>((event, emit) {
      // Navigasi atau logika lain untuk memulai kuis
      // Misalnya, Anda bisa menambahkan logika untuk navigasi di sini
    });
  }
}
