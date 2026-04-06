import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String nom;
  final String email;
  final String role;
  final String photoUrl;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.nom,
    required this.email,
    required this.role,
    required this.photoUrl,
    this.createdAt,
  });

  bool get isAdmin => role == 'admin'; // ← Propriété importante

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: data['uid'] ?? '',
      nom: data['nom'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
      photoUrl: data['photoUrl'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'nom': nom,
      'email': email,
      'role': role,
      'photoUrl': photoUrl,
      'createdAt': createdAt,
    };
  }
}
