import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  User? _user;
  String? _userName;

  User? get user => _user;
  String? get userName => _userName;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _supabase.auth.onAuthStateChange.listen((AuthState data) {
      _user = data.session?.user;
      if (_user != null) {
        _loadUserName();
      } else {
        _userName = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserName() async {
    if (_user == null) return;
    try {
      final data = await _supabase.from('users').select('full_name').eq('id', _user!.id).single();
      _userName = data['full_name'] as String?;
      notifyListeners();
    } catch (e) {
      print('Error loading user name: $e');
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      await _loadUserName();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      await _loadUserName();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      _userName = null;
    } catch (e) {
      rethrow;
    }
  }

  // دالة عامة لتحديث بيانات المستخدم يمكن استدعاؤها من أي مكان
  Future<void> refreshUserData() async {
    await _loadUserName();
  }
} 