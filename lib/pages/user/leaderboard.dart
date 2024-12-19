import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardPage extends StatelessWidget {
  LeaderboardPage({super.key});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchLeaderboardData() async {
    try {
      final matchesSnapshot = await _firestore.collection('matches').get();
      List<Map<String, dynamic>> leaderboard = [];

      for (var match in matchesSnapshot.docs) {
        var matchId = match.id;
        var matchData = match.data();
        var participants = List<String>.from(matchData['participants'] ?? []);
        var scores = Map<String, dynamic>.from(matchData['scores'] ?? {});
        var categoryUid = matchData['categoryUid'];
        var duration = matchData['duration'] ?? 0;

        String categoryName = '';
        if (categoryUid != null) {
          var categoryDoc = await _firestore.collection('categories').doc(categoryUid).get();
          if (categoryDoc.exists) {
            categoryName = categoryDoc.data()?['name'] ?? 'Unknown Category';
          }
        }

        for (String uid in participants) {
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

            var existingUser = leaderboard.firstWhere(
              (entry) => entry['uid'] == uid,
              orElse: () => {},
            );

            if (existingUser.isNotEmpty) {
              if ((existingUser['score'] ?? 0) < score) {
                existingUser['score'] = score;
                existingUser['duration'] = duration;
              } else if ((existingUser['score'] ?? 0) == score) {
                if ((existingUser['duration'] ?? 0) > duration) {
                  existingUser['duration'] = duration;
                }
              }
            } else {
              leaderboard.add({
                'uid': uid,
                'name': name,
                'photoUrl': photoUrl,
                'score': score,
                'categoryName': categoryName,
                'duration': duration,
              });
            }
          }
        }
      }

      leaderboard.sort((a, b) {
        if ((b['score'] ?? 0) != (a['score'] ?? 0)) {
          return (b['score'] ?? 0).compareTo(a['score'] ?? 0);
        }
        return (a['duration'] ?? 0).compareTo(b['duration'] ?? 0);
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
      body: Stack(
        children: [
          // Background menggunakan SVG
          Positioned.fill(
            child: SvgPicture.asset(
              "assets/svg/bg.svg",
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchLeaderboardData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        "Error loading leaderboard or no data available",
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  final leaderboard = snapshot.data!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Leaderboard
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text(
                            'Leaderboard Solo Quiz Game',
                            style: const TextStyle(
                              fontSize: 24,
                              fontFamily: 'NeonLight',
                              fontWeight: FontWeight.bold,
                              color: Colors.orangeAccent,
                            ),
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
                              medal = 'Gold';
                            } else if (index == 1) {
                              medal = 'Silver';
                            } else if (index == 2) {
                              medal = 'Bronze';
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
                                      user['categoryName'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.orangeAccent,
                                      ),
                                    ),
                                    Text(
                                      "Duration: ${user['duration']} seconds",
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
          ),
        ],
      ),
    );
  }
}
