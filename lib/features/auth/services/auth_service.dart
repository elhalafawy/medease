import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/firebase/auth_service.dart';

class AuthServiceProvider {
  final _authService = AuthService();

  Future<UserCredential> registerWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _authService.registerWithEmailAndPassword(email, password);
      await _authService.sendEmailVerification();
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _authService.signInWithEmailAndPassword(email, password);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      return await _authService.signInWithGoogle();
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential> signInWithFacebook() async {
    try {
      return await _authService.signInWithFacebook();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      rethrow;
    }
  }
} 