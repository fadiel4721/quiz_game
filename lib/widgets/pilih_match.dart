import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pm1_task_management/bloc/room/room_bloc.dart';
import 'package:pm1_task_management/bloc/room/room_event.dart';
import 'package:pm1_task_management/bloc/room/room_state.dart';
import 'package:pm1_task_management/routes/router_name.dart';

class PilihMatch extends StatefulWidget {
  final VoidCallback onPressed;

  const PilihMatch({super.key, required this.onPressed});

  @override
  _PilihMatchState createState() => _PilihMatchState();
}

class _PilihMatchState extends State<PilihMatch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation =
        Tween<double>(begin: 1.0, end: 1.1).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showQuizModeSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Mode Single
              GestureDetector(
                onTap: () {
                  Navigator.pop(context); // Tutup modal
                  context.read<RoomBloc>().add(
                        CreateRoomEvent(uid: "user_uid", type: "single"),
                      );
                },
                child: _buildModeOption(
                  imageAsset: 'assets/images/gamepad.png',
                  label: "Single",
                ),
              ),
              // Mode Double
              GestureDetector(
                onTap: () {
                  Navigator.pop(context); // Tutup modal
                  context.goNamed(
                      Routes.selectRoomPage); // Langsung ke SelectRoomPage
                },
                child: _buildModeOption(
                  imageAsset: 'assets/images/multiplayer.png',
                  label: "Double",
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModeOption({
    required String imageAsset,
    required String label,
  }) {
    return Container(
      width: 120,
      height: 150,
      decoration: BoxDecoration(
        color: const Color(0xFF001F3F), // Background warna biru gelap
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.3),
            spreadRadius: 4,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imageAsset,
            width: 60,
            height: 60,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'NeonLight', // Font NeonLight
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showQuizModeSelection(context);
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: BlocConsumer<RoomBloc, RoomState>(
          listener: (context, state) {
            if (state is RoomFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            } else if (state is RoomSuccess) {
              if (state.match == null || state.match!.roomCode == null) {
                context
                    .goNamed(Routes.quizPage); // Navigasi ke quiz untuk single
              }
            }
          },
          builder: (context, state) {
            return Container(
              width: 200,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF001F3F), // Warna latar belakang card
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.4),
                    spreadRadius: 4,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  "Mulai Quiz",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'NeonLight', // Menambahkan font NeonLight
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}