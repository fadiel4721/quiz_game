class CategoryModel {
  final String id; // Document ID (UID Firebase)
  final String name;
  final String uid; // UID yang sama dengan Firebase UID
  final String imageUrl; // URL gambar kategori

  CategoryModel({
    required this.id,
    required this.name,
    required this.uid,
    required this.imageUrl,
  });

  // Konversi dari Firestore ke model
  factory CategoryModel.fromFirestore(
    Map<String, dynamic> json,
    String documentId,
  ) {
    return CategoryModel(
      id: documentId,
      name: json['name'] ?? '',
      uid: json['uid'] ?? documentId, // Pastikan UID selalu sesuai dengan Firebase
      imageUrl: json['imageUrl'] ?? '', // Ambil URL gambar jika ada
    );
  }

  // Konversi dari model ke Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'uid': uid,
      'imageUrl': imageUrl, // Simpan URL gambar
    };
  }
}
