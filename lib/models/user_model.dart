import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String username;
  final Timestamp createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.createdAt,
  });

  // Create UserModel from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      username: data['username'] ?? 'Unknown',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'username': username,
      'createdAt': createdAt,
    };
  }
}
