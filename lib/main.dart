import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/auth/auth_gate.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // PRIORIDADE 2: inicializa o Firebase com as credenciais geradas por
  // `flutterfire configure` (veja lib/firebase_options.dart e o README).
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const FridgeNotesApp());
}

class FridgeNotesApp extends StatelessWidget {
  const FridgeNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FridgeNotes',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // AuthGate decide sozinho se mostra Login ou Home, baseado no
      // estado de autenticação do Firebase (ver screens/auth/auth_gate.dart).
      home: const AuthGate(),
    );
  }
}
