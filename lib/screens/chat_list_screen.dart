import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text("No user signed in."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _chatService.getUserChatRooms(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text("Something went wrong."),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No chats yet."),
            );
          }

          final chatRooms = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              final room = chatRooms[index];
              final data = room.data() as Map<String, dynamic>;

              final participants = data["participants"] as List<dynamic>;
              final lastMessage = data["lastMessage"] ?? "";
              final lastMessageTime = data["lastMessageTime"] as Timestamp?;

              final otherUserId = participants.firstWhere(
                (id) => id != currentUser.uid,
                orElse: () => "",
              );

              return ListTile(
                title: Text("Chat with: $otherUserId"),
                subtitle: Text(lastMessage),
                trailing: lastMessageTime != null
                    ? Text(
                        lastMessageTime
                            .toDate()
                            .toLocal()
                            .toString()
                            .split(".")[0],
                        style: const TextStyle(fontSize: 12),
                      )
                    : null,
                onTap: () async {
                  // fetch other user's data
                  final userData = await _chatService.getUserData(otherUserId);

                  if (userData == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("User data not found.")),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        receiverId: otherUserId,
                        receiverName: userData["username"] ?? "Unknown",
                        receiverEmail: userData["email"] ?? "",
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
