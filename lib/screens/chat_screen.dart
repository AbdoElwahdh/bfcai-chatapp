import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/widgets/message_bubble.dart';
import 'package:chat_app/widgets/new_message.dart';

class ChatScreen extends StatelessWidget {
  final String peerId;
  final String peerUsername;
  final String currentUserId;

  const ChatScreen({
    super.key,
    required this.peerId,
    required this.peerUsername,
    required this.currentUserId,
  });

  String getChatRoomId(String a, String b) {
    return a.compareTo(b) > 0 ? '${a}_$b' : '${b}_$a';
  }

  void _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    final chatRoomId = getChatRoomId(currentUserId, peerId);
    final messagesCollection = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages');

    await messagesCollection.add({
      'text': message.trim(),
      'senderId': currentUserId,
      'timestamp': Timestamp.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatRoomId = getChatRoomId(currentUserId, peerId);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFEEF2FF),
              child: Text(
                peerUsername.isNotEmpty ? peerUsername[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Color(0xFF4F46E5),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                peerUsername,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: const Color(0xFFF3F4F6),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .doc(chatRoomId)
                    .collection('messages')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (ctx, chatSnapshot) {
                  if (chatSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final chatDocs = chatSnapshot.data?.docs ?? [];

                  return ListView.builder(
                    reverse: true,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: chatDocs.length,
                    itemBuilder: (ctx, index) {
                      final message =
                          chatDocs[index].data() as Map<String, dynamic>;
                      final isMe = message['senderId'] == currentUserId;

                      return MessageBubble(
                        message: message['text'],
                        isMe: isMe,
                      );
                    },
                  );
                },
              ),
            ),
          ),
          NewMessage(onSendMessage: _sendMessage),
        ],
      ),
    );
  }
}
