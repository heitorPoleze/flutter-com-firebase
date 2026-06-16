import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';

class AuthService {
  final _firebaseAuth = FirebaseAuth.instance;

  Future<bool> cadastrarUsuario({required String email, required String senha}) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: senha);
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('Erro ao cadastrar usuário: $e');
      rethrow;
    }
  }

  Future<bool> fazerLogin({required String email, required String senha}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: senha);
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('Erro ao fazer login: $e');
      rethrow;
    }
  }

  Future<bool> recuperarSenhaViaEmail(String email) async {
    try{
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('Erro ao recuperar senha: $e');
      rethrow;
    }
  }
}