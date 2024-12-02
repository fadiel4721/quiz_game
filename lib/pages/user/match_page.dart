// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:pm1_task_management/bloc/match/match_bloc.dart';
// import 'package:pm1_task_management/bloc/match/match_event.dart';
// import 'package:pm1_task_management/bloc/match/match_state.dart';


// class MatchPage extends StatelessWidget {
//   final String matchId; // ID Match dari database
//   final bool isSingle; // Single atau Double

//   const MatchPage({
//     Key? key,
//     required this.matchId,
//     required this.isSingle,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) =>
//           MatchBloc(firestore: FirebaseFirestore.instance)..add(StartMatchEvent(matchId)),
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text(isSingle ? "Single Match" : "Double Match"),
//           backgroundColor: Colors.blue,
//         ),
//         body: BlocBuilder<MatchBloc, MatchState>(
//           builder: (context, state) {
//             if (state is MatchInitial) {
//               return const Center(
//                 child: CircularProgressIndicator(),
//               );
//             } else if (state is MatchInProgress) {
//               return isSingle
//                   ? _buildSingleMatchUI(context, state)
//                   : _buildDoubleMatchUI(context, state);
//             } else if (state is MatchCompleted) {
//               return _buildMatchCompletedUI(context, state);
//             } else if (state is MatchFailure) {
//               return Center(
//                 child: Text("Error: ${state.errorMessage}"),
//               );
//             }
//             return const SizedBox();
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildSingleMatchUI(BuildContext context, MatchInProgress state) {
//     // UI untuk single match
//     return Center(
//       child: ElevatedButton(
//         onPressed: () {
//           Navigator.pushNamed(context, '/quiz', arguments: {'matchId': matchId});
//         },
//         child: const Text("Main"),
//       ),
//     );
//   }

//   Widget _buildDoubleMatchUI(BuildContext context, MatchInProgress state) {
//     // UI untuk double match
//     return Column(
//       children: [
//         const SizedBox(height: 20),
//         const Text(
//           "Players",
//           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//         ),
//         Expanded(
//           child: ListView(
//             children: state.scores.entries
//                 .map((entry) => ListTile(
//                       title: Text("User: ${entry.key}"),
//                       trailing: Text("Score: ${entry.value}"),
//                     ))
//                 .toList(),
//           ),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             context.read<MatchBloc>().add(EndMatchEvent(matchId));
//           },
//           child: const Text("End Match"),
//         ),
//       ],
//     );
//   }

//   Widget _buildMatchCompletedUI(BuildContext context, MatchCompleted state) {
//     // UI ketika match selesai
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         const Text(
//           "Match Completed",
//           style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 16),
//         ...state.finalScores.entries.map((entry) => ListTile(
//               title: Text("User: ${entry.key}"),
//               trailing: Text("Final Score: ${entry.value}"),
//             )),
//         const SizedBox(height: 16),
//         ElevatedButton(
//           onPressed: () {
//             Navigator.pop(context);
//           },
//           child: const Text("Back to Dashboard"),
//         ),
//       ],
//     );
//   }
// }
