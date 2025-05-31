import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase/auth_service.dart';

class AuthServiceProvider {
  final _authService = AuthService();

  Future<bool> registerWithEmailAndPassword(String email, String password, context) async {
    try {
      return await _authService.registerWithEmailAndPasswordWithUI(context, email, password);
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _authService.signInWithEmailAndPassword(email, password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      await _authService.signInWithGoogle();
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