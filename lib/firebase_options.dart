// ARQUIVO GERADO AUTOMATICAMENTE — NÃO EDITE ESTE ARQUIVO NA MÃO.
//
// Este é um placeholder. As credenciais reais do Firebase (API keys,
// App IDs, etc.) NÃO são inventadas por mim — elas só existem depois
// que você mesmo cria o projeto no Firebase Console e roda o comando
// abaixo na raiz do projeto Flutter (com o Firebase CLI instalado):
//
//   flutterfire configure
//
// Esse comando substitui este arquivo inteiro por um com as
// credenciais reais do SEU projeto Firebase. Veja o passo a passo
// completo no README.md (seção "Prioridade 2 — Firebase").
//
// Até lá, o app vai falhar ao iniciar (Firebase.initializeApp vai
// lançar um erro), porque options.apiKey/appId estão vazios de
// propósito — é esperado.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions não foram configuradas para esta plataforma. '
          'Rode `flutterfire configure` (veja o README).',
        );
    }
  }

  // TODO: substituído automaticamente por `flutterfire configure`.
  static const FirebaseOptions web = FirebaseOptions(
  apiKey: "AIzaSyDnz941V34QgViGg2x16TxkiKarGFLtKA4",

  authDomain: "fridgenotes-75350.firebaseapp.com",

  projectId: "fridgenotes-75350",

  storageBucket: "fridgenotes-75350.firebasestorage.app",

  messagingSenderId: "908436644428",

  appId: "1:908436644428:web:c9ed4e40b09980d77f8ae9"

  );

  // TODO: substituído automaticamente por `flutterfire configure`.
  static const FirebaseOptions android = FirebaseOptions(
  apiKey: "AIzaSyDnz941V34QgViGg2x16TxkiKarGFLtKA4",

  authDomain: "fridgenotes-75350.firebaseapp.com",

  projectId: "fridgenotes-75350",

  storageBucket: "fridgenotes-75350.firebasestorage.app",

  messagingSenderId: "908436644428",

  appId: "1:908436644428:web:c9ed4e40b09980d77f8ae9"

  );

  // TODO: substituído automaticamente por `flutterfire configure`.
  static const FirebaseOptions ios = FirebaseOptions(
  apiKey: "AIzaSyDnz941V34QgViGg2x16TxkiKarGFLtKA4",

  authDomain: "fridgenotes-75350.firebaseapp.com",

  projectId: "fridgenotes-75350",

  storageBucket: "fridgenotes-75350.firebasestorage.app",

  messagingSenderId: "908436644428",

  appId: "1:908436644428:web:c9ed4e40b09980d77f8ae9"

  );
}
