import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pm1_task_management/bloc/room/room_bloc.dart';
import 'package:pm1_task_management/bloc/room/room_event.dart';
import 'package:pm1_task_management/bloc/room/room_state.dart';

class SelectRoomPage extends StatefulWidget {
  const SelectRoomPage({super.key});

  @override
  _SelectRoomPageState createState() => _SelectRoomPageState();
}

class _SelectRoomPageState extends State<SelectRoomPage> {
  final TextEditingController _roomCodeController = TextEditingController();

  @override
  void dispose() {
    _roomCodeController.dispose();
    super.dispose();
  }

  void _createNewRoom() {
    context.read<RoomBloc>().add(
          CreateRoomEvent(uid: "user_uid", type: "double"),
        );
  }

  void _joinRoomWithCode() {
    final roomCode = _roomCodeController.text.trim();
    if (roomCode.isNotEmpty) {
      context.go('/user/dashboard/room/$roomCode');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan masukkan kode room yang valid'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RoomBloc, RoomState>(
      listener: (context, state) {
        if (state is RoomFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent,
            ),
          );
        } else if (state is RoomSuccess) {
          final roomCode = state.match?.roomCode;
          if (roomCode != null) {
            context.go('/user/dashboard/room/$roomCode');
          }
        }
      },
      builder: (context, state) {
        final isLoading = state is RoomLoading;

        return Scaffold(
          resizeToAvoidBottomInset: true,
          body: Stack(
            children: [
              // Background SVG
              Positioned.fill(
                child: SvgPicture.asset(
                  "assets/svg/bg.svg",
                  fit: BoxFit.cover,
                ),
              ),

              // Tombol "Exit" di pojok kiri atas
              SafeArea(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: GestureDetector(
                      onTap: () {
                        // Navigates to the dashboard using the route name defined in GoRouter
                        context.goNamed(
                            'dashboard'); // Make sure 'dashboard' is the correct route name
                      },
                    ),
                  ),
                ),
              ),

              SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 24.0,
                    right: 24.0,
                    top: 20.0,
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      const Text(
                        'Bergabung dengan Room atau Buat Room Baru',
                        style: TextStyle(
                          fontFamily: 'NeonLight',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),

                      // Gambar Room
                      Image.asset(
                        'assets/images/room.png',
                        width: 130,
                        height: 130,
                      ),
                      const SizedBox(height: 40),

                      // Tombol Buat Room Baru
                      ElevatedButton(
                        onPressed: isLoading ? null : _createNewRoom,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          backgroundColor: const Color(0xFF001F3F),
                          minimumSize: const Size(double.infinity, 60),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Buat Room Baru',
                                style: TextStyle(
                                  fontFamily: 'NeonLight',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                      const SizedBox(height: 20),

                      // Divider dengan "atau"
                      Row(
                        children: const [
                          Expanded(
                            child: Divider(
                              color: Colors.white38,
                              thickness: 1,
                              endIndent: 10,
                            ),
                          ),
                          Text(
                            'atau',
                            style: TextStyle(
                              fontFamily: 'NeonLight',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white70,
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.white38,
                              thickness: 1,
                              indent: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Input Kode Room
                      TextField(
                        controller: _roomCodeController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Masukkan Kode Room',
                          hintStyle: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'NeonLight',
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: _joinRoomWithCode,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Tombol Bergabung dengan Kode
                      ElevatedButton(
                        onPressed: _joinRoomWithCode,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          backgroundColor:
                              const Color(0xFF001F3F), // Warna tombol berubah
                          minimumSize: const Size(double.infinity, 60),
                        ),
                        child: const Text(
                          'Bergabung dengan Kode',
                          style: TextStyle(
                            fontFamily: 'NeonLight',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
