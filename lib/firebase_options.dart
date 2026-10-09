// ARQUIVO GERADO AUTOMATICAMENTE — NÃO EDITE ESTE ARQUIVO NA MÃO
// (a não ser que esteja colando a config de um projeto Firebase real,
// como foi feito aqui para a plataforma Web).
//
// O bloco `web` abaixo já está preenchido com a config real do projeto
// `fridgenotes-75350`. Os blocos `android` e `ios` continuam como
// placeholder — se for rodar em emulador Android ou iOS, rode
// `flutterfire configure` (com o Firebase CLI instalado) na raiz do
// projeto pra gerar essa parte também, ou adicione os apps Android/iOS
// no Firebase Console e cole as credenciais aqui do mesmo jeito.
//
// A API key do Firebase Web NÃO é um segredo como uma chave de servidor
// — ela só identifica o projeto, e vai parar no JS compilado do app de
// qualquer forma (todo app Firebase Web funciona assim). Quem protege
// os dados de verdade são as regras do Firestore (firestore.rules) e o
// Firebase Authentication, não o sigilo dessa chave.

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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDnz941V34QgViGg2x16TxkiKarGFLtKA4',
    appId: '1:908436644428:web:c9ed4e40b09980d77f8ae9',
    messagingSenderId: '908436644428',
    projectId: 'fridgenotes-75350',
    authDomain: 'fridgenotes-75350.firebaseapp.com',
    storageBucket: 'fridgenotes-75350.firebasestorage.app',
  );

  // TODO: substituído automaticamente por `flutterfire configure`.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: '',
    appId: '',
    messagingSenderId: '',
    projectId: '',
  );

  // TODO: substituído automaticamente por `flutterfire configure`.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: '',
    appId: '',
    messagingSenderId: '',
    projectId: '',
    iosBundleId: '',
  );
}
