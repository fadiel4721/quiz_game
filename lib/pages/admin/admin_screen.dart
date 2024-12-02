// // admin_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:pm1_task_management/bloc/admin/admin_bloc.dart';
// import 'package:pm1_task_management/bloc/admin/admin_event.dart';
// import 'package:pm1_task_management/bloc/admin/admin_state.dart';
// import 'package:pm1_task_management/models/question_model.dart';


// class AdminScreen extends StatelessWidget {
//   final String quizCategory;

//   AdminScreen({super.key, required this.quizCategory});

//   final TextEditingController questionContorllerText = TextEditingController();
//   final List<TextEditingController> optionControllers = List.generate(4, (index) => TextEditingController());
//   final TextEditingController correctAnswerController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Add Question to $quizCategory"),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(10),
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: questionContorllerText,
//                 decoration: const InputDecoration(labelText: "Question"),
//               ),
//               for (var i = 0; i < 4; i++)
//                 TextFormField(
//                   controller: optionControllers[i],
//                   decoration: InputDecoration(labelText: "Options ${i + 1}"),
//                 ),
//               TextFormField(
//                 controller: correctAnswerController,
//                 decoration: const InputDecoration(labelText: "Correct Answers (0-3)"),
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   if (questionContorllerText.text.isEmpty ||
//                       optionControllers.any((controller) => controller.text.isEmpty) ||
//                       correctAnswerController.text.isEmpty) {
//                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("All fields are required")));
//                   } else {
//                     _addQuestion(context);
//                   }
//                 },
//                 child: const Text("Add Question"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _addQuestion(BuildContext context) {
//   // Generate a unique id for the question
//   // You might want to fetch the current highest id from saved data to ensure uniqueness
//   final id = DateTime.now().millisecondsSinceEpoch;  // Example of generating a unique id

//   final question = Question(
//     id: id,  // Assigning the generated id
//     category: quizCategory,
//     questions: questionContorllerText.text,
//     options: optionControllers.map((controller) => controller.text).toList(),
//     answer: int.parse(correctAnswerController.text),  // Parse the correct answer
//   );

//   context.read<AdminBloc>().add(SaveQuestion(question));
// }

// }
