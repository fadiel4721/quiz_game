class ScoreModel {
  final String id; // ID Score
  final String userId; // UID Pemain
  final String matchId; // ID Match
  final int score; // Total Score

  ScoreModel({
    required this.id,
    required this.userId,
    required this.matchId,
    required this.score,
  });

  // Convert Score to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'matchId': matchId,
      'score': score,
    };
  }

  // Convert Firebase data to ScoreModel
  factory ScoreModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ScoreModel(
      id: documentId,
      userId: map['userId'] ?? '',
      matchId: map['matchId'] ?? '',
      score: map['score'] ?? 0,
    );
  }
}
