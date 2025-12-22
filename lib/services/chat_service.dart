import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../utils/helpers.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Create or get existing chat
  Future<String?> createChat(String otherUserId) async {
    if (currentUserId == null) return null;

    final chatId = Helpers.getChatId(currentUserId!, otherUserId);

    try {
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();

      if (!chatDoc.exists) {
        // Create new chat
        final chat = ChatModel(
          id: chatId,
          participants: [currentUserId!, otherUserId],
          lastMessage: '',
          lastMessageTime: Timestamp.now(),
          createdAt: Timestamp.now(),
          deletedBy: [],
        );

        await _firestore.collection('chats').doc(chatId).set(chat.toMap());
      } else {
        // Chat exists - restore chat if it was deleted by current user
        await _firestore.collection('chats').doc(chatId).update({
          'deletedBy': FieldValue.arrayRemove([currentUserId]),
        });
      }

      return chatId;
    } catch (e) {
      return null;
    }
  }

  // Send message
  Future<void> sendMessage(String chatId, String text) async {
    if (currentUserId == null || text.trim().isEmpty) return;

    try {
      final timestamp = Timestamp.now();

      // Create message
      final message = MessageModel(
        id: '',
        senderId: currentUserId!,
        text: text.trim(),
        timestamp: timestamp,
        deletedBy: [],
      );

      // Add message to subcollection
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(message.toMap());

      // Update chat's last message
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': text.trim(),
        'lastMessageTime': timestamp,
        'deletedBy': [], // Restore chat for all users when new message arrives
      });
    } catch (e) {
      rethrow;
    }
  }

  // Get chats stream (only non-deleted chats)
  Stream<List<ChatModel>> getChatsStream() {
    if (currentUserId == null) return Stream.value([]);

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .snapshots()
        .map((snapshot) {
      final chats = snapshot.docs
          .map((doc) => ChatModel.fromFirestore(doc))
          .where((chat) => !chat.isDeletedBy(currentUserId!))
          .toList();

      // Sort chats locally by last message time
      chats.sort(
        (a, b) => b.lastMessageTime.compareTo(a.lastMessageTime),
      );

      return chats;
    });
  }

  // Get messages stream (only non-deleted messages)
  Stream<List<MessageModel>> getMessagesStream(String chatId) {
    if (currentUserId == null) return Stream.value([]);

    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MessageModel.fromFirestore(doc))
          .where((message) => !message.isDeletedBy(currentUserId!))
          .toList();
    });
  }

  // Delete chat (soft delete - only for current user)
  Future<void> deleteChat(String chatId) async {
    if (currentUserId == null) return;

    try {
      await _firestore.collection('chats').doc(chatId).update({
        'deletedBy': FieldValue.arrayUnion([currentUserId]),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Clear chat messages (soft delete - only for current user)
  Future<void> clearChat(String chatId) async {
    if (currentUserId == null) return;

    try {
      final messagesSnapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .get();

      final batch = _firestore.batch();

      // Mark messages as deleted for current user
      for (var doc in messagesSnapshot.docs) {
        batch.update(doc.reference, {
          'deletedBy': FieldValue.arrayUnion([currentUserId]),
        });
      }

      await batch.commit();

      // Clear last message preview for current user
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': '',
        'lastMessageTime': null,
      });
    } catch (e) {
      rethrow;
    }
  }
}
