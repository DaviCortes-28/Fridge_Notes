import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/comment_model.dart';
import '../models/fridge_model.dart';
import '../models/post_it_model.dart';
import '../models/user_model.dart';

/// Serviço responsável por toda a leitura/escrita no Cloud Firestore.
///
/// Estrutura usada (PRIORIDADE 4):
///
/// users/{userId}
/// fridges/{fridgeId}
///   postIts/{postItId}
///     comments/{commentId}
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _db.collection('users');

  CollectionReference<Map<String, dynamic>> get _fridgesRef =>
      _db.collection('fridges');

  CollectionReference<Map<String, dynamic>> _postItsRef(String fridgeId) =>
      _fridgesRef.doc(fridgeId).collection('postIts');

  CollectionReference<Map<String, dynamic>> _commentsRef(
    String fridgeId,
    String postItId,
  ) =>
      _postItsRef(fridgeId).doc(postItId).collection('comments');

  // ---------------------------------------------------------------------
  // USERS (PRIORIDADE 3)
  // ---------------------------------------------------------------------

  Future<void> createUserDocument({
    required String uid,
    required String name,
    required String email,
  }) async {
    await _usersRef.doc(uid).set({
      'name': name,
      'email': email,
      'avatar': '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _usersRef.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.id, doc.data()!);
  }

  /// Busca vários usuários de uma vez (usado para exibir a lista de
  /// membros de uma geladeira com nome, e não só o ID).
  Future<List<UserModel>> getUsers(List<String> ids) async {
    if (ids.isEmpty) return [];
    final futures = ids.map((id) => _usersRef.doc(id).get());
    final docs = await Future.wait(futures);
    return docs
        .where((d) => d.exists)
        .map((d) => UserModel.fromMap(d.id, d.data()!))
        .toList();
  }

  // ---------------------------------------------------------------------
  // FRIDGES (PRIORIDADE 5)
  // ---------------------------------------------------------------------

  /// Cria uma nova geladeira e devolve o ID gerado.
  ///
  /// Também gera um código de convite aleatório de 6 caracteres
  /// (ex: "8F4K2A") usado por outros usuários para entrar na geladeira.
  Future<FridgeModel> createFridge({
    required String name,
    required String ownerId,
    String theme = 'classic',
  }) async {
    final inviteCode = _generateInviteCode();

    final docRef = await _fridgesRef.add({
      'name': name,
      'ownerId': ownerId,
      'theme': theme,
      'inviteCode': inviteCode,
      'members': [ownerId],
      'createdAt': FieldValue.serverTimestamp(),
    });

    final snapshot = await docRef.get();
    return FridgeModel.fromMap(snapshot.id, snapshot.data()!);
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // sem O/0/I/1 (confunde)
    final rnd = Random.secure();
    return List.generate(6, (_) => chars[rnd.nextInt(chars.length)]).join();
  }

  /// Consulta ao Firestore pelo código de convite e adiciona o usuário
  /// aos membros da geladeira encontrada.
  ///
  /// Lança uma [Exception] com mensagem amigável se o código não existir.
  Future<FridgeModel> joinFridgeByCode({
    required String code,
    required String userId,
  }) async {
    final normalized = code.trim().toUpperCase();

    final query = await _fridgesRef
        .where('inviteCode', isEqualTo: normalized)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception('Nenhuma geladeira encontrada com esse código.');
    }

    final doc = query.docs.first;

    await doc.reference.update({
      'members': FieldValue.arrayUnion([userId]),
    });

    final updated = await doc.reference.get();
    return FridgeModel.fromMap(updated.id, updated.data()!);
  }

  Future<void> leaveFridge({
    required String fridgeId,
    required String userId,
  }) async {
    await _fridgesRef.doc(fridgeId).update({
      'members': FieldValue.arrayRemove([userId]),
    });
  }

  /// Geladeiras das quais o usuário atual é membro.
  Stream<List<FridgeModel>> watchUserFridges(String userId) {
    return _fridgesRef
        .where('members', arrayContains: userId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => FridgeModel.fromMap(d.id, d.data()))
            .toList());
  }

  Stream<FridgeModel?> watchFridge(String fridgeId) {
    return _fridgesRef.doc(fridgeId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return FridgeModel.fromMap(doc.id, doc.data()!);
    });
  }

  /// Customização da geladeira (PRIORIDADE 11): nome e tema visual.
  /// Não altera nenhuma outra funcionalidade (membros, post-its, etc.).
  Future<void> updateFridgeSettings({
    required String fridgeId,
    String? name,
    String? theme,
  }) async {
    final data = <String, dynamic>{};
    if (name != null && name.trim().isNotEmpty) data['name'] = name.trim();
    if (theme != null) data['theme'] = theme;
    if (data.isEmpty) return;
    await _fridgesRef.doc(fridgeId).update(data);
  }

  // ---------------------------------------------------------------------
  // POST-ITS (PRIORIDADE 6)
  // ---------------------------------------------------------------------

  Future<void> createPostIt({
    required String fridgeId,
    required String title,
    required String description,
    required String authorId,
    required String authorName,
    required String color,
    required String category,
    required String magnetIcon,
    DateTime? dueDate,
    required double posX,
    required double posY,
  }) async {
    await _postItsRef(fridgeId).add({
      'title': title,
      'description': description,
      'authorId': authorId,
      'authorName': authorName,
      'color': color,
      'category': category,
      'magnetIcon': magnetIcon,
      'completed': false,
      'completedByName': null,
      'dueDate': dueDate == null ? null : Timestamp.fromDate(dueDate),
      'createdAt': FieldValue.serverTimestamp(),
      'posX': posX,
      'posY': posY,
    });
  }

  /// Atualiza só a posição do post-it no mural (ao arrastar), sem mexer
  /// no resto dos campos.
  Future<void> updatePostItPosition({
    required String fridgeId,
    required String postItId,
    required double posX,
    required double posY,
  }) async {
    await _postItsRef(fridgeId).doc(postItId).update({'posX': posX, 'posY': posY});
  }

  Future<void> updatePostIt({
    required String fridgeId,
    required String postItId,
    required Map<String, dynamic> data,
  }) async {
    await _postItsRef(fridgeId).doc(postItId).update(data);
  }

  Future<void> deletePostIt({
    required String fridgeId,
    required String postItId,
  }) async {
    // Observação didática: isso não apaga a subcoleção "comments"
    // automaticamente (o Firestore não faz isso sozinho). Para um
    // projeto acadêmico isso é aceitável; em produção seria feito por
    // uma Cloud Function.
    await _postItsRef(fridgeId).doc(postItId).delete();
  }

  Future<void> setPostItCompleted({
    required String fridgeId,
    required String postItId,
    required bool completed,
    String? completedByName,
  }) async {
    await _postItsRef(fridgeId).doc(postItId).update({
      'completed': completed,
      'completedByName': completed ? completedByName : null,
    });
  }

  Stream<PostItModel?> watchPostIt({
    required String fridgeId,
    required String postItId,
  }) {
    return _postItsRef(fridgeId).doc(postItId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return PostItModel.fromMap(doc.id, doc.data()!);
    });
  }

  /// Todos os post-its da geladeira, mais recentes primeiro.
  Stream<List<PostItModel>> watchAllPostIts(String fridgeId) {
    return _postItsRef(fridgeId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_mapPostIts);
  }

  // ---------------------------------------------------------------------
  // CONSULTAS / FILTROS (PRIORIDADE 8) — mínimo de 2 exigido pela atividade
  // ---------------------------------------------------------------------

  /// CONSULTA 1: somente post-its pendentes (completed == false).
  Stream<List<PostItModel>> watchPendingPostIts(String fridgeId) {
    return _postItsRef(fridgeId)
        .where('completed', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_mapPostIts);
  }

  /// CONSULTA 2: somente post-its criados pelo usuário atual.
  Stream<List<PostItModel>> watchMyPostIts(String fridgeId, String userId) {
    return _postItsRef(fridgeId)
        .where('authorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_mapPostIts);
  }

  /// CONSULTA EXTRA: somente post-its concluídos (bônus, além do mínimo).
  Stream<List<PostItModel>> watchCompletedPostIts(String fridgeId) {
    return _postItsRef(fridgeId)
        .where('completed', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_mapPostIts);
  }

  List<PostItModel> _mapPostIts(QuerySnapshot<Map<String, dynamic>> snap) {
    return snap.docs.map((d) => PostItModel.fromMap(d.id, d.data())).toList();
  }

  // ---------------------------------------------------------------------
  // COMENTÁRIOS (PRIORIDADE 7 — interação multiusuário)
  // ---------------------------------------------------------------------

  Stream<List<CommentModel>> watchComments({
    required String fridgeId,
    required String postItId,
  }) {
    return _commentsRef(fridgeId, postItId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => CommentModel.fromMap(d.id, d.data()))
            .toList());
  }

  Future<void> addComment({
    required String fridgeId,
    required String postItId,
    required String authorId,
    required String authorName,
    required String text,
  }) async {
    await _commentsRef(fridgeId, postItId).add({
      'authorId': authorId,
      'authorName': authorName,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
