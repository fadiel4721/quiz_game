class QuestionModel {
  final String id; // Document ID (UID Firebase)
  final String questionText;
  final String answer;
  final List<String> options;
  final String categoryUid; // UID kategori yang terkait
  final String uid; // UID dokumen Firebase

  QuestionModel({
    required this.id,
    required this.questionText,
    required this.answer,
    required this.options,
    required this.categoryUid,
    required this.uid,
  });

  // Konversi dari Firestore ke model
  factory QuestionModel.fromFirestore(
    Map<String, dynamic> json,
    String documentId,
  ) {
    return QuestionModel(
      id: documentId, // Menggunakan documentId sebagai id
      questionText: json['questionText'] ?? '',
      answer: json['answer'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      categoryUid: json['categoryUid'] ?? '',
      uid: json['uid'] ?? documentId, // Jika uid tidak ada, gunakan documentId
    );
  }

  // Konversi dari model ke Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'questionText': questionText,
      'answer': answer,
      'options': options,
      'categoryUid': categoryUid,
      'uid': uid,
    };
  }

  // Tambahkan metode copyWith
  QuestionModel copyWith({
    String? id,
    String? questionText,
    String? answer,
    List<String>? options,
    String? categoryUid,
    String? uid,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      questionText: questionText ?? this.questionText,
      answer: answer ?? this.answer,
      options: options ?? this.options,
      categoryUid: categoryUid ?? this.categoryUid,
      uid: uid ?? this.uid,
    );
  }
}
