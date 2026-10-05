import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

class JoinFridgeScreen extends StatefulWidget {
  const JoinFridgeScreen({super.key});

  @override
  State<JoinFridgeScreen> createState() => _JoinFridgeScreenState();
}

class _JoinFridgeScreenState extends State<JoinFridgeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _loading = false;

  final _firestoreService = FirestoreService();
  final _authService = AuthService();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final fridge = await _firestoreService.joinFridgeByCode(
        code: _codeController.text,
        userId: _authService.currentUser!.uid,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Você entrou em "${fridge.name}"!')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entrar em uma geladeira')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Digite o código de convite compartilhado com você:'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Código',
                  hintText: 'Ex: 8F4K2A',
                ),
                style: const TextStyle(fontSize: 20, letterSpacing: 3),
                validator: (v) => (v == null || v.trim().length < 4) ? 'Informe um código válido' : null,
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
                    : const Text('Entrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
