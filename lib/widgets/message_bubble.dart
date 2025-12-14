// Message bubble widget used in ChatScreen.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class MessageBubble extends StatelessWidget {
  final Map<String, dynamic> msg;
  final bool isMe;

  const MessageBubble({super.key, required this.msg, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final timestamp = msg['timestamp'] as Timestamp?;
    final timeText = timestamp != null
        ? TimeOfDay.fromDateTime(timestamp.toDate()).format(context)
        : '';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? AppColors.bubbleMe : AppColors.bubbleOther,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft:
                isMe ? const Radius.circular(18) : const Radius.circular(6),
            bottomRight:
                isMe ? const Radius.circular(6) : const Radius.circular(18),
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              msg['text'] ?? '',
              style: TextStyle(
                  color: isMe ? Colors.white : AppColors.textDark,
                  fontSize: 15),
            ),
            const SizedBox(height: 6),
            Text(
              timeText,
              style: TextStyle(
                  color: isMe ? Colors.white70 : AppColors.textLight,
                  fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
