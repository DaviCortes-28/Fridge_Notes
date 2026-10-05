import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/comment_model.dart';
import '../../models/post_it_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/sound_service.dart';
import '../../widgets/comment_widget.dart';
import 'create_post_it_screen.dart' show kPostItColors, kPostItCategories;

/// Tela de detalhe de um post-it: visualização, edição (só o autor),
/// conclusão (qualquer membro), exclusão (autor ou dono da geladeira)
/// e comentários em tempo real (PRIORIDADE 7 — interação multiusuário).
class EditPostItScreen extends StatefulWidget {
  final String fridgeId;
  final String postItId;

  const EditPostItScreen({super.key, required this.fridgeId, required this.postItId});

  @override
  State<EditPostItScreen> createState() => _EditPostItScreenState();
}

class _EditPostItScreenState extends State<EditPostItScreen> {
  final _commentController = TextEditingController();
  final _firestoreService = FirestoreService();
  final _authService = AuthService();
  final _soundService = SoundService();

  bool _sendingComment = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _toggleCompleted(PostItModel postIt) async {
    final user = _authService.currentUser!;
    await _firestoreService.setPostItCompleted(
      fridgeId: widget.fridgeId,
      postItId: postIt.id,
      completed: !postIt.completed,
      completedByName: user.displayName ?? user.email,
    );
    if (!postIt.completed) {
      await _soundService.playConfirm();
    }
  }

  Future<void> _delete(PostItModel postIt) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir post-it?'),
        content: Text('Tem certeza que deseja excluir "${postIt.title}"? Essa ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _firestoreService.deletePostIt(fridgeId: widget.fridgeId, postItId: postIt.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _editDialog(PostItModel postIt) async {
    final titleController = TextEditingController(text: postIt.title);
    final descController = TextEditingController(text: postIt.description);
    String category = postIt.category;
    String color = postIt.color;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Editar post-it'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Título')),
                const SizedBox(height: 8),
                TextField(controller: descController, decoration: const InputDecoration(labelText: 'Descrição'), maxLines: 3),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: kPostItCategories.map((c) {
                    return ChoiceChip(
                      label: Text(c),
                      selected: category == c,
                      onSelected: (_) => setDialogState(() => category = c),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  children: kPostItColors.map((hex) {
                    final c = Color(int.parse(hex.replaceFirst('#', '0xFF')));
                    return GestureDetector(
                      onTap: () => setDialogState(() => color = hex),
                      child: CircleAvatar(
                        backgroundColor: c,
                        radius: color == hex ? 18 : 14,
                        child: color == hex ? const Icon(Icons.check, size: 14) : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Salvar')),
          ],
        ),
      ),
    );

    if (saved == true) {
      await _firestoreService.updatePostIt(
        fridgeId: widget.fridgeId,
        postItId: postIt.id,
        data: {
          'title': titleController.text.trim(),
          'description': descController.text.trim(),
          'category': category,
          'color': color,
        },
      );
    }
  }

  Future<void> _sendComment(PostItModel postIt) async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _sendingComment = true);
    final user = _authService.currentUser!;
    await _firestoreService.addComment(
      fridgeId: widget.fridgeId,
      postItId: postIt.id,
      authorId: user.uid,
      authorName: user.displayName ?? user.email ?? 'Usuário',
      text: text,
    );
    await _soundService.playNotification();
    _commentController.clear();
    if (mounted) setState(() => _sendingComment = false);
  }

  @override
  Widget build(BuildContext context) {
    final uid = _authService.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Post-it')),
      body: StreamBuilder<PostItModel?>(
        stream: _firestoreService.watchPostIt(fridgeId: widget.fridgeId, postItId: widget.postItId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final postIt = snapshot.data;
          if (postIt == null) {
            return const Center(child: Text('Este post-it foi removido.'));
          }

          final isAuthor = postIt.authorId == uid;
          final color = Color(int.parse(postIt.color.replaceFirst('#', '0xFF')));

          return Column(
            children: [
              Container(
                width: double.infinity,
                color: color,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(postIt.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        ),
                        if (isAuthor)
                          IconButton(icon: const Icon(Icons.edit), onPressed: () => _editDialog(postIt)),
                        IconButton(icon: const Icon(Icons.delete), onPressed: () => _delete(postIt)),
                      ],
                    ),
                    if (postIt.description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(postIt.description),
                    ],
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Chip(label: Text(postIt.category), visualDensity: VisualDensity.compact),
                        Chip(label: Text('por ${postIt.authorName}'), visualDensity: VisualDensity.compact),
                        if (postIt.dueDate != null)
                          Chip(
                            label: Text('Vence ${DateFormat('dd/MM').format(postIt.dueDate!)}'),
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => _toggleCompleted(postIt),
                      icon: Icon(postIt.completed ? Icons.replay : Icons.check),
                      label: Text(
                        postIt.completed
                            ? 'Concluído por ${postIt.completedByName ?? '-'} · reabrir'
                            : 'Marcar como concluído',
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Comentários', style: Theme.of(context).textTheme.titleMedium),
                ),
              ),
              Expanded(
                child: StreamBuilder<List<CommentModel>>(
                  stream: _firestoreService.watchComments(fridgeId: widget.fridgeId, postItId: postIt.id),
                  builder: (context, commentSnapshot) {
                    final comments = commentSnapshot.data ?? [];
                    if (commentSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (comments.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Nenhum comentário ainda. Seja o primeiro a responder!'),
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: comments.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) => CommentWidget(comment: comments[index]),
                    );
                  },
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: const InputDecoration(
                            hintText: 'Escreva um comentário...',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          onSubmitted: (_) => _sendComment(postIt),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _sendingComment
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: () => _sendComment(postIt),
                            ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
