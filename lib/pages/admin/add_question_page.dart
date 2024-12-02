import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm1_task_management/bloc/question/question_bloc.dart';
import 'package:pm1_task_management/bloc/question/question_event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pm1_task_management/models/question_model.dart';

class AddQuestionPage extends StatefulWidget {
  const AddQuestionPage({super.key});

  @override
  _AddQuestionPageState createState() => _AddQuestionPageState();
}

class _AddQuestionPageState extends State<AddQuestionPage> {
  final _formKey = GlobalKey<FormState>();
  String? questionText;
  String? answer;
  List<String> options = ['', '', ''];
  String? selectedCategoryUid;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, String>> categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  void _fetchCategories() async {
    try {
      var snapshot = await _firestore.collection('categories').get();
      setState(() {
        categories = snapshot.docs
            .map((doc) => {
                  'uid': doc.id,
                  'name': doc.data()['name'] as String,
                })
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
        title: const Text('Add Question'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question Text
              TextFormField(
                decoration: const InputDecoration(labelText: 'Question Text'),
                onSaved: (value) => questionText = value,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a question.' : null,
              ),

              // Answer
              TextFormField(
                decoration: const InputDecoration(labelText: 'Answer'),
                onSaved: (value) => answer = value,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter an answer.' : null,
              ),

              // Options
              for (int i = 0; i < options.length; i++)
                TextFormField(
                  decoration: InputDecoration(labelText: 'Option ${i + 1}'),
                  onSaved: (value) => options[i] = value ?? '',
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter an option.' : null,
                ),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: selectedCategoryUid,
                decoration: const InputDecoration(labelText: 'Category'),
                items: categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category['uid'],
                    child: Text(category['name']!),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategoryUid = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a category.' : null,
              ),

              const SizedBox(height: 16),

              // Add Question Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    // Buat model pertanyaan
                    final question = QuestionModel(
                      id: '', // Akan diisi oleh Firestore document ID
                      questionText: questionText!,
                      answer: answer!,
                      options: options,
                      categoryUid: selectedCategoryUid!,
                      uid: '', // Placeholder UID
                    );

                    // Dispatch event AddQuestion ke Bloc
                    context.read<QuestionBloc>().add(AddQuestion(question));

                    // Kembali ke halaman sebelumnya
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add Question'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
