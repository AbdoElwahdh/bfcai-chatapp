// Input area widget for sending new messages.
import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';

class NewMessage extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  final String receiverEmail;

  const NewMessage(
      {super.key,
      required this.receiverId,
      required this.receiverName,
      required this.receiverEmail});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final TextEditingController _controller = TextEditingController();
  final ChatService _chat = ChatService();
  final AuthService _auth = AuthService();
  bool _sending = false;

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);

    try {
      await _chat.sendMessage(widget.receiverId, text, {
        'username': widget.receiverName,
        'email': widget.receiverEmail,
      });
      _controller.clear();
    } catch (_) {
      // ignore: avoid_print
      print('send failed');
    } finally {
      setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(borderSide: BorderSide.none),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                filled: true,
                fillColor: Color(0xFFF3F4F6),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: AppColors.primary),
            child: IconButton(
              icon: _sending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.send, color: Colors.white),
              onPressed: _sending ? null : _send,
            ),
          ),
        ],
      ),
    );
  }
}
