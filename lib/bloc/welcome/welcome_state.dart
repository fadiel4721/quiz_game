// welcome_state.dart
import 'package:equatable/equatable.dart';

// State untuk menyimpan informasi nama pengguna
class WelcomeState extends Equatable {
  final String userName; // Nama pengguna

  const WelcomeState({this.userName = ''});

  // Menyediakan metode untuk mengubah nilai state tanpa mengubah yang lainnya
  WelcomeState copyWith({String? userName}) {
    return WelcomeState(userName: userName ?? this.userName);
  }

  @override
  List<Object> get props => [userName]; // Menyatakan bahwa perubahan pada userName mempengaruhi state
}
