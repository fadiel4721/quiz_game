import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm1_task_management/bloc/question/question_bloc.dart';
import 'package:pm1_task_management/bloc/question/question_event.dart';
import 'package:pm1_task_management/models/question_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditQuestionPage extends StatefulWidget {
  final QuestionModel question;

  const EditQuestionPage({super.key, required this.question});

  @override
  _EditQuestionPageState createState() => _EditQuestionPageState();
}

class _EditQuestionPageState extends State<EditQuestionPage> {
  final _formKey = GlobalKey<FormState>();
  late String questionText;
  late String answer;
  late List<String> options;
  late String selectedCategoryUid;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> categories = [];

  @override
  void initState() {
    super.initState();
    questionText = widget.question.questionText;
    answer = widget.question.answer;
    
    // Ensure options always has 3 items (empty strings if there are fewer than 3 options)
    options = List<String>.from(widget.question.options);
    while (options.length < 3) {
      options.add('');
    }

    selectedCategoryUid = widget.question.categoryUid;
    _fetchCategories();
  }

  void _fetchCategories() async {
    try {
      var snapshot = await _firestore.collection('categories').get();
      setState(() {
        categories = snapshot.docs
            .map((doc) => doc.data()['name'] as String)
            .toList();
      });
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Question'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: questionText,
                decoration: const InputDecoration(labelText: 'Question Text'),
                onSaved: (value) => questionText = value!,
              ),
              TextFormField(
                initialValue: answer,
                decoration: const InputDecoration(labelText: 'Answer'),
                onSaved: (value) => answer = value!,
              ),
              for (int i = 0; i < 3; i++)
                TextFormField(
                  initialValue: options[i],
                  decoration: InputDecoration(labelText: 'Option ${i + 1}'),
                  onSaved: (value) => options[i] = value!,
                ),
              // Ensure the selectedCategoryUid is valid before showing the dropdown
              DropdownButtonFormField<String>(
                value: selectedCategoryUid.isNotEmpty && categories.contains(selectedCategoryUid)
                    ? selectedCategoryUid
                    : null,
                decoration: const InputDecoration(labelText: 'Category'),
                items: categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategoryUid = value!;
                  });
                },
                validator: (value) => value == null ? 'Please select a category.' : null,
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final updatedQuestion = widget.question.copyWith(
                      questionText: questionText,
                      answer: answer,
                      options: options,
                      categoryUid: selectedCategoryUid,
                    );
                    context.read<QuestionBloc>().add(EditQuestion(updatedQuestion));
                    Navigator.pop(context); // Navigate back to QuestionPage
                  }
                },
                child: const Text('Update Question'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
