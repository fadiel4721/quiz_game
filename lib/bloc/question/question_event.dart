import 'package:pm1_task_management/models/question_model.dart';

abstract class QuestionEvent {}

class FetchQuestions extends QuestionEvent {}

class AddQuestion extends QuestionEvent {
  final QuestionModel question;

  AddQuestion(this.question);
}

class EditQuestion extends QuestionEvent {
  final QuestionModel updatedQuestion;

  EditQuestion(this.updatedQuestion);
}

class DeleteQuestion extends QuestionEvent {
  final String questionId;

  DeleteQuestion(this.questionId);
}
