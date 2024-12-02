import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pm1_task_management/bloc/room/room_bloc.dart';
import 'package:pm1_task_management/bloc/room/room_event.dart';
import 'package:pm1_task_management/bloc/room/room_state.dart';
import 'package:pm1_task_management/routes/router_name.dart';

class PilihMatch extends StatefulWidget {
  final VoidCallback onPressed;

  const PilihMatch({Key? key, required this.onPressed}) : super(key: key);

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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Pilih Mode Bermain",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Tutup modal
                      context.read<RoomBloc>().add(
                            CreateRoomEvent(uid: "user_uid", type: "single"),
                          );
                    },
                    child: _buildModeOption(
                      icon: Icons.person,
                      color: Colors.blue.shade700,
                      label: "Single",
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Tutup modal
                      context.read<RoomBloc>().add(
                            CreateRoomEvent(uid: "user_uid", type: "double"),
                          );
                    },
                    child: _buildModeOption(
                      icon: Icons.people,
                      color: Colors.pink.shade700,
                      label: "Double",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Tutup modal
                  print("Modal ditutup");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Batal",
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModeOption(
      {required IconData icon, required Color color, required String label}) {
    return Container(
      width: 120,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 4,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 50,
            color: color,
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
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
        _showQuizModeSelection(context); // Tampilkan modal
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: BlocConsumer<RoomBloc, RoomState>(
          listener: (context, state) {
            if (state is RoomLoading) {
              final createEvent =
                  context.read<RoomBloc>().state is CreateRoomEvent
                      ? (context.read<RoomBloc>().state as CreateRoomEvent)
                      : null;

              if (createEvent?.type == 'double') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Membuat room...')),
                );
              }
            } else if (state is RoomFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            } else if (state is RoomSuccess) {
              if (state.match == null || state.match!.roomCode == null) {
                // Navigasi langsung ke halaman quiz untuk single
                context.goNamed(Routes.quizPage);
              } else {
                // Navigasi ke RoomPage untuk mode double
                final roomCode = state.match!.roomCode!;
                context.go('/user/dashboard/room/$roomCode');
              }
            }
          },
          builder: (context, state) {
            return Container(
              width: 200,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blue,
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
