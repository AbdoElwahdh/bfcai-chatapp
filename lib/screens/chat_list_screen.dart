import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:chat_app/services/auth_service.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;
  final _authService = AuthService();

  String _searchQuery = '';

  Future<void> _logout() async {
    await _authService.signOut();
  }

  void _openChat(String peerId, String peerUsername) {
    if (currentUser == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          peerId: peerId,
          peerUsername: peerUsername,
          currentUserId: currentUser!.uid,
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (currentUser == null) {
      return const Center(
        child: Text('Please sign in to start chatting.'),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        final filtered = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final username = (data['username'] ?? '') as String;
          final isMe = doc.id == currentUser!.uid;

          return !isMe &&
              username.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

        if (filtered.isEmpty) {
          return const Center(
            child: Text(
              'No users found.\nTry a different name.',
              textAlign: TextAlign.center,
            ),
          );
        }

        return ListView.separated(
          itemCount: filtered.length,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          separatorBuilder: (_, __) => const SizedBox(height: 4),
          itemBuilder: (ctx, index) {
            final data = filtered[index].data() as Map<String, dynamic>;
            final peerId = filtered[index].id;
            final username = data['username'] as String? ?? 'Unknown';
            final email = data['email'] as String? ?? '';

            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _openChat(peerId, username),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF4F46E5),
                      child: Text(
                        username.isNotEmpty ? username[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    title: Text(
                      username,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      email,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Text(
          'No recent chats yet.\nUse the search bar above to find someone and start a conversation.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('Messages'),
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: _logout,
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search users',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: _searchQuery.isEmpty
                  ? _buildEmptyState()
                  : _buildSearchResults(),
            ),
          ),
        ],
      ),
    );
  }
}
