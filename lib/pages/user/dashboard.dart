import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pm1_task_management/bloc/profile/profile_bloc.dart';
import 'package:pm1_task_management/routes/router_name.dart';
import 'package:pm1_task_management/widgets/pilih_match.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import untuk SVG

class Dashboard extends StatelessWidget {
  Dashboard({super.key});

  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background (SVG Image)
          SvgPicture.asset(
            "assets/svg/bg.svg", // Path ke file SVG Anda
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // AppBar dengan tombol logout
                    AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      automaticallyImplyLeading: false,
                      title: Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
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
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircleAvatar(
                                  backgroundColor: Colors.grey,
                                  radius: 20,
                                );
                              } else if (snapshot.hasError ||
                                  !snapshot.hasData) {
                                return const CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  radius: 20,
                                );
                              } else {
                                var userData = snapshot.data?.data()
                                    as Map<String, dynamic>;
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
                      ),
                      leading: IconButton(
                        icon: Image.asset(
                            'assets/images/exit.png'), // Ganti dengan path gambar Anda
                        onPressed: () async {
                          // Menampilkan dialog konfirmasi logout
                          bool? shouldLogout =
                              await _showLogoutConfirmationDialog(context);
                          if (shouldLogout == true) {
                            // Melakukan logout jika pengguna mengonfirmasi
                            FirebaseAuth.instance.signOut();
                            context.go('/login');
                          }
                        },
                      ),
                    ),
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
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator(
                              color: Colors.white);
                        } else if (snapshot.hasError || !snapshot.hasData) {
                          return const Text(
                            'Hi, User',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'NeonLight', // Gunakan font NeonLight
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
                              fontFamily: 'NeonLight', // Gunakan font NeonLight
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
                        print("Quiz Button Pressed");
                      },
                    ),
                    const SizedBox(height: 16),
                    // Tombol Leaderboard
                    ElevatedButton(
                      onPressed: () {
                        context.goNamed(Routes.leaderBoard);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.black, // Mengubah background menjadi hitam
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32.0, vertical: 16.0),
                        shadowColor: Colors.white, // Menambahkan bayangan putih
                        elevation: 5, // Menambahkan efek bayangan
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize
                            .min, // Agar ukuran tombol mengikuti konten
                        children: [
                          Image.asset(
                            'assets/images/medal.png', // Gambar medali
                            width: 24, // Ukuran gambar medali
                            height: 24,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(
                              width: 8), // Spasi antara gambar dan teks
                          const Text(
                            'LEADERBOARD',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // Teks berwarna putih
                              fontFamily: 'NeonLight', // Gunakan font NeonLight
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk menampilkan dialog konfirmasi logout
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
                Navigator.of(context).pop(false); // Menutup dialog tanpa logout
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Menutup dialog dan logout
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
