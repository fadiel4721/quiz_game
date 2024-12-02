import 'package:equatable/equatable.dart';

abstract class MatchEvent extends Equatable {
  const MatchEvent();

  @override
  List<Object?> get props => [];
}

class StartMatchEvent extends MatchEvent {
  final String matchId;

  const StartMatchEvent(this.matchId);

  @override
  List<Object?> get props => [matchId];
}

class UpdateScoreEvent extends MatchEvent {
  final String matchId;
  final String userId;
  final int score;

  const UpdateScoreEvent({
    required this.matchId,
    required this.userId,
    required this.score,
  });

  @override
  List<Object?> get props => [matchId, userId, score];
}

class EndMatchEvent extends MatchEvent {
  final String matchId;

  const EndMatchEvent({required this.matchId});

  @override
  List<Object?> get props => [matchId];
}

class LoadQuestionsEvent extends MatchEvent {
  final String categoryUid;

  const LoadQuestionsEvent({required this.categoryUid});

  @override
  List<Object?> get props => [categoryUid];
}

class AnswerQuestionEvent extends MatchEvent {
  final String matchId;
  final String userId;
  final String selectedAnswer;

  const AnswerQuestionEvent({
    required this.matchId,
    required this.userId,
    required this.selectedAnswer,
  });

  @override
  List<Object?> get props => [matchId, userId, selectedAnswer];
}

class NextQuestionEvent extends MatchEvent {
  final String matchId;

  const NextQuestionEvent({required this.matchId});

  @override
  List<Object?> get props => [matchId];
}
