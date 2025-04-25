import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:medease/screens/home_screen.dart';
import '../screens/login_screen.dart';
import 'firebase_options.dart';

Future<void> showErrorDialog(BuildContext context, String text,)async {
  return showDialog(context: context, builder: (context){
    return AlertDialog(
      title: const Text("An error has occurred"),
      content: Text(text),
      actions: [
        TextButton(onPressed: (){
          Navigator.of(context).pop();
        }, child: const Text("OK"))
      ],
    );

  });
}

void Register(context, email, password) async {
  try {
    List<String> signInMethods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
    final userCredential = FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password).toString();
    final user = FirebaseAuth.instance.currentUser;
    user?.sendEmailVerification();
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginScreen(),));
  }
  // Exception
  on FirebaseException catch(e){
  if (e.code == 'weak-password'){ showErrorDialog(context, "Weak password $e");}
  else {  showErrorDialog(context, "Error${e.code}"); }
   showErrorDialog(context, "bad ${e.code}");
  } catch(e){ showErrorDialog(context, e.toString()); }
}

void Login (context, email, password){
  try{
    final userCredential = FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null){
      // Checks if email is verified
      if(!user.emailVerified){
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const HomeScreen(),));
        showErrorDialog(context, "Signed in");
      showErrorDialog(context, "Email is not verified");
        FirebaseAuth.instance.signOut();
      } else{showErrorDialog(context, "Email is verified"); FirebaseAuth.instance.signOut();}
    } else {showErrorDialog(context, "Wrong credentials");}
    // Error exceptions
  } on FirebaseAuthException catch(e){
    if (e.code == 'user-not-found'){  showErrorDialog(context, "User not found"); }
    else if (e.code == "Wrong password") { showErrorDialog(context,"Wrong password\n$e");}
    else {  showErrorDialog(context,"22222222222222222222\n$e"); }
  }
}

void logout(context){
  FirebaseAuth.instance.signOut();
}