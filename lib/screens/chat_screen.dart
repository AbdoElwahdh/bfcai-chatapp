import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import '../widgets/message_bubble.dart';
import '../widgets/new_message.dart';

class ChatScreen extends StatelessWidget {
  final String receiverId;
  final String receiverName;

  ChatScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
  });

  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final currentUid = _auth.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF), // Subtle background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              child: Text(
                  receiverName.isNotEmpty ? receiverName[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 14)),
            ),
            const SizedBox(width: 10),
            Text(receiverName,
                style: const TextStyle(color: Colors.black, fontSize: 18)),
          ],
        ),
        leading: const BackButton(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _chatService.getMessages(receiverId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('Say Hi! 👋',
                        style: TextStyle(color: Colors.grey)),
                  );
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true, // Auto-scroll to bottom
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data = messages[index].data() as Map<String, dynamic>;
                    final isMe = data['senderId'] == currentUid;
                    return MessageBubble(msg: data, isMe: isMe);
                  },
                );
              },
            ),
          ),
          // Using the extracted widget for input
          NewMessage(receiverId: receiverId),
        ],
      ),
    );
  }
}
