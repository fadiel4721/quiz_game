import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flame_audio/flame_audio.dart'; // Paket untuk audio
import 'package:pm1_task_management/bloc/profile/profile_bloc.dart';
import 'package:pm1_task_management/routes/router_name.dart';
import 'package:pm1_task_management/widgets/pilih_match.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Untuk SVG

class Dashboard extends StatefulWidget {
  Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with WidgetsBindingObserver {
  FirebaseAuth auth = FirebaseAuth.instance;
  bool isMuted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _playBackgroundMusic(); // Memastikan musik diputar saat pertama kali
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      FlameAudio.bgm.pause(); // Pause audio jika aplikasi diminimalkan
    } else if (state == AppLifecycleState.resumed && !isMuted) {
      _playBackgroundMusic(); // Lanjutkan audio jika aplikasi kembali
    }
  }

  void _playBackgroundMusic() {
    if (!isMuted) {
      FlameAudio.bgm.play('dashboard.mp3', volume: 0.5); // Ganti dengan path audio Anda
    }
  }

  void _toggleMute() {
    setState(() {
      isMuted = !isMuted;
    });
    if (isMuted) {
      FlameAudio.bgm.pause();
    } else {
      _playBackgroundMusic();
    }
  }

  void _playButtonClickSound() {
    FlameAudio.play('button.mp3'); // Pastikan file audio 'button_click.mp3' ada
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background (SVG Image)
          SvgPicture.asset(
            "assets/svg/bg.svg",
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AppBar dengan tombol logout dan profil di pojok kiri
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _playButtonClickSound(); // Suara klik tombol profil
                          context
                              .read<ProfileBloc>()
                              .add(ProfileEventGet(auth.currentUser!.uid));
                          context.goNamed(Routes.profile);
                        },
                        child: FutureBuilder<DocumentSnapshot>( 
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .doc(auth.currentUser?.uid)
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const CircleAvatar(
                                backgroundColor: Colors.grey,
                                radius: 20,
                              );
                            } else if (snapshot.hasError || !snapshot.hasData) {
                              return const CircleAvatar(
                                backgroundColor: Colors.blue,
                                radius: 20,
                              );
                            } else {
                              var userData =
                                  snapshot.data?.data() as Map<String, dynamic>;
                              String? photoUrl = userData['photoUrl'];
                              return CircleAvatar(
                                backgroundImage: photoUrl != null
                                    ? NetworkImage(photoUrl)
                                    : const AssetImage(
                                            'assets/images/default_profile.jpg')
                                        as ImageProvider,
                                radius: 20,
                              );
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0), // Tambahkan padding kanan
                        child: IconButton(
                          iconSize: 30, // Ukuran ikon
                          icon: Image.asset(
                            'assets/images/exit.png',
                            width: 24, // Pastikan ukuran konsisten
                            height: 24,
                          ),
                          onPressed: () async {
                            _playButtonClickSound(); // Suara klik tombol logout
                            bool? shouldLogout =
                                await _showLogoutConfirmationDialog(context);
                            if (shouldLogout == true) {
                              FirebaseAuth.instance.signOut();
                              FlameAudio.bgm.stop(); // Hentikan audio saat logout
                              context.go('/login');
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Gambar dan Judul
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black45,
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                'assets/images/quiz.jpg',
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Nama di Body
                          FutureBuilder<DocumentSnapshot>( 
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .doc(auth.currentUser?.uid)
                                .get(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const CircularProgressIndicator(
                                    color: Colors.white);
                              } else if (snapshot.hasError || !snapshot.hasData) {
                                return const Text(
                                  'Hi, User',
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'NeonLight',
                                  ),
                                  textAlign: TextAlign.center,
                                );
                              } else {
                                var userData =
                                    snapshot.data?.data() as Map<String, dynamic>;
                                String name = userData['name'] ?? 'User';
                                return Text(
                                  'Hi, $name',
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'NeonLight',
                                  ),
                                  textAlign: TextAlign.center,
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 24),
                          // Tombol Start Quiz dengan PilihMatch
                          PilihMatch(
                            onPressed: () {
                              _playButtonClickSound(); // Suara klik tombol PilihMatch
                              FlameAudio.bgm.stop(); // Hentikan audio saat PilihMatch
                              print("Quiz Button Pressed");
                            },
                          ),
                          const SizedBox(height: 16),
                          // Tombol Leaderboard
                          ElevatedButton(
                            onPressed: () {
                              _playButtonClickSound(); // Suara klik tombol Leaderboard
                              context.goNamed(Routes.leaderBoard);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32.0, vertical: 16.0),
                              shadowColor: Colors.white,
                              elevation: 5,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/images/medal.png',
                                  width: 24,
                                  height: 24,
                                  fit: BoxFit.cover,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'LEADERBOARD',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'NeonLight',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Tombol Mute/Unmute Audio dengan Ikon
                          IconButton(
                            icon: Image.asset(
                              isMuted
                                  ? 'assets/images/mute.png' // Ganti dengan ikon mute Anda
                                  : 'assets/images/unmute.png', // Ganti dengan ikon unmute Anda
                              width: 24,
                              height: 24,
                            ),
                            onPressed: _toggleMute,
                          ),
                        ],
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
  }

  Future<bool?> _showLogoutConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
