import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm1_task_management/bloc/room/room_bloc.dart';
import 'package:pm1_task_management/bloc/room/room_event.dart';
import 'package:pm1_task_management/bloc/room/room_state.dart';
import 'package:pm1_task_management/models/match_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoomPage extends StatelessWidget {
  final String roomCode;

  const RoomPage({Key? key, required this.roomCode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(
          'Lobby Room',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<RoomBloc, RoomState>(
        builder: (context, state) {
          if (state is RoomLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is RoomFailure) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(fontSize: 16, color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          }

          if (state is RoomSuccess) {
            final MatchModel? match = state.match;

            final user1Uid =
                match!.participants.isNotEmpty ? match.participants[0] : null;
            final user2Uid =
                match.participants.length > 1 ? match.participants[1] : null;

            final isQuizReady = match.participants.length == 2;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Room Code
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 24.0),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.vpn_key,
                          color: Colors.blueAccent,
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Room Code: $roomCode',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // User 1 Banner (using assets)
                  BannerUser(
                    photoUrl:
                        'assets/images/player1.jpg', // Local asset path for user1
                    name: user1Uid,
                  ),

                  const SizedBox(height: 20),

                  // User 2 Banner (using assets)
                  BannerUser(
                    photoUrl:
                        'assets/images/player2.jpg', // Local asset path for user2
                    name: user2Uid,
                  ),

                  const SizedBox(height: 40),

                  // Start Quiz Button
                  ElevatedButton(
                    onPressed: isQuizReady
                        ? () {
                            BlocProvider.of<RoomBloc>(context).add(
                              StartQuizEvent(roomCode: roomCode),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40.0, vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      'Mulai Quiz',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class BannerUser extends StatelessWidget {
  final String? photoUrl;
  final String? name;

  const BannerUser({Key? key, this.photoUrl, this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: photoUrl != null
                ? AssetImage(photoUrl!) // Use AssetImage for local assets
                : null,
            radius: 30,
            child: photoUrl == null ? const Icon(Icons.person, size: 30) : null,
          ),
          const SizedBox(width: 16),
          Text(
            name ?? 'Waiting...',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
