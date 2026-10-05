import 'package:cloud_firestore/cloud_firestore.dart';

/// Status calculado de um post-it, usado só na exibição (não é salvo
/// diretamente no Firestore — é derivado de `completed` e `dueDate`).
enum PostItStatus { pending, completed, late }

/// Representa um documento da subcoleção `fridges/{fridgeId}/postIts`.
class PostItModel {
  final String id;
  final String title;
  final String description;
  final String authorId;
  final String authorName;
  final String color; // cor em hex, ex: '#FFF176'
  final String category;
  final String magnetIcon; // identificador do ícone do ímã (customização)
  final bool completed;
  final String? completedByName;
  final DateTime? dueDate;
  final DateTime createdAt;

  /// Posição no mural, como FRAÇÃO (0.0 a 1.0) da área visível — e não em
  /// pixels — para a posição continuar fazendo sentido em qualquer
  /// tamanho de tela/janela. Atualizado ao arrastar o post-it.
  final double posX;
  final double posY;

  PostItModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.authorId,
    required this.authorName,
    this.color = '#FFF176',
    this.category = 'geral',
    this.magnetIcon = 'pin',
    this.completed = false,
    this.completedByName,
    this.dueDate,
    required this.createdAt,
    required this.posX,
    required this.posY,
  });

  PostItStatus get status {
    if (completed) return PostItStatus.completed;
    if (dueDate != null && dueDate!.isBefore(DateTime.now())) {
      return PostItStatus.late;
    }
    return PostItStatus.pending;
  }

  /// Gera uma posição padrão determinística (baseada no ID) para post-its
  /// antigos que ainda não têm posX/posY salvos no Firestore — assim eles
  /// não ficam todos empilhados exatamente no canto (0,0).
  static double _fallbackCoord(String id, int salt) {
    final seed = (id.hashCode ^ salt).abs();
    return 0.06 + (seed % 70) / 100; // entre 0.06 e 0.75
  }

  factory PostItModel.fromMap(String id, Map<String, dynamic> map) {
    return PostItModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      color: map['color'] ?? '#FFF176',
      category: map['category'] ?? 'geral',
      magnetIcon: map['magnetIcon'] ?? 'pin',
      completed: map['completed'] ?? false,
      completedByName: map['completedByName'],
      dueDate: (map['dueDate'] as Timestamp?)?.toDate(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      posX: (map['posX'] as num?)?.toDouble() ?? _fallbackCoord(id, 17),
      posY: (map['posY'] as num?)?.toDouble() ?? _fallbackCoord(id, 31),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'authorId': authorId,
      'authorName': authorName,
      'color': color,
      'category': category,
      'magnetIcon': magnetIcon,
      'completed': completed,
      'completedByName': completedByName,
      'dueDate': dueDate == null ? null : Timestamp.fromDate(dueDate!),
      'createdAt': Timestamp.fromDate(createdAt),
      'posX': posX,
      'posY': posY,
    };
  }
}
