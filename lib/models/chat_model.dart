import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final Timestamp lastMessageTime;
  final Timestamp createdAt;
  final List<String> deletedBy;

  ChatModel({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.createdAt,
    required this.deletedBy,
  });

  // Create ChatModel from Firestore document
  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatModel(
      id: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: data['lastMessageTime'] ?? Timestamp.now(),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      deletedBy: List<String>.from(data['deletedBy'] ?? []),
    );
  }

  // Convert ChatModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'createdAt': createdAt,
      'deletedBy': deletedBy,
    };
  }

  // Check if chat is deleted by specific user
  bool isDeletedBy(String userId) {
    return deletedBy.contains(userId);
  }

  // Get the other participant's ID
  String getOtherUserId(String currentUserId) {
    return participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }
}
