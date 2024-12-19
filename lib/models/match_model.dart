class MatchModel {
  final String matchId; // matchId tidak nullable lagi, karena harus dihasilkan
  final String?
      roomCode; // roomCode nullable karena hanya diperlukan di mode double
  final String type;
  final List<String> participants;
  final bool isActive;
  final Map<String, int> scores;
  final String? documentId;

  MatchModel({
    required this.matchId, // matchId sekarang required
    this.roomCode, // roomCode tetap nullable
    required this.type,
    required this.participants,
    required this.isActive,
    required this.scores,
    this.documentId,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'matchId': matchId, // matchId disertakan pada data Firestore
      'roomCode': roomCode, // roomCode untuk mode double
      'type': type,
      'participants': participants,
      'isActive': isActive,
      'scores': scores,
    };
  }

  factory MatchModel.fromFirestore(
      Map<String, dynamic> firestoreData, String docId) {
    return MatchModel(
      matchId: firestoreData['matchId'], // matchId disalin dari Firestore
      roomCode: firestoreData['roomCode'], // roomCode disalin jika ada
      type: firestoreData['type'],
      participants: List<String>.from(firestoreData['participants']),
      isActive: firestoreData['isActive'],
      scores: Map<String, int>.from(firestoreData['scores']),
      documentId: docId,
    );
  }

  MatchModel copyWith({
    String? matchId,
    String? roomCode,
    String? type,
    List<String>? participants,
    bool? isActive,
    Map<String, int>? score,
    String? documentId,
  }) {
    return MatchModel(
      matchId: matchId ?? this.matchId,
      roomCode: roomCode ?? this.roomCode,
      type: type ?? this.type,
      participants: participants ?? this.participants,
      isActive: isActive ?? this.isActive,
      scores: scores ?? this.scores,
      documentId: documentId ?? this.documentId,
    );
  }
}
