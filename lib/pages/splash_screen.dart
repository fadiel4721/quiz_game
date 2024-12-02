import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Menunda navigasi ke halaman login setelah animasi selesai
    Future.delayed(const Duration(seconds: 3), () {
      context.go('/login'); // Navigasi ke halaman login
    });

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background SVG
          SvgPicture.asset(
            "assets/svg/bg.svg",
            fit: BoxFit.fitWidth,
          ),
          Center(
            child: Lottie.asset(
              'assets/gif/Splash_Screen.json', // Animasi Lottie
              repeat: false, // Animasi hanya diputar sekali
            ),
          ),
        ],
      ),
    );
  }
}
