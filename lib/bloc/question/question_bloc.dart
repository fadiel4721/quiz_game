import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pm1_task_management/models/question_model.dart';
import 'package:pm1_task_management/bloc/question/question_event.dart';
import 'package:pm1_task_management/bloc/question/question_state.dart';

class QuestionBloc extends Bloc<QuestionEvent, QuestionState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  QuestionBloc() : super(QuestionLoading()) {
    on<FetchQuestions>(_onFetchQuestions);
    on<AddQuestion>(_onAddQuestion);
    on<EditQuestion>(_onEditQuestion);
    on<DeleteQuestion>(_onDeleteQuestion);
  }

  // Fetch questions
  Future<void> _onFetchQuestions(
      FetchQuestions event, Emitter<QuestionState> emit) async {
    try {
      emit(QuestionLoading());
      var snapshot = await _firestore.collection('questions').get();
      List<QuestionModel> questions = snapshot.docs
          .map((doc) => QuestionModel.fromFirestore(
                doc.data(),
                doc.id,
              ))
          .toList();
      emit(QuestionLoaded(questions));
    } catch (e) {
      emit(QuestionError("Failed to fetch questions: $e"));
    }
  }

  // Add question
  // Add question
Future<void> _onAddQuestion(
    AddQuestion event, Emitter<QuestionState> emit) async {
  try {
    // Step 1: Tambahkan dokumen ke koleksi questions
    var docRef = await _firestore.collection('questions').add(event.question.toFirestore());

    // Step 2: Perbarui model pertanyaan dengan document ID
    final updatedQuestion = event.question.copyWith(
      id: docRef.id,
      uid: docRef.id,
    );

    // Step 3: Perbarui Firestore dengan model yang diperbarui
    await _firestore
        .collection('questions')
        .doc(docRef.id)
        .set(updatedQuestion.toFirestore());

    // Step 4: Ambil nama kategori dari collection categories
    var categorySnapshot = await _firestore
        .collection('categories')
        .doc(event.question.categoryUid)
        .get();

    if (categorySnapshot.exists) {
      // Step 5: Ambil nama kategori dan tambahkan ke subkoleksi categories
      final categoryName = categorySnapshot.data()?['name'] ?? 'Unknown';
      await _firestore
          .collection('questions')
          .doc(docRef.id)
          .collection('categories')
          .add({'name': categoryName});
    }

    // Emit state loading, lalu refresh daftar pertanyaan
    emit(QuestionLoading());
    add(FetchQuestions());
  } catch (e) {
    emit(QuestionError("Failed to add question: $e"));
  }
}
// Edit question
Future<void> _onEditQuestion(
    EditQuestion event, Emitter<QuestionState> emit) async {
  try {
    // Dapatkan dokumen kategori berdasarkan categoryUid baru
    var categorySnapshot = await _firestore
        .collection('categories')
        .doc(event.updatedQuestion.categoryUid)
        .get();

    if (!categorySnapshot.exists) {
      emit(QuestionError("Category not found for the selected UID."));
      return;
    }

    // Perbarui dokumen utama di Firestore
    await _firestore
        .collection('questions')
        .doc(event.updatedQuestion.id)
        .update(event.updatedQuestion.toFirestore());

    // Perbarui subkoleksi 'categories' di dokumen 'questions'
    await _firestore
        .collection('questions')
        .doc(event.updatedQuestion.id)
        .collection('categories')
        .doc('categoryDetails') // Gunakan ID tetap untuk overwrite
        .set({
      'name': categorySnapshot['name'],
    });

    // Emit state loading, lalu refresh daftar pertanyaan
    emit(QuestionLoading());
    add(FetchQuestions());
  } catch (e) {
    emit(QuestionError("Failed to update question: $e"));
  }
}
 // Delete question
Future<void> _onDeleteQuestion(
    DeleteQuestion event, Emitter<QuestionState> emit) async {
  try {
    // Hapus subkoleksi 'categories' terlebih dahulu
    var subCollection = _firestore
        .collection('questions')
        .doc(event.questionId)
        .collection('categories');

    var subDocs = await subCollection.get();
    for (var doc in subDocs.docs) {
      await subCollection.doc(doc.id).delete();
    }

    // Hapus dokumen utama
    await _firestore.collection('questions').doc(event.questionId).delete();

    // Emit state loading, lalu refresh daftar pertanyaan
    emit(QuestionLoading());
    add(FetchQuestions());
  } catch (e) {
    emit(QuestionError("Failed to delete question: $e"));
  }
}

}
