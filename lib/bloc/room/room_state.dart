import 'package:equatable/equatable.dart';
import 'package:pm1_task_management/models/match_model.dart'; // Import MatchModel

abstract class RoomState extends Equatable {
  const RoomState();

  @override
  List<Object?> get props => []; // Mendukung nilai nullable
}

/// Initial state saat tidak ada proses berlangsung
class RoomInitial extends RoomState {}

/// State saat sedang memuat data
class RoomLoading extends RoomState {}

/// State untuk menunjukkan sukses membuat atau mengelola room
/// State untuk menunjukkan sukses membuat atau mengelola room
class RoomSuccess extends RoomState {
  final MatchModel? match; // Data room yang berhasil dibuat atau diupdate
  final String photoUrl;  // Menyimpan photoUrl untuk ditampilkan di UI

  const RoomSuccess({this.match, required this.photoUrl});

  @override
  List<Object?> get props => [match, photoUrl];
}


/// State saat terjadi kesalahan
class RoomFailure extends RoomState {
  final String message;

  const RoomFailure({required this.message});

  @override
  List<Object> get props => [message];
}
