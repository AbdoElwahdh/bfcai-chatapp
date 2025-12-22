import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String text;
  final Timestamp timestamp;
  final List<String> deletedBy;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.deletedBy,
  });

  // Create MessageModel from Firestore document
  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      text: data['text'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      deletedBy: List<String>.from(data['deletedBy'] ?? []),
    );
  }

  // Convert MessageModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp,
      'deletedBy': deletedBy,
    };
  }

  // Check if message is deleted by specific user
  bool isDeletedBy(String userId) {
    return deletedBy.contains(userId);
  }
}
