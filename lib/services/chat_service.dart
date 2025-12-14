import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Cache to prevent excessive reads
  final Map<String, Map<String, dynamic>> _userCache = {};

  /// Generates a consistent Chat Room ID based on user IDs
  String getChatRoomId(String id1, String id2) {
    final ids = [id1, id2]..sort();
    return ids.join('_');
  }

  /// Get User Data with caching and error handling
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      if (_userCache.containsKey(userId)) {
        return _userCache[userId];
      }

      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>;
      _userCache[userId] = data;
      return data;
    } catch (e) {
      debugPrint('Error getting user data: $e');
      return null;
    }
  }

  /// Sends a message and updates the ChatRoom summary
  Future<void> sendMessage(String receiverId, String text) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final senderId = user.uid;
    // Optimistic UI updates or fetch actual name
    final senderData = await getUserData(senderId);
    final senderName = senderData?['username'] ?? 'User';

    final timestamp = Timestamp.now();
    final chatRoomId = getChatRoomId(senderId, receiverId);

    // Create a new message document
    final messageRef = _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc();

    final batch = _firestore.batch();

    // 1. Add the message
    batch.set(messageRef, {
      'id': messageRef.id,
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'timestamp': timestamp,
      'read': false, // Future enhancement: Read receipts
    });

    // 2. Update the chat room summary (for the list view)
    batch.set(
      _firestore.collection('chat_rooms').doc(chatRoomId),
      {
        'participants': [senderId, receiverId],
        'lastMessage': text,
        'lastMessageTime': timestamp,
        'chatRoomId': chatRoomId,
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  /// Stream of Chat Rooms for the main list
  Stream<QuerySnapshot> getUserChatRooms() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('chat_rooms')
        .where('participants', arrayContains: user.uid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }

  /// Stream of Messages for a specific chat
  Stream<QuerySnapshot> getMessages(String otherUserId) {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    final roomId = getChatRoomId(user.uid, otherUserId);

    return _firestore
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(100) // Increased limit for better UX
        .snapshots();
  }
}
