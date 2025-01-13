import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pm1_task_management/bloc/profile/profile_bloc.dart';
import 'package:pm1_task_management/routes/router_name.dart';

class AdminDashboard extends StatelessWidget {
  AdminDashboard({super.key});

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
                context.goNamed(Routes.adminprofile);
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
                    var userData = snapshot.data?.data() as Map<String, dynamic>;
                    String? photoUrl = userData['photoUrl'];
                    return CircleAvatar(
                      backgroundImage: photoUrl != null
                          ? NetworkImage(photoUrl)
                          : const AssetImage('assets/images/default_profile.jpg')
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCategoryCard(context),
                _buildQuestionCard(context),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  context.go('/login');
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk Kategori
  static Widget _buildCategoryCard(BuildContext context) {
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
            const Icon(
              Icons.category,
              color: Colors.white,
              size: 30,
            ),
            const SizedBox(height: 10),
            const Text(
              'Buat Category',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Text(
              'Manage Categories',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                debugPrint('Navigating to: ${Routes.categoryPage}');
                context.goNamed(Routes.categoryPage);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              child: const Text('Manage'),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk Pertanyaan
  static Widget _buildQuestionCard(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        width: 179,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFBE3A3E),
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
            const Icon(
              Icons.question_answer,
              color: Colors.white,
              size: 30,
            ),
            const SizedBox(height: 10),
            const Text(
              'Buat Question',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Text(
              'Manage Questions',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                debugPrint('Navigating to: ${Routes.questionPage}');
                context.goNamed(Routes.questionPage);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: const Text('Manage'),
            ),
          ],
        ),
      ),
    );
  }
}
