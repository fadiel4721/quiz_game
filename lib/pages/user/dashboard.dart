import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pm1_task_management/bloc/profile/profile_bloc.dart';
import 'package:pm1_task_management/routes/router_name.dart';
import 'package:pm1_task_management/widgets/pilih_match.dart';

class Dashboard extends StatelessWidget {
  Dashboard({super.key});

  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Ambil nama dari Firestore
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(auth.currentUser?.uid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Text('Error loading name');
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return const Text('Hi, User');
                } else {
                  var userData = snapshot.data?.data() as Map<String, dynamic>;
                  String name = userData['name'] ?? 'User';
                  return Text(
                    'Hi, $name',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  );
                }
              },
            ),
            GestureDetector(
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
          ],
        ),
      ),
      body: SingleChildScrollView( // Tambahkan SingleChildScrollView
        child: Container(
          color: Colors.blue[50], // Warna background yang cocok dengan navbar
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, // Tambahkan ini untuk layout yang responsif
              children: [
                // Gambar dan Judul Game
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // Latar belakang putih di sekitar gambar
                    borderRadius: BorderRadius.circular(
                        16), // Membuat sudut gambar melengkung
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26, // Bayangan lembut
                        blurRadius: 8,
                        offset: Offset(0, 4), // Arah bayangan
                      ),
                    ],
                  ),
                  padding:
                      const EdgeInsets.all(8), // Memberi jarak di dalam container
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(12), // Melengkungkan sudut gambar
                    child: Image.asset(
                      'assets/images/quiz.jpg', // Lokasi gambar
                      height: 200, // Ukuran tinggi gambar
                      width: double.infinity, // Gambar menyesuaikan lebar layar
                      fit: BoxFit
                          .cover, // Gambar mengisi area container secara proporsional
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Game Quiz",
                  textAlign: TextAlign.center, // Tambahkan agar teks rata tengah
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 32),
                PilihMatch(
                  onPressed: () {
                    // Action untuk tombol quiz
                    print("Quiz Button Pressed");
                  },
                ),
                const SizedBox(height: 16), // Jarak antara tombol
                ElevatedButton.icon(
                  onPressed: () {
                    context.goNamed(Routes.leaderBoard);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 12.0),
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  icon: const Icon(Icons.leaderboard, color: Colors.white),
                  label: const Text(
                    "Leaderboard",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 32), // Jarak tambahan untuk responsivitas
                ElevatedButton.icon(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    context.go('/login');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 12.0),
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    "Logout",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
