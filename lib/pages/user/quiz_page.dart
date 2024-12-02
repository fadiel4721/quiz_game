import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pm1_task_management/models/category_model.dart';
import 'package:pm1_task_management/pages/user/question_page.dart';

class QuizPage extends StatelessWidget {
  const QuizPage({Key? key}) : super(key: key);

  // Fungsi untuk mencari pertandingan yang sudah ada berdasarkan kategori
  Future<String?> findExistingMatch(String categoryUid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('matches')
        .where('categoryUid', isEqualTo: categoryUid)
        .where('isActive', isEqualTo: true) // Pastikan pertandingan aktif
        .get();

    if (snapshot.docs.isNotEmpty) {
      // Jika ada pertandingan yang aktif, kembalikan matchId-nya
      return snapshot.docs.first.id;
    }

    // Jika tidak ada pertandingan yang aktif, kembalikan null
    return null;
  }

  Future<List<CategoryModel>> fetchCategories() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('categories').get();

    return snapshot.docs
        .map((doc) => CategoryModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  // Fungsi untuk memperbarui subkoleksi `users` pada setiap dokumen `matches`
  Future<void> updateUsersSubcollections(String matchId) async {
    final firestore = FirebaseFirestore.instance;

    try {
      // Ambil dokumen match berdasarkan matchId
      final matchDoc = await firestore.collection('matches').doc(matchId).get();

      if (!matchDoc.exists) return;

      final matchData = matchDoc.data()!;
      final participants = List<String>.from(matchData['participants'] ?? []);

      for (String uid in participants) {
        // Ambil data user dari koleksi `users` berdasarkan uid
        final userDoc = await firestore.collection('users').doc(uid).get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;
          final name = userData['name'] ?? 'Unknown';
          final photoUrl = userData['photoUrl'] ?? '';

          // Tambahkan data user ke subkoleksi `users` di dokumen `matches`
          await firestore
              .collection('matches')
              .doc(matchId)
              .collection('users')
              .doc(uid)
              .set({
            'name': name,
            'photoUrl': photoUrl,
          });
        }
      }
    } catch (e) {
      print("Error saat memperbarui subkoleksi 'users': $e");
    }
  }

  // Fungsi untuk memperbarui subkoleksi `categories` pada setiap dokumen `matches`
  Future<void> updateCategoriesSubcollection(String matchId, String categoryUid) async {
    final firestore = FirebaseFirestore.instance;

    try {
      // Ambil data kategori berdasarkan categoryUid
      final categoryDoc = await firestore.collection('categories').doc(categoryUid).get();

      if (!categoryDoc.exists) return;

      final categoryData = categoryDoc.data()!;
      final categoryName = categoryData['name'] ?? 'Unknown Category'; // Ambil nama kategori

      // Tambahkan data kategori ke subkoleksi `categories` di dokumen `matches`
      await firestore
          .collection('matches')
          .doc(matchId)
          .collection('categories')
          .doc(categoryUid) // Gunakan categoryUid sebagai ID dokumen
          .set({
        'name': categoryName, // Simpan nama kategori
      });
    } catch (e) {
      print("Error saat memperbarui subkoleksi 'categories': $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Kategori'),
      ),
      body: FutureBuilder<List<CategoryModel>>(
        future: fetchCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final categories = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return GestureDetector(
                onTap: () async {
                  // Ambil userId dari Firebase Auth
                  String userId = FirebaseAuth.instance.currentUser?.uid ?? 'defaultUserId';

                  if (userId == 'defaultUserId') {
                    // Arahkan pengguna ke halaman login jika userId tidak ditemukan
                    Navigator.pushReplacementNamed(context, '/login');
                    return;
                  }

                  try {
                    // Cek apakah sudah ada match yang aktif dengan kategori ini
                    String? existingMatchId = await findExistingMatch(category.uid);

                    if (existingMatchId != null) {
                      // Perbarui subkoleksi `users` pada match yang ada
                      await updateUsersSubcollections(existingMatchId);
                      // Perbarui subkoleksi `categories` pada match yang ada
                      await updateCategoriesSubcollection(existingMatchId, category.uid);

                      // Jika ada pertandingan yang sudah ada, gunakan pertandingan tersebut
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuestionsPage(
                            categoryUid: category.uid,
                            matchId: existingMatchId,
                            userId: userId,
                          ),
                        ),
                      );
                    } else {
                      // Jika tidak ada pertandingan aktif, buat pertandingan baru dengan tipe "single"
                      String matchId = await createMatch(category.uid, userId);

                      // Perbarui subkoleksi `users` pada match baru
                      await updateUsersSubcollections(matchId);
                      // Perbarui subkoleksi `categories` pada match baru
                      await updateCategoriesSubcollection(matchId, category.uid);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuestionsPage(
                            categoryUid: category.uid,
                            matchId: matchId,
                            userId: userId,
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    // Tangani jika tidak dapat membuat atau memperbarui matchId
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3), // posisi bayangan
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.category,
                        size: 50,
                        color: Colors.blueAccent,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        category.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.blueAccent,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Fungsi untuk membuat pertandingan baru dan mendapatkan matchId
  Future<String> createMatch(String categoryUid, String userId) async {
    final matchRef = FirebaseFirestore.instance.collection('matches').doc();

    await matchRef.set({
      'categoryUid': categoryUid,
      'isActive': true,
      'scores': {userId: 0}, // Inisialisasi skor dengan userId
      'participants': [userId], // Gunakan userId untuk participants
      'startTime': FieldValue.serverTimestamp(),
      'type': 'single', // Tetapkan tipe sebagai "single"
    });

    return matchRef.id;
  }
}
