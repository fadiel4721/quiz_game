import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm1_task_management/bloc/match/match_bloc.dart';
import 'package:pm1_task_management/bloc/match/match_event.dart';
import 'package:pm1_task_management/bloc/match/match_state.dart';
import 'package:pm1_task_management/pages/user/result_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';

class QuestionsPage extends StatefulWidget {
  final String categoryUid;
  final String matchId;
  final String userId;

  const QuestionsPage({
    Key? key,
    required this.categoryUid,
    required this.matchId,
    required this.userId,
  }) : super(key: key);

  @override
  _QuestionsPageState createState() => _QuestionsPageState();
}

class _QuestionsPageState extends State<QuestionsPage> {
  bool _answered = false;
  String? _selectedOption;
  DateTime? _startTime;
  DateTime? _endTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    context
        .read<MatchBloc>()
        .add(LoadQuestionsEvent(categoryUid: widget.categoryUid));
  }

  Future<void> _updateMatchEndTimeAndDuration() async {
    if (_startTime != null) {
      _endTime = DateTime.now();
      final duration = _endTime!.difference(_startTime!).inSeconds;
      final matchRef =
          FirebaseFirestore.instance.collection('matches').doc(widget.matchId);
      final matchSnapshot = await matchRef.get();
      if (matchSnapshot.exists) {
        await matchRef.update({
          'endTime': _endTime,
          'duration': duration,
          'isActive': false,
        });
        print("Game selesai dengan durasi: $duration detik");
      } else {
        print("Match not found");
      }
    }
  }

  Future<void> _showExitConfirmationDialog() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Keluar Game'),
          content: const Text(
              'Apakah Anda yakin ingin keluar dari permainan? Semua progres akan disimpan.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Tidak'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Ya'),
            ),
          ],
        );
      },
    );

    if (shouldExit == true) {
      await _updateMatchEndTimeAndDuration();
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _nextQuestion() async {
    if (!mounted) return;
    final currentState = context.read<MatchBloc>().state;
    if (currentState is QuestionsLoaded) {
      if (currentState.currentIndex + 1 < currentState.questions.length) {
        await Future.delayed(const Duration(seconds: 2));
        context
            .read<MatchBloc>()
            .add(NextQuestionEvent(matchId: widget.matchId));
        print("Pindah ke soal berikutnya.");
      } else {
        _endTime = DateTime.now();
        context.read<MatchBloc>().add(EndMatchEvent(matchId: widget.matchId));
        await _updateMatchEndTimeAndDuration();
        print("Soal selesai, pertandingan selesai.");
      }
    }

    if (mounted) {
      setState(() {
        _answered = false;
      });
    }
  }

  Future<void> _previousQuestion() async {
    if (!mounted) return;
    final currentState = context.read<MatchBloc>().state;
    if (currentState is QuestionsLoaded) {
      if (currentState.currentIndex > 0) {
        context
            .read<MatchBloc>()
            .add(PreviousQuestionEvent(matchId: widget.matchId));
        print("Kembali ke soal sebelumnya.");
      }
    }

    if (mounted) {
      setState(() {
        _answered = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_answered || _startTime != null) {
          await _showExitConfirmationDialog();
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            SvgPicture.asset(
              "assets/svg/bg.svg",
              fit: BoxFit.cover,
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: BlocConsumer<MatchBloc, MatchState>(
                  listener: (context, state) {
                    if (state is MatchCompleted) {
                      if (mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ResultPage(scores: state.finalScores),
                          ),
                        );
                      }
                    } else if (state is QuestionAnswered) {
                      if (mounted) {
                        setState(() {
                          _answered = true;
                        });

                        final isCorrect = state.isCorrect;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isCorrect
                                ? 'Jawaban Benar!'
                                : 'Jawaban Salah!'),
                            backgroundColor:
                                isCorrect ? Colors.green : Colors.red,
                            duration: const Duration(seconds: 1),
                          ),
                        );

                        Future.delayed(const Duration(seconds: 1), () async {
                          await _nextQuestion();
                        });
                      }
                    }
                  },
                  builder: (context, state) {
                    if (state is MatchLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is QuestionsLoaded) {
                      if (state.questions.isEmpty) {
                        return const Center(
                          child: Text('Tidak ada soal tersedia.'),
                        );
                      }

                      final question = state.questions[state.currentIndex];
                      final currentIndex = state.currentIndex + 1;
                      final totalQuestions = state.questions.length;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Menambahkan teks "Keluar Game" di pojok kiri atas dengan font family
                          Positioned(
                            top: 20,
                            left: 16,
                            child: GestureDetector(
                              onTap:
                                  _showExitConfirmationDialog, // Trigger modal keluar game
                              child: Text(
                                'Keluar',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily:
                                      'NeonLight', // Tambahkan font family
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Soal $currentIndex dari $totalQuestions',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            question.questionText,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 180),
                          ...question.options.map((option) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _answered
                                    ? null
                                    : () {
                                        if (mounted) {
                                          setState(() {
                                            _answered = true;
                                            _selectedOption = option;
                                          });
                                          context.read<MatchBloc>().add(
                                                AnswerQuestionEvent(
                                                  matchId: widget.matchId,
                                                  userId: widget.userId,
                                                  selectedAnswer: option,
                                                ),
                                              );
                                          print("Jawaban dipilih: $option");
                                        }
                                      },
                                child: Text(option,
                                    style: const TextStyle(fontSize: 16)),
                              ),
                            );
                          }).toList(),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: _previousQuestion,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Previous',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                              ),
                              ElevatedButton(
                                onPressed: _nextQuestion,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:const Color(0xFF001F3F) ,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Skip',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      );
                    } else {
                      return const Center(child: Text('Terjadi kesalahan.'));
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
