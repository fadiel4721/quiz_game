import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LeaderboardPage extends StatelessWidget {
  LeaderboardPage({super.key});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchLeaderboardData() async {
    try {
      final matchesSnapshot = await _firestore.collection('matches').get();
      List<Map<String, dynamic>> leaderboard = [];

      // Proses setiap match
      for (var match in matchesSnapshot.docs) {
        var matchId = match.id;
        var matchData = match.data();
        var participants = List<String>.from(matchData['participants'] ?? []); // List of userId (UID)
        var scores = Map<String, dynamic>.from(matchData['scores'] ?? {}); // Scores per UID
        var categoryUid = matchData['categoryUid']; // Ambil categoryUid dari match
        var duration = matchData['duration'] ?? 0; // Ambil durasi dari match

        // Debugging: Cek isi participants dan scores
        print("Processing match: $matchId");
        print("Participants: $participants");
        print("Scores: $scores");

        // Ambil nama kategori berdasarkan categoryUid
        String categoryName = '';
        if (categoryUid != null) {
          var categoryDoc = await _firestore.collection('categories').doc(categoryUid).get();
          if (categoryDoc.exists) {
            categoryName = categoryDoc.data()?['name'] ?? 'Unknown Category';
          }
        }

        // Proses setiap participant berdasarkan UID
        for (String uid in participants) {
          // Ambil data dari subkoleksi `users` dalam dokumen `matches`
          var userDoc = await _firestore
              .collection('matches')
              .doc(matchId)
              .collection('users')
              .doc(uid)
              .get();

          if (userDoc.exists) {
            var userData = userDoc.data()!;
            var name = userData['name'] ?? 'Unknown';
            var photoUrl = userData['photoUrl'] ?? '';
            var score = scores[uid] ?? 0;

            // Cek apakah user sudah ada di leaderboard dan update jika skornya lebih tinggi
            var existingUser = leaderboard.firstWhere(
              (entry) => entry['uid'] == uid,
              orElse: () => {}, // Return an empty map if not found
            );

            if (existingUser.isNotEmpty) {
              // Debugging: Cek skor sebelumnya
              print("Existing user found: ${existingUser['name']} with score: ${existingUser['score']}");
              if ((existingUser['score'] ?? 0) < score) {
                existingUser['score'] = score; // Update score jika lebih tinggi
                existingUser['duration'] = duration; // Update durasi jika skor lebih tinggi
              } else if ((existingUser['score'] ?? 0) == score) {
                // Jika skor sama, bandingkan durasi
                if ((existingUser['duration'] ?? 0) > duration) {
                  existingUser['duration'] = duration; // Update durasi jika lebih rendah
                }
              }
            } else {
              // Jika user belum ada, tambahkan ke leaderboard
              leaderboard.add({
                'uid': uid,
                'name': name,
                'photoUrl': photoUrl,
                'score': score,
                'categoryName': categoryName, // Tambahkan nama kategori
                'duration': duration, // Tambahkan durasi
              });
            }
          } else {
            // Debugging: Jika user tidak ditemukan di subkoleksi
            print("User not found in subcollection for UID: $uid");
          }
        }
      }

      // Urutkan leaderboard berdasarkan skor, lalu durasi
      leaderboard.sort((a, b) {
        if ((b['score'] ?? 0) != (a['score'] ?? 0)) {
          return (b['score'] ?? 0).compareTo(a['score'] ?? 0); // Urutkan berdasarkan skor
        }
        return (a['duration'] ?? 0).compareTo(b['duration'] ?? 0); // Jika skor sama, urutkan berdasarkan durasi
      });

      return leaderboard;
    } catch (e) {
      print("Error fetching leaderboard data: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchLeaderboardData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text("Error loading leaderboard or no data available"),
              );
            }

            final leaderboard = snapshot.data!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header dengan teks "Leaderboard Solo Players"
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'Leaderboard Solo Quiz Game',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.orangeAccent,
                    ),
                  ),
                ),
                // Daftar leaderboard
                Expanded(
                  child: ListView.builder(
                    itemCount: leaderboard.length,
                    itemBuilder: (context, index) {
                      final user = leaderboard[index];

                      // Menambahkan medali untuk 3 teratas
                      String medal = '';
                      if (index == 0) {
                        medal = 'Gold'; // Medali Emas
                      } else if (index == 1) {
                        medal = 'Silver'; // Medali Perak
                      } else if (index == 2) {
                        medal = 'Bronze'; // Medali Perunggu
                      }

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundImage: user['photoUrl'].isNotEmpty
                                ? NetworkImage(user['photoUrl'])
                                : const AssetImage('assets/images/default_profile.jpg')
                                    as ImageProvider,
                          ),
                          title: Text(
                            user['name'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user['categoryName'], // Menampilkan nama kategori
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.orangeAccent,
                                ),
                              ),
                              Text(
                                "Duration: ${user['duration']} seconds", // Menampilkan durasi
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          trailing: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (medal == 'Gold')
                                const Icon(Icons.star, color: Colors.amber, size: 28)
                              else if (medal == 'Silver')
                                const Icon(Icons.star, color: Colors.grey, size: 28)
                              else if (medal == 'Bronze')
                                const Icon(Icons.star, color: Colors.orange, size: 28),
                              Text(
                                "${user['score']} Points",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}