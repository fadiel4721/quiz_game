import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:pm1_task_management/bloc/profile/profile_bloc.dart';
import 'package:pm1_task_management/routes/router_name.dart';

class SmartBuilding extends StatelessWidget {
   SmartBuilding({super.key});

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
            const Text(
              'Hi, Fadiel Muhammad',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            GestureDetector(
              onTap: () {
                context
                    .read<ProfileBloc>()
                    .add(ProfileEventGet(auth.currentUser!.uid));
                context.goNamed(Routes.profile);
              },
              child: const CircleAvatar(
                backgroundImage: AssetImage('assets/images/profile.jpg'),
                radius: 20,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDeviceCard(
                  icon: Icons.door_front_door,
                  title: 'Smart Door',
                  subtitle: 'Pintu jati tebel banget',
                  room: '304',
                  context: context,
                  deviceType: 'door',
                ),
                _buildDeviceCard(
                  icon: Icons.ac_unit,
                  title: 'Smart AC',
                  subtitle: 'Midea MSAF-05CRN2',
                  room: '304',
                  context: context,
                  deviceType: 'ac',
                ),
              ],
            ),
            const SizedBox(height: 70),
            const Text(
              'Berita Terkini',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            ImageSlideshow(
              width: double.infinity,
              height: 200,
              initialPage: 0,
              indicatorColor: Colors.blue,
              indicatorBackgroundColor: Colors.grey,
              onPageChanged: (value) {},
              autoPlayInterval: 3000,
              isLoop: true,
              children: [
                _buildImageWithCaption('assets/images/gold.jpg',
                    'Prodi Teknologi Informasi Borong Medali Kejuaraan Internasional'),
                _buildImageWithCaption('assets/images/silver.jpg',
                    'Prodi Teknologi Informasi Borong Medali Kejuaraan Internasional'),
                _buildImageWithCaption('assets/images/bronze.jpg',
                    'Prodi Teknologi Informasi Borong Medali Kejuaraan Internasional'),
              ],
            ),
            const SizedBox(height: 20), // Jarak setelah image slider
            Center(
              child: IconButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  context.go('/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                ),
                icon: const Icon(Icons.logout),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildImageWithCaption(String imagePath, String caption) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        ),
        Positioned(
          bottom: 10,
          left: 10,
          right: 10,
          child: Container(
            color: Colors.black54,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              caption,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildDeviceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String room,
    required BuildContext context,
    required String deviceType,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        width: 179,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF3A3EBE),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: Colors.white),
                    const SizedBox(height: 4),
                    Text(
                      room,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: LiteRollingSwitch(
                        value: false,
                        textOn: 'On',
                        textOff: 'Off',
                        colorOn: Colors.greenAccent[700] ?? Colors.green,
                        colorOff: Colors.redAccent[700] ?? Colors.red,
                        iconOn: Icons.done,
                        iconOff: Icons.power_settings_new,
                        textSize: 12.0,
                        onChanged: (bool state) {
                          print('sekarang: $state');
                          if (state) {
                            _showDeviceActionDialog(context, deviceType);
                          }
                        },
                        onTap: () {},
                        onDoubleTap: () {},
                        onSwipe: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _showDeviceActionDialog(BuildContext context, String deviceType) {
    String message =
        deviceType == 'door' ? 'Pintu Sudah Terbuka!' : 'AC Sudah Dinyalakan!';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(seconds: 1),
                child: Icon(
                  deviceType == 'door' ? Icons.door_front_door : Icons.ac_unit,
                  key: ValueKey(deviceType),
                  size: 100,
                  color: Colors.yellow,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Tutup'),
              ),
            ],
          ),
        );
      },
    );
  }
}
