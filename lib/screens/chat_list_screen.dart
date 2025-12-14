import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/chat_service.dart';
import '../services/auth_service.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // Search Logic with Debounce
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _searchQuery =
              query.trim().toLowerCase(); // Keep this for search to work
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) {
      return const Scaffold(body: Center(child: Text("Error: No User")));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Messages',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () async {
              await _authService.signOut();
              if (!mounted) return;
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/auth', (route) => false);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _searchQuery.isEmpty
                ? _buildMyChatRooms(currentUid)
                : _buildGlobalSearch(currentUid),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search for users...',
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  // Tab 1: Recent Chats
  Widget _buildMyChatRooms(String currentUid) {
    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getUserChatRooms(),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return const Center(child: Text("Error loading chats"));
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final rooms = snapshot.data!.docs;
        if (rooms.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey),
                SizedBox(height: 10),
                Text("No chats yet. Search to start!",
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.separated(
          itemCount: rooms.length,
          separatorBuilder: (_, __) => const Divider(height: 1, indent: 70),
          itemBuilder: (context, index) {
            final roomData = rooms[index].data() as Map<String, dynamic>;
            final participants =
                List<String>.from(roomData['participants'] ?? []);
            final otherId = participants.firstWhere((id) => id != currentUid,
                orElse: () => '');

            if (otherId.isEmpty) return const SizedBox.shrink();

            return FutureBuilder<Map<String, dynamic>?>(
              future: _chatService.getUserData(otherId),
              builder: (context, userSnap) {
                if (!userSnap.hasData) {
                  return const ListTile(title: Text("Loading..."));
                }
                final user = userSnap.data!;
                final username = user['username'] ?? 'Unknown';
                final lastMsg = roomData['lastMessage'] ?? '';
                final ts = roomData['lastMessageTime'] as Timestamp?;
                final time = ts != null ? _formatTime(ts) : '';

                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.indigoAccent,
                    child: Text(username[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(username,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(lastMsg,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: Text(time,
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  onTap: () => _navigateToChat(context, otherId, username),
                );
              },
            );
          },
        );
      },
    );
  }

  // Tab 2: Global Search (Using username_lowercase)
  Widget _buildGlobalSearch(String currentUid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('username_lowercase', isGreaterThanOrEqualTo: _searchQuery)
          .where('username_lowercase',
              isLessThanOrEqualTo: '$_searchQuery\uf8ff')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final users =
            snapshot.data!.docs.where((doc) => doc.id != currentUid).toList();

        if (users.isEmpty) {
          return Center(child: Text('No user found matching "$_searchQuery"'));
        }

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final userData = users[index].data() as Map<String, dynamic>;
            final username = userData['username'] ?? 'Unknown';

            return ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(username),
              trailing: const Icon(Icons.message, color: Colors.blueAccent),
              onTap: () => _navigateToChat(context, users[index].id, username),
            );
          },
        );
      },
    );
  }

  void _navigateToChat(BuildContext context, String uid, String name) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => ChatScreen(receiverId: uid, receiverName: name)),
    );
  }

  String _formatTime(Timestamp timestamp) {
    final now = DateTime.now();
    final date = timestamp.toDate();
    if (now.difference(date).inDays == 0) {
      return "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    } else {
      return "${date.day}/${date.month}";
    }
  }
}
