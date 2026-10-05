import 'package:cloud_firestore/cloud_firestore.dart';

/// Representa um documento da coleção `users` no Firestore.
class UserModel {
  final String id;
  final String name;
  final String email;
  final String avatar;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatar = '',
    required this.createdAt,
  });

  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      avatar: map['avatar'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'avatar': avatar,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
