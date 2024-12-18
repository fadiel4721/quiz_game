import 'package:equatable/equatable.dart';

abstract class RoomEvent extends Equatable {
  const RoomEvent();

  @override
  List<Object> get props => [];
}

/// Event untuk membuat room baru
class CreateRoomEvent extends RoomEvent {
  final String uid; // UID pengguna yang membuat room
  final String type; // Tipe room: single atau double
  

  const CreateRoomEvent({required this.uid, required this.type});

  @override
  List<Object> get props => [uid, type];
}

/// Event untuk bergabung ke room
class JoinRoomEvent extends RoomEvent {
  final String uid; // UID pengguna yang ingin join
  final String roomCode; // Kode room yang akan di-join

  const JoinRoomEvent({required this.uid, required this.roomCode});

  @override
  List<Object> get props => [uid, roomCode];
}

/// Event untuk memulai quiz (mengaktifkan room)
class StartQuizEvent extends RoomEvent {
  final String roomCode; // Kode room yang akan diaktifkan

  const StartQuizEvent({required this.roomCode});

  @override
  List<Object> get props => [roomCode];
}
