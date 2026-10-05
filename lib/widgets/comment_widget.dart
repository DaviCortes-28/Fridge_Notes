import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/comment_model.dart';

/// Exibe um comentário dentro da tela de um post-it (interação multiusuário).
class CommentWidget extends StatelessWidget {
  final CommentModel comment;

  const CommentWidget({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            child: Text(
              comment.authorName.isNotEmpty ? comment.authorName[0].toUpperCase() : '?',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(comment.authorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('dd/MM HH:mm').format(comment.createdAt),
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
                Text(comment.text),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
