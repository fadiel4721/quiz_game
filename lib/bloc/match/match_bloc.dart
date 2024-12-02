import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pm1_task_management/models/question_model.dart';
import 'match_event.dart';
import 'match_state.dart';

class MatchBloc extends Bloc<MatchEvent, MatchState> {
  final FirebaseFirestore firestore;

  MatchBloc({required this.firestore}) : super(MatchInitial()) {
    on<StartMatchEvent>(_onStartMatch);
    on<UpdateScoreEvent>(_onUpdateScore);
    on<EndMatchEvent>(_onEndMatch);
    on<LoadQuestionsEvent>(_onLoadQuestionsEvent);
    on<AnswerQuestionEvent>(_onAnswerQuestionEvent);
    on<NextQuestionEvent>(_onNextQuestionEvent);
  }

  Future<void> _onStartMatch(
    StartMatchEvent event,
    Emitter<MatchState> emit,
  ) async {
    try {
      if (event.matchId.isEmpty) {
        throw Exception("matchId is empty!");
      }
      emit(MatchInProgress(matchId: event.matchId, scores: {}));
    } catch (e) {
      emit(MatchFailure("Failed to start match: ${e.toString()}"));
    }
  }

  Future<void> _onUpdateScore(
    UpdateScoreEvent event,
    Emitter<MatchState> emit,
  ) async {
    if (state is MatchInProgress) {
      try {
        final currentState = state as MatchInProgress;
        final currentScores = Map<String, int>.from(currentState.scores);

        currentScores[event.userId] =
            (currentScores[event.userId] ?? 0) + event.score;

        await firestore
            .collection('matches')
            .doc(event.matchId)
            .update({'scores': currentScores});

        emit(MatchInProgress(matchId: event.matchId, scores: currentScores));
      } catch (e) {
        emit(MatchFailure("Failed to update score: ${e.toString()}"));
      }
    }
  }

  Future<void> _onEndMatch(
    EndMatchEvent event,
    Emitter<MatchState> emit,
  ) async {
    try {
      final matchDoc =
          await firestore.collection('matches').doc(event.matchId).get();

      if (!matchDoc.exists) {
        throw Exception("Match not found for ID: ${event.matchId}");
      }

      final matchData = matchDoc.data() as Map<String, dynamic>;
      final scores = Map<String, int>.from(matchData['scores'] ?? {});

      await firestore
          .collection('matches')
          .doc(event.matchId)
          .update({'isActive': false});

      emit(MatchCompleted(
        matchId: event.matchId,
        finalScores: scores,
      ));
    } catch (e) {
      emit(MatchFailure("Failed to end match: ${e.toString()}"));
    }
  }

 Future<void> _onLoadQuestionsEvent(
  LoadQuestionsEvent event,
  Emitter<MatchState> emit,
) async {
  try {
    final snapshot = await firestore
        .collection('questions')
        .where('categoryUid', isEqualTo: event.categoryUid)
        .get();

    if (snapshot.docs.isEmpty) {
      throw Exception(
          "No questions found for categoryUid: ${event.categoryUid}");
    }

    // Mengubah soal dari snapshot menjadi list
    final questions = snapshot.docs
        .map((doc) => QuestionModel.fromFirestore(doc.data(), doc.id))
        .toList();

    // Mengacak urutan soal menggunakan shuffle()
    questions.shuffle();

    emit(QuestionsLoaded(
      questions: questions,
      currentIndex: 0,
      scores: {},
      answersColors: {},
    ));
  } catch (e) {
    emit(MatchFailure("Failed to load questions: ${e.toString()}"));
  }
}


 Future<void> _onAnswerQuestionEvent(
  AnswerQuestionEvent event,
  Emitter<MatchState> emit,
) async {
  final currentState = state;

  if (currentState is QuestionsLoaded) {
    try {
      final currentQuestion = currentState.questions[currentState.currentIndex];
      final isCorrect = currentQuestion.answer == event.selectedAnswer;

      final newScores = Map<String, int>.from(currentState.scores);
      newScores[event.userId] = (newScores[event.userId] ?? 0) + (isCorrect ? 10 : 0);

      final updatedAnswersColors = Map<int, Color>.from(currentState.answersColors);
      updatedAnswersColors[currentState.currentIndex] = isCorrect ? Colors.green : Colors.red;

      await firestore
          .collection('matches')
          .doc(event.matchId)
          .update({'scores': newScores});

      emit(QuestionAnswered(
        currentIndex: currentState.currentIndex,
        isCorrect: isCorrect,
        newScore: newScores[event.userId] ?? 0,
        answerColor: updatedAnswersColors[currentState.currentIndex]!,
      ));

      emit(QuestionsLoaded(
        questions: currentState.questions,
        currentIndex: currentState.currentIndex,
        scores: newScores,
        answersColors: updatedAnswersColors,
      ));
    } catch (e) {
      emit(MatchFailure("Failed to answer question: ${e.toString()}"));
    }
  }
}
  void _onNextQuestionEvent(
    NextQuestionEvent event,
    Emitter<MatchState> emit,
  ) {
    final currentState = state;

    if (currentState is QuestionsLoaded) {
      if (currentState.currentIndex + 1 < currentState.questions.length) {
        emit(QuestionsLoaded(
          questions: currentState.questions,
          currentIndex: currentState.currentIndex + 1,
          scores: currentState.scores,
          answersColors: currentState.answersColors,
        ));
      } else {
        emit(MatchCompleted(
          matchId: event.matchId,
          finalScores: currentState.scores,
        ));
      }
    }
  }
}
