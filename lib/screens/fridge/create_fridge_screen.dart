import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

class CreateFridgeScreen extends StatefulWidget {
  const CreateFridgeScreen({super.key});

  @override
  State<CreateFridgeScreen> createState() => _CreateFridgeScreenState();
}

class _CreateFridgeScreenState extends State<CreateFridgeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  FridgeTheme _selectedTheme = FridgeTheme.classic;
  bool _loading = false;

  final _firestoreService = FirestoreService();
  final _authService = AuthService();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final fridge = await _firestoreService.createFridge(
        name: _nameController.text.trim(),
        ownerId: _authService.currentUser!.uid,
        theme: _selectedTheme.id,
      );

      if (!mounted) return;
      setState(() => _loading = false);

      // Mostra o código de convite gerado, com opção de copiar — é o
      // que o outro usuário vai digitar para entrar na geladeira.
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Geladeira criada! 🧊'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Compartilhe este código para outras pessoas entrarem:'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        fridge.inviteCode,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 3),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    tooltip: 'Copiar código',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: fridge.inviteCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Código copiado!')),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar geladeira: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova geladeira')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome da geladeira',
                  hintText: 'Ex: Casa, Família, República...',
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Dê um nome à geladeira' : null,
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
                    onSelected: (_) => setState(() => _selectedTheme = theme),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Criar geladeira'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
