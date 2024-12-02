// // question_card.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:pm1_task_management/bloc/quiz/quiz_bloc.dart';
// import 'package:pm1_task_management/bloc/quiz/quiz_event.dart';
// import 'package:pm1_task_management/bloc/quiz/quiz_state.dart';
// import 'package:pm1_task_management/models/question_model.dart';
// import 'package:pm1_task_management/utils/constants.dart';


// class QuestionCard extends StatelessWidget {
//   final Question question;
//   const QuestionCard({super.key, required this.question});

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<QuizBloc, QuizState>(
//       builder: (context, state) {
//         return Container(
//           margin: EdgeInsets.symmetric(horizontal: kDefaultPadding),
//           padding: EdgeInsets.all(kDefaultPadding),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(25),
//           ),
//           child: Column(
//             children: [
//               Text(
//                 question.questionText,
//                 style: Theme.of(context)
//                     .textTheme
//                     .titleLarge!
//                     .copyWith(color: kBlackColor),
//               ),
//               const SizedBox(height: kDefaultPadding / 2),
//               ...List.generate(
//                 question.options.length,
//                 (index) => GestureDetector(
//                   onTap: () {
//                     context.read<QuizBloc>().add(SelectAnswer(
//                         selectedIndex: index, selectedAnswer: question.options[index]));
//                   },
//                   child: Container(
//                     margin: EdgeInsets.only(top: kDefaultPadding),
//                     padding: EdgeInsets.all(kDefaultPadding),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey),
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                     child: Text(
//                       "${index + 1}. ${question.options[index]}",
//                       style: TextStyle(
//                         color: Colors.black,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
