import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart'; // Tambahkan paket lottie
import 'package:firebase_auth/firebase_auth.dart'; // Contoh untuk autentikasi Firebase

class ResultPage extends StatelessWidget {
  final Map<String, int> scores;

  const ResultPage({Key? key, required this.scores}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ambil nama pengguna dari Firebase Auth (contoh)
    final user = FirebaseAuth.instance.currentUser;
    final userName = user != null ? user.displayName ?? 'Pengguna' : 'Pengguna';

    return Scaffold(
      body: Stack(
        children: [
          // Background SVG
          SvgPicture.asset(
            "assets/svg/bg.svg",
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title Container
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '🎉 Hasil Kuis 🎉',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'NeonLight',
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Berikut adalah skor yang kamu peroleh:',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'NeonLight',
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Scores List
                  Expanded(
                    child: ListView.builder(
                      itemCount: scores.entries.length,
                      itemBuilder: (context, index) {
                        final entry = scores.entries.elementAt(index);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12.0),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Skor: ',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  fontFamily: 'NeonLight',
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      color: Colors.orangeAccent),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${entry.value}', // Menampilkan skor
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontFamily: 'NeonLight',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Menambahkan teks "Selamat" di atas GIF
                  Text(
                    'Selamat, $userName! Kamu berhasil menyelesaikan kuis ini.',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'NeonLight',
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Lottie Animation (diperbesar)
                  Container(
                    alignment: Alignment.center,
                    child: Lottie.asset(
                      'assets/gif/winner.json', // Path ke file Lottie
                      width: 400, // Ukuran GIF diperbesar
                      height: 380, // Ukuran GIF diperbesar
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Button to go back
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF001F3F), // Warna tombol
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 10,
                      shadowColor: Colors.white.withOpacity(0.5),
                      side: const BorderSide(
                        color: Colors.white, // Garis putih di sekitar tombol
                        width: 2,
                      ),
                    ),
                    child: const Text(
                      'Kembali ke Beranda',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'NeonLight',
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
}
