// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:pm1_task_management/bloc/leaderboard/leaderboard_event.dart';
// import 'package:pm1_task_management/bloc/leaderboard/leaderboard_state.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:pm1_task_management/models/match_model.dart';
// import 'package:pm1_task_management/models/user_model.dart';

// class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   LeaderboardBloc() : super(LeaderboardInitial());

//   @override
//   Stream<LeaderboardState> mapEventToState(LeaderboardEvent event) async* {
//     if (event is FetchLeaderboard) {
//       yield LeaderboardLoading(); // Emit loading state

//       try {
//         final leaderboard = await _fetchLeaderboardData();
//         yield LeaderboardLoaded(leaderboard); // Emit loaded state
//       } catch (e) {
//         yield LeaderboardError('Error fetching leaderboard data: $e'); // Emit error state
//       }
//     }
//   }

//   // Fetch leaderboard data from Firestore
//   Future<List<Map<String, dynamic>>> _fetchLeaderboardData() async {
//     try {
//       final matchesSnapshot = await _firestore.collection('matches').get();
//       List<Map<String, dynamic>> leaderboard = [];

//       for (var match in matchesSnapshot.docs) {
//         final matchData = match.data();
//         final matchModel = MatchModel.fromFirestore(matchData, match.id);
//         final participants = matchModel.scores;

//         for (var entry in participants.entries) {
//           final uid = entry.key;
//           final score = entry.value;

//           final userSnapshot = await _firestore.collection('users').doc(uid).get();

//           if (userSnapshot.exists) {
//             final userData = userSnapshot.data()!;
//             final userModel = UserModel.fromJson(userData);
//             final name = userModel.name ?? 'Unknown';
//             final photoUrl = userModel.photoUrl ?? '';

//             leaderboard.add({
//               'name': name,
//               'photoUrl': photoUrl,
//               'score': score,
//             });
//           }
//         }
//       }

//       leaderboard.sort((a, b) => b['score'].compareTo(a['score']));
//       return leaderboard;
//     } catch (e) {
//       throw Exception('Error fetching leaderboard data: $e');
//     }
//   }
// }
