import 'dart:ui';
import 'package:equatable/equatable.dart';
import 'package:pm1_task_management/models/question_model.dart';

abstract class MatchState extends Equatable {
  const MatchState();

  @override
  List<Object?> get props => [];
}

class MatchInitial extends MatchState {}

class MatchInProgress extends MatchState {
  final String matchId;
  final Map<String, int> scores;

  const MatchInProgress({
    required this.matchId,
    required this.scores,
  });

  @override
  List<Object?> get props => [matchId, scores];
}

class MatchLoading extends MatchState {}

class MatchCompleted extends MatchState {
  final String matchId;
  final Map<String, int> finalScores;

  const MatchCompleted({
    required this.matchId,
    required this.finalScores,
  });

  @override
  List<Object?> get props => [matchId, finalScores];
}

class MatchFailure extends MatchState {
  final String errorMessage;

  const MatchFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

class QuestionsLoaded extends MatchState {
  final List<QuestionModel> questions;
  final int currentIndex;
  final Map<String, int> scores;
  final Map<int, Color> answersColors; // Warna untuk setiap soal (index)

  const QuestionsLoaded({
    required this.questions,
    required this.currentIndex,
    required this.scores,
    required this.answersColors,
  });

  @override
  List<Object?> get props => [questions, currentIndex, scores, answersColors];
}


class QuestionAnswered extends MatchState {
  final bool isCorrect;
  final int currentIndex; // Tambahan index untuk state ini
  final int newScore;
  final Color answerColor;

  const QuestionAnswered({
    required this.currentIndex,
    required this.isCorrect,
    required this.newScore,
    required this.answerColor,
  });

  @override
  List<Object?> get props => [isCorrect, newScore, answerColor];
}
