import 'package:chat_app/screens/chat_screen.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final AuthService _auth = AuthService();
  final ChatService _chatService = ChatService();

  String searchQuery = "";

  /// Search users by username (case-insensitive)
  Stream<QuerySnapshot> _searchUsers(String query) {
    return FirebaseFirestore.instance
        .collection("users")
        .where("username", isGreaterThanOrEqualTo: query)
        .where("username", isLessThanOrEqualTo: "$query\uf8ff")
        .snapshots();
  }

  /// Only show chat rooms that include current user
  Stream<QuerySnapshot> _chatRooms() {
    return _chatService.getUserChatRooms();
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text(
          "Chats",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacementNamed(context, "/auth");
            },
          )
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: searchQuery.isEmpty
                ? _buildChatRoomsList(currentUid)
                : _buildSearchResults(currentUid),
          ),
        ],
      ),
    );
  }

  /// Search Bar Widget
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search, color: Colors.indigo),
            hintText: "Search by name...",
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14),
          ),
          onChanged: (val) {
            setState(() => searchQuery = val.trim().toLowerCase());
          },
        ),
      ),
    );
  }

  /// ------------------------------
  /// CHAT ROOMS LIST (default mode)
  /// ------------------------------
  Widget _buildChatRoomsList(String currentUid) {
    return StreamBuilder<QuerySnapshot>(
      stream: _chatRooms(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final rooms = snapshot.data!.docs;

        if (rooms.isEmpty) {
          return const Center(child: Text("No chats yet"));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: rooms.length,
          itemBuilder: (context, index) {
            final room = rooms[index].data() as Map<String, dynamic>;
            final participants = (room["participants"] ?? []) as List;

            if (participants.isEmpty) return const SizedBox();

            /// Determine the other participant
            String? otherId;
            for (var id in participants) {
              if (id != currentUid) {
                otherId = id;
                break;
              }
            }
            if (otherId == null) return const SizedBox();

            return _buildChatRoomTile(room, otherId);
          },
        );
      },
    );
  }

  /// Builds each chat room tile
  Widget _buildChatRoomTile(Map<String, dynamic> room, String otherId) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _chatService.getUserData(otherId),
      builder: (context, userSnap) {
        if (!userSnap.hasData) return const SizedBox();

        final user = userSnap.data!;
        final username = (user["username"] ?? "").toString();
        final email = user["email"];
        final lastMsg = (room["lastMessage"] ?? "").toString();

        return _buildTile(
          username: username,
          subtitle: lastMsg,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(
                  receiverId: otherId,
                  receiverName: username,
                  receiverEmail: email,
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// ------------------------------
  /// SEARCH RESULTS LIST
  /// ------------------------------
  Widget _buildSearchResults(String currentUid) {
    return StreamBuilder<QuerySnapshot>(
      stream: _searchUsers(searchQuery),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!.docs.where((u) => u.id != currentUid);

        if (users.isEmpty) {
          return const Center(child: Text("No users found"));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final data = users.elementAt(index).data() as Map<String, dynamic>;
            final uid = users.elementAt(index).id;

            final username = (data["username"] ?? "").toString();

            return _buildTile(
              username: username,
              subtitle: "", // hide email in search results
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      receiverId: uid,
                      receiverName: username,
                      receiverEmail: data["email"],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  /// Reusable UI tile for chat list + search list
  Widget _buildTile({
    required String username,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final avatarLetter = username.isNotEmpty ? username[0].toUpperCase() : "?";

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.indigo,
          child: Text(
            avatarLetter,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
        title: Text(
          username,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: subtitle.isNotEmpty
            ? Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
