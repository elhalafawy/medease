import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:medease/Firebase/Authentication.dart';
import 'package:medease/screens/login_success_widget.dart'; 
import 'verify_email_screen.dart'; 

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Google sign in failed: $e')));
    }
  }

  Future<void> signInWithFacebook(BuildContext context) async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final OAuthCredential credential = FacebookAuthProvider.credential(result.accessToken!.token);
        await FirebaseAuth.instance.signInWithCredential(credential);

        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Facebook sign in failed')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Facebook sign in error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Image.asset(
              'assets/images/login_design.png',
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 250),
                  const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00264D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Good to see you back!  🖤',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _email,
                    decoration: const InputDecoration(
                      hintText: 'username@gmail.com',
                      labelText: 'Email Address',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    obscureText: true,
                    controller: _password,
                    decoration: const InputDecoration(
                      hintText: '************',
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      suffixIcon: Icon(Icons.visibility_off_outlined),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.go('/forgot-password'),
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                     onPressed: () async {
  try {
    final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _email.text.trim(),
      password: _password.text.trim(),
    );

    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.emailVerified) {
      showDialog(
        context: context,
        builder: (_) => const LoginSuccessWidget(),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const VerifyEmailScreen()),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Login failed: $e')),
    );
  }
},

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00264D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () => context.go('/signup'),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF003C5F),
                        ),
                      ),
                    ),
                  ),
              const SizedBox(height: 32),

Row(
  children: [
    Expanded(
      child: Divider(
        color: Colors.grey.shade400,
        thickness: 1,
      ),
    ),
    const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        "Or sign in with",
        style: TextStyle(color: Colors.black54, fontSize: 14),
      ),
    ),
    Expanded(
      child: Divider(
        color: Colors.grey.shade400,
        thickness: 1,
      ),
    ),
  ],
),

const SizedBox(height: 24),

Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    InkWell(
  onTap: () => signInWithFacebook(context),
  borderRadius: BorderRadius.circular(50),
  child: Container(
    width: 50,
    height: 50,
    decoration: BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Image.asset('assets/icons/facebook_icon.png'),
    ),
  ),
),

    const SizedBox(width: 24),
    InkWell(
  onTap: () => signInWithGoogle(context),
  borderRadius: BorderRadius.circular(50),
  child: Container(
    width: 50,
    height: 50,
    decoration: BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Image.asset('assets/icons/google_icon.png'),
    ),
  ),
),

  ],
),

const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
