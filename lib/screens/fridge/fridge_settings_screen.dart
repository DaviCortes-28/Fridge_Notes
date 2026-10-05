import 'package:flutter/material.dart';

import '../../models/fridge_model.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

/// Tela de customização da geladeira (PRIORIDADE 11): nome e tema visual.
///
/// Só o dono da geladeira pode alterar — os demais membros veem as
/// opções desabilitadas, com um aviso explicando o motivo.
class FridgeSettingsScreen extends StatefulWidget {
  final FridgeModel fridge;
  final bool isOwner;

  const FridgeSettingsScreen({super.key, required this.fridge, required this.isOwner});

  @override
  State<FridgeSettingsScreen> createState() => _FridgeSettingsScreenState();
}

class _FridgeSettingsScreenState extends State<FridgeSettingsScreen> {
  late final TextEditingController _nameController;
  late FridgeTheme _selectedTheme;
  bool _saving = false;

  final _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.fridge.name);
    _selectedTheme = FridgeTheme.fromId(widget.fridge.theme);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await _firestoreService.updateFridgeSettings(
        fridgeId: widget.fridge.id,
        name: _nameController.text,
        theme: _selectedTheme.id,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personalizar geladeira')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!widget.isOwner)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.amber[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Apenas o dono da geladeira pode alterar essas opções.'),
              ),
            TextField(
              controller: _nameController,
              enabled: widget.isOwner,
              decoration: const InputDecoration(labelText: 'Nome da geladeira'),
            ),
            const SizedBox(height: 20),
            Text('Tema visual', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: FridgeTheme.values.map((theme) {
                final selected = theme == _selectedTheme;
                return ChoiceChip(
                  label: Text(theme.label),
                  avatar: Icon(theme.icon, size: 18),
                  selected: selected,
                  onSelected: widget.isOwner ? (_) => setState(() => _selectedTheme = theme) : null,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            if (widget.isOwner)
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Salvar'),
              ),
          ],
        ),
      ),
    );
  }
}
