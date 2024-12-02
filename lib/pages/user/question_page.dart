import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm1_task_management/bloc/match/match_bloc.dart';
import 'package:pm1_task_management/bloc/match/match_event.dart';
import 'package:pm1_task_management/bloc/match/match_state.dart';
import 'package:pm1_task_management/pages/user/result_page.dart';
import 'dart:async';

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
  Timer? _timer;
  int _timeLeft = 30; // Waktu per soal dalam detik
  bool _answered = false;
  String? _selectedOption;

  @override
  void initState() {
    super.initState();
    context.read<MatchBloc>().add(LoadQuestionsEvent(categoryUid: widget.categoryUid));
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel(); // Hentikan timer jika ada timer yang sedang berjalan
    _timeLeft = 30; // Reset waktu ke 30 detik hanya pada awal timer
    _answered = false; // Reset status soal apakah sudah dijawab atau belum
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else if (mounted && _timeLeft == 0) {
        timer.cancel();
        _nextQuestion();
      }
    });
  }

  Future<void> _nextQuestion() async {
    if (!mounted) return;
    final currentState = context.read<MatchBloc>().state;
    if (currentState is QuestionsLoaded) {
      if (currentState.currentIndex + 1 < currentState.questions.length) {
        await Future.delayed(const Duration(seconds: 2)); // Delay untuk feedback jawaban
        context.read<MatchBloc>().add(NextQuestionEvent(matchId: widget.matchId));
        print("Pindah ke soal berikutnya.");
      } else {
        context.read<MatchBloc>().add(EndMatchEvent(matchId: widget.matchId));
        print("Soal selesai, pertandingan selesai.");
      }
    }

    if (mounted) {
      setState(() {
        _answered = false; // Reset status jawaban
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soal'),
      ),
      body: BlocConsumer<MatchBloc, MatchState>( 
        listener: (context, state) {
          if (state is MatchCompleted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => ResultPage(scores: state.finalScores),
              ),
            );
          } else if (state is QuestionAnswered) {
            setState(() {
              _answered = true; // Menandai soal telah dijawab
            });

            // Menampilkan Snackbar untuk memberikan feedback
            final isCorrect = state.isCorrect;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isCorrect ? 'Jawaban Benar!' : 'Jawaban Salah!'),
                backgroundColor: isCorrect ? Colors.green : Colors.red,
                duration: Duration(seconds: 1),
              ),
            );

            // Setelah snackbar, langsung lanjut ke soal berikutnya
            Future.delayed(const Duration(seconds: 1), _nextQuestion); // Delay agar snackbar dapat dilihat sebelum berpindah
          }
        },
        builder: (context, state) {
          if (state is MatchLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is QuestionsLoaded) {
            if (state.questions.isEmpty) {
              return const Center(child: Text('Tidak ada soal tersedia.'));
            }

            final question = state.questions[state.currentIndex];
            final currentIndex = state.currentIndex + 1;
            final totalQuestions = state.questions.length;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LinearProgressIndicator(
                    value: _timeLeft / 30,
                    color: Colors.blue,
                    backgroundColor: Colors.grey[300],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Soal $currentIndex dari $totalQuestions',
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    question.questionText,
                    style: const TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ...question.options.map((option) {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // Tidak ada perubahan warna untuk opsi
                      ),
                      onPressed: _answered
                          ? null
                          : () {
                              setState(() {
                                _answered = true;
                                _selectedOption = option; // Simpan jawaban yang dipilih
                              });
                              context.read<MatchBloc>().add(
                                    AnswerQuestionEvent(
                                      matchId: widget.matchId,
                                      userId: widget.userId,
                                      selectedAnswer: option,
                                    ),
                                  );
                              print("Jawaban dipilih: $option. Benar: ${option == question.answer}");
                            },
                      child: Text(option),
                    );
                  }).toList(),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _nextQuestion, // Tombol hanya aktif setelah jawaban dipilih
                    child: const Text('Skip'),
                  ),
                ],
              ),
            );
          } else if (state is MatchFailure) {
            return Center(child: Text('Error: ${state.errorMessage}'));
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

