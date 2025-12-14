import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Ensure you have intl package
import '../utils/app_colors.dart';

class MessageBubble extends StatelessWidget {
  final Map<String, dynamic> msg;
  final bool isMe;

  const MessageBubble({super.key, required this.msg, required this.isMe});

  @override
  Widget build(BuildContext context) {
    // Robust parsing of timestamp
    final timestamp = msg['timestamp'] as Timestamp?;
    final timeText = timestamp != null
        ? DateFormat('hh:mm a').format(timestamp.toDate())
        : '';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe
              ? AppColors.bubbleMe
              : AppColors.bubbleOther, // Ensure these colors exist
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft:
                isMe ? const Radius.circular(16) : const Radius.circular(2),
            bottomRight:
                isMe ? const Radius.circular(2) : const Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              msg['text'] ?? '',
              style: TextStyle(
                color: isMe ? Colors.white : AppColors.textDark,
                fontSize: 16,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              timeText,
              style: TextStyle(
                color: isMe ? Colors.white.withOpacity(0.7) : Colors.grey[600],
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
