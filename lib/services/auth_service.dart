import 'package:firebase_auth/firebase_auth.dart';

import 'firestore_service.dart';

/// Serviço responsável por login, cadastro e logout via Firebase Authentication.
///
/// Retorna `null` quando a operação dá certo, ou uma mensagem de erro
/// amigável (em português) quando falha — assim as telas não precisam
/// entender códigos de erro do Firebase.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  /// Stream usada pelo AuthGate para saber se há usuário logado ou não.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyMessage(e.code);
    } catch (_) {
      return 'Ocorreu um erro ao entrar. Tente novamente.';
    }
  }

  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await credential.user?.updateDisplayName(name.trim());

      final uid = credential.user?.uid;
      if (uid != null) {
        // PRIORIDADE 3: após o cadastro, criamos o documento do usuário
        // em users/{userId}, conforme pedido no documento do projeto.
        await _firestoreService.createUserDocument(
          uid: uid,
          name: name.trim(),
          email: email.trim(),
        );
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyMessage(e.code);
    } catch (_) {
      return 'Ocorreu um erro ao cadastrar. Tente novamente.';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String _friendlyMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Não encontramos uma conta com esse e-mail.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      case 'email-already-in-use':
        return 'Já existe uma conta com esse e-mail.';
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'weak-password':
        return 'A senha precisa ter pelo menos 6 caracteres.';
      case 'network-request-failed':
        return 'Sem conexão com a internet.';
      default:
        return 'Ocorreu um erro (${code}). Tente novamente.';
    }
  }
}
