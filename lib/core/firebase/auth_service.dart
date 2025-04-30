import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Show error dialog
  Future<void> showErrorDialog(BuildContext context, String text) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("An error has occurred"),
          content: Text(text),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            )
          ],
        );
      },
    );
  }

  // Register with email and password with error handling
  Future<bool> registerWithEmailAndPasswordWithUI(BuildContext context, String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration successful! Please verify your email.")),
      );

      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        await showErrorDialog(context, "Weak password: ${e.message}");
      } else if (e.code == 'email-already-in-use') {
        await showErrorDialog(context, "This email is already in use.");
      } else {
        await showErrorDialog(context, "Error: ${e.message}");
      }
      return false;
    } catch (e) {
      await showErrorDialog(context, e.toString());
      return false;
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google sign in aborted');

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with Facebook
  Future<UserCredential> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status != LoginStatus.success) {
        throw Exception('Facebook sign in failed');
      }

      final OAuthCredential credential = FacebookAuthProvider.credential(
        result.accessToken!.token,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await FacebookAuth.instance.logOut();
    await _auth.signOut();
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      rethrow;
    }
  }
}


Future<void> showErrorDialog(BuildContext context, String text) async {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("An error has occurred"),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("OK"),
          )
        ],
      );
    },
  );
}

Future<bool> Register(BuildContext context, String email, String password) async {
  try {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Registration successful! Please verify your email.")),
    );

    return true;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      await showErrorDialog(context, "Weak password: ${e.message}");
    } else if (e.code == 'email-already-in-use') {
      await showErrorDialog(context, "This email is already in use.");
    } else {
      await showErrorDialog(context, "Error: ${e.message}");
    }
    return false;
  } catch (e) {
    await showErrorDialog(context, e.toString());
    return false;
  }
} 