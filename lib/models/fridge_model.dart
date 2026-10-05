import 'package:cloud_firestore/cloud_firestore.dart';

/// Representa um documento da coleção `fridges`.
///
/// `members` guarda os IDs dos usuários que participam da geladeira.
/// `theme` guarda o identificador do tema visual (ver [FridgeTheme] em
/// theme/app_theme.dart) — usado na Prioridade 11 (Customização).
class FridgeModel {
  final String id;
  final String name;
  final String ownerId;
  final String theme;
  final String inviteCode;
  final List<String> members;
  final DateTime createdAt;

  FridgeModel({
    required this.id,
    required this.name,
    required this.ownerId,
    this.theme = 'classic',
    required this.inviteCode,
    this.members = const [],
    required this.createdAt,
  });

  bool isOwner(String userId) => ownerId == userId;

  factory FridgeModel.fromMap(String id, Map<String, dynamic> map) {
    return FridgeModel(
      id: id,
      name: map['name'] ?? '',
      ownerId: map['ownerId'] ?? '',
      theme: map['theme'] ?? 'classic',
      inviteCode: map['inviteCode'] ?? '',
      members: List<String>.from(map['members'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'ownerId': ownerId,
      'theme': theme,
      'inviteCode': inviteCode,
      'members': members,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
