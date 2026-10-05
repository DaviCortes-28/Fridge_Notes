import 'package:cloud_firestore/cloud_firestore.dart';

/// Representa um documento da subcoleção `comments` dentro de um post-it.
///
/// Caminho completo:
/// fridges/{fridgeId}/postIts/{postItId}/comments/{commentId}
///
/// É essa subcoleção que sustenta o requisito de interação multiusuário.
class CommentModel {
  final String id;
  final String authorId;
  final String authorName;
  final String text;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.text,
    required this.createdAt,
  });

  factory CommentModel.fromMap(String id, Map<String, dynamic> map) {
    return CommentModel(
      id: id,
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      text: map['text'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
