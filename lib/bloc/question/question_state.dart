import 'package:pm1_task_management/models/question_model.dart';

abstract class QuestionState {}

class QuestionLoading extends QuestionState {}

class QuestionLoaded extends QuestionState {
  final List<QuestionModel> questions;

  QuestionLoaded(this.questions);
}

class QuestionError extends QuestionState {
  final String message;

  QuestionError(this.message);
}
