import 'dart:math';

import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/sound_service.dart';
import '../../widgets/post_it_widget.dart';

const List<String> kPostItColors = ['#FFF176', '#81D4FA', '#A5D6A7', '#FFAB91', '#CE93D8'];
const List<String> kPostItCategories = ['geral', 'compras', 'tarefa', 'lembrete', 'recado'];

class CreatePostItScreen extends StatefulWidget {
  final String fridgeId;

  const CreatePostItScreen({super.key, required this.fridgeId});

  @override
  State<CreatePostItScreen> createState() => _CreatePostItScreenState();
}

class _CreatePostItScreenState extends State<CreatePostItScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _color = kPostItColors.first;
  String _category = kPostItCategories.first;
  String _magnetIcon = kMagnetIcons.keys.first;
  DateTime? _dueDate;
  bool _saving = false;

  final _firestoreService = FirestoreService();
  final _authService = AuthService();
  final _soundService = SoundService();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    final user = _authService.currentUser!;
    final random = Random();
    try {
      await _firestoreService.createPostIt(
        fridgeId: widget.fridgeId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        authorId: user.uid,
        authorName: user.displayName ?? user.email ?? 'Usuário',
        color: _color,
        category: _category,
        magnetIcon: _magnetIcon,
        dueDate: _dueDate,
        // Posição inicial aleatória no mural (fração 0.05–0.7 da área
        // visível) — o usuário pode arrastar pra organizar depois.
        posX: 0.05 + random.nextDouble() * 0.65,
        posY: 0.05 + random.nextDouble() * 0.55,
      );

      // PRIORIDADE 12: som de papel (criando) + ímã (fixando).
      await _soundService.playPaper();
      await _soundService.playMagnet();

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar post-it: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo post-it')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Dê um título ao post-it' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              Text('Categoria', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: kPostItCategories.map((c) {
                  return ChoiceChip(
                    label: Text(c),
                    selected: _category == c,
                    onSelected: (_) => setState(() => _category = c),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Text('Cor', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children: kPostItColors.map((hex) {
                  final color = Color(int.parse(hex.replaceFirst('#', '0xFF')));
                  final selected = _color == hex;
                  return GestureDetector(
                    onTap: () => setState(() => _color = hex),
                    child: CircleAvatar(
                      backgroundColor: color,
                      radius: selected ? 20 : 16,
                      child: selected ? const Icon(Icons.check, size: 16) : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Text('Ímã', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: kMagnetIcons.entries.map((entry) {
                  final selected = _magnetIcon == entry.key;
                  return ChoiceChip(
                    avatar: Icon(entry.value, size: 18),
                    label: Text(entry.key),
                    selected: selected,
                    onSelected: (_) => setState(() => _magnetIcon = entry.key),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _dueDate == null
                          ? 'Sem data de vencimento'
                          : 'Vence em: ${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                    ),
                  ),
                  TextButton(onPressed: _pickDueDate, child: const Text('Escolher data')),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saving ? null : _submit,
                child: _saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Fixar na geladeira'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
