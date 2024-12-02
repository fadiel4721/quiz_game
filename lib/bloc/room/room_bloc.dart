import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm1_task_management/bloc/room/room_event.dart';
import 'package:pm1_task_management/bloc/room/room_state.dart';
import 'package:pm1_task_management/models/match_model.dart';

class RoomBloc extends Bloc<RoomEvent, RoomState> {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  RoomBloc({required this.firestore, required this.auth})
      : super(RoomInitial()) {
    on<CreateRoomEvent>(_onCreateRoom);
    on<JoinRoomEvent>(_onJoinRoom);
    on<StartQuizEvent>(_onStartQuiz);
  }

  // Logika untuk membuat room baru
  Future<void> _onCreateRoom(
    CreateRoomEvent event,
    Emitter<RoomState> emit,
  ) async {
    emit(RoomLoading());
    try {
      final user = auth.currentUser;

      if (user == null) {
        emit(RoomFailure(message: 'User not authenticated.'));
        return;
      }

      final userName = user.displayName ?? user.email ?? 'Unknown';

      // Siapkan participants
      final List<String> participants = [userName];

      // Generate unique ID untuk dokumen
      final String matchId = firestore.collection('matches').doc().id;

      if (event.type == 'single') {
        // Mode "single": Tidak perlu simpan ke Firestore, hanya buat objek lokal
        final MatchModel newRoom = MatchModel(
          matchId: matchId, // Gunakan matchId yang dihasilkan
          roomCode: null, // RoomCode null untuk mode single
          type: event.type,
          participants: participants,
          isActive: false,
          scores: {user.uid: 0},
          documentId: matchId, // Document ID sama dengan matchId
        );

        // Emit state tanpa simpan ke Firestore
        emit(RoomSuccess(match: newRoom));
      } else if (event.type == 'double') {
        // Mode "double": Simpan ke Firestore
        final String roomCode = DateTime.now().millisecondsSinceEpoch.toString();
        final MatchModel newRoom = MatchModel(
          matchId: matchId, // Gunakan matchId yang dihasilkan
          roomCode: roomCode, // RoomCode untuk mode double
          type: event.type,
          participants: participants,
          isActive: false,
          scores: {user.uid: 0},
          documentId: matchId, // Document ID sama dengan matchId
        );

        // Simpan dokumen ke Firestore dengan ID tertentu
        await firestore.collection('matches').doc(matchId).set(newRoom.toFirestore());

        emit(RoomSuccess(match: newRoom));
      }
    } catch (e) {
      emit(RoomFailure(message: 'Failed to create room: ${e.toString()}'));
    }
  }

  // Logika untuk bergabung ke room
  Future<void> _onJoinRoom(
    JoinRoomEvent event,
    Emitter<RoomState> emit,
  ) async {
    emit(RoomLoading());
    try {
      // Ambil room berdasarkan roomCode
      final DocumentSnapshot snapshot =
          await firestore.collection('matches').doc(event.roomCode).get();

      if (!snapshot.exists) {
        emit(RoomFailure(message: 'Room not found.'));
        return;
      }

      final MatchModel room = MatchModel.fromFirestore(
          snapshot.data() as Map<String, dynamic>, snapshot.id);

      // Validasi jumlah peserta (maksimal 2 untuk tipe double)
      if (room.type == 'double' && room.participants.length >= 2) {
        emit(RoomFailure(message: 'Room is full.'));
        return;
      }

      // Ambil pengguna yang sedang login
      final user = auth.currentUser;

      if (user == null) {
        emit(RoomFailure(message: 'User not authenticated.'));
        return;
      }

      final userName =
          user.displayName ?? user.email ?? 'Unknown'; // Ambil nama atau email

      // Tambahkan UID ke peserta
      final updatedParticipants = List<String>.from(room.participants)
        ..add(userName);

      // Menambahkan skor awal untuk pengguna baru
      final updatedScore = Map<String, int>.from(room.scores)
        ..putIfAbsent(
            user.uid, () => 0); // Menambahkan skor 0 untuk pengguna baru

      // Update room di Firestore
      await firestore.collection('matches').doc(event.roomCode).update({
        'participants': updatedParticipants,
        'score': updatedScore, // Update field score
      });

      // Emit state baru dengan data yang diperbarui
      emit(RoomSuccess(
        match: room.copyWith(
          participants: updatedParticipants,
          score: updatedScore, // Mengupdate skor
        ),
      ));
    } catch (e) {
      emit(RoomFailure(message: 'Failed to join room: ${e.toString()}'));
    }
  }

  // Logika untuk mulai kuis (akan digunakan nanti)

  // Logika untuk memulai quiz (mengaktifkan room)
  Future<void> _onStartQuiz(
    StartQuizEvent event,
    Emitter<RoomState> emit,
  ) async {
    emit(RoomLoading());
    try {
      // Update isActive menjadi true di Firestore
      await firestore
          .collection('matches')
          .doc(event.roomCode)
          .update({'isActive': true});

      // Ambil room terbaru untuk memastikan data terupdate
      final DocumentSnapshot snapshot =
          await firestore.collection('matches').doc(event.roomCode).get();

      if (!snapshot.exists) {
        emit(RoomFailure(message: 'Room not found.'));
        return;
      }

      final MatchModel room = MatchModel.fromFirestore(
          snapshot.data() as Map<String, dynamic>, snapshot.id);

      emit(RoomSuccess(match: room));
    } catch (e) {
      emit(RoomFailure(message: 'Failed to start quiz: ${e.toString()}'));
    }
  }
}
