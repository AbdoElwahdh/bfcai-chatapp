import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Generate chat room ID in a consistent order.
  String getChatRoomId(String id1, String id2) {
    final ids = [id1, id2];
    ids.sort();
    return ids.join("_");
  }

  /// Safely fetch current user document.
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.data() as Map<String, dynamic>?;
  }

  /// Send message with safe null-checks and batch update.
  Future<void> sendMessage(
    String receiverId,
    String text,
    Map<String, dynamic> receiverData,
  ) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not signed in");
    }

    final senderId = user.uid;
    final senderEmail = user.email ?? "";
    final timestamp = Timestamp.now();

    final senderData = await getCurrentUserData();
    final senderName = senderData?["username"] ?? "Unknown";

    final chatRoomId = getChatRoomId(senderId, receiverId);

    final messagesRef = _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages");

    final batch = _firestore.batch();

    final newMessageRef = messagesRef.doc();

    // Message object
    batch.set(newMessageRef, {
      "id": newMessageRef.id,
      "senderId": senderId,
      "senderName": senderName,
      "senderEmail": senderEmail,
      "text": text,
      "timestamp": timestamp,
      "read": false,
    });

    // Room meta update
    final roomRef = _firestore.collection("chat_rooms").doc(chatRoomId);
    batch.set(
      roomRef,
      {
        "participants": [senderId, receiverId],
        "lastMessage": text,
        "lastMessageTime": timestamp,
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  /// Return empty stream if user is null (prevents crashes).
  Stream<QuerySnapshot> getUserChatRooms() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection("chat_rooms")
        .where("participants", arrayContains: user.uid)
        .orderBy("lastMessageTime", descending: true)
        .snapshots();
  }

  /// Limited messages load (foundation for pagination).
  Stream<QuerySnapshot> getMessages(
    String userId,
    String otherUserId, {
    int limit = 50,
  }) {
    final chatRoomId = getChatRoomId(userId, otherUserId);

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .limit(limit)
        .snapshots();
  }
}
