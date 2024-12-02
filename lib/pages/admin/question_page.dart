import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pm1_task_management/bloc/question/question_bloc.dart';
import 'package:pm1_task_management/bloc/question/question_event.dart';
import 'package:pm1_task_management/bloc/question/question_state.dart';
import 'package:pm1_task_management/models/question_model.dart';
import 'package:pm1_task_management/routes/router_name.dart';

class QuestionPage extends StatelessWidget {
  const QuestionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuestionBloc()..add(FetchQuestions()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manage Questions'),
        ),
        body: BlocBuilder<QuestionBloc, QuestionState>(
          builder: (context, state) {
            if (state is QuestionLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is QuestionLoaded) {
              final questions = state.questions;

              if (questions.isEmpty) {
                return const Center(child: Text('No questions available.'));
              }

              return ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final question = questions[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    elevation: 5,
                    child: ListTile(
                      title: Text(question.questionText),
                      subtitle: Text('Category UID: ${question.categoryUid}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              context.goNamed(
                                'editQuestion', 
                                extra: question, 
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              context.read<QuestionBloc>().add(DeleteQuestion(question.id));
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else if (state is QuestionError) {
              return Center(child: Text(state.message));
            } else {
              return const SizedBox();
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            context.goNamed('addQuestion');
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
