import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
