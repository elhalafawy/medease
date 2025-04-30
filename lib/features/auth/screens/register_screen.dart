import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../widgets/otp_verification_widget.dart';
import '../../../core/firebase/auth_service.dart';
import 'verify_email_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _authServiceProvider = AuthServiceProvider();
  bool _agreeToTerms = false;
  bool _isPasswordVisible = false;
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _birthdate = TextEditingController();

  // Registration Method
  Future<void> registerUser() async {
    try {
      await _authServiceProvider.registerWithEmailAndPassword(
        _email.text.trim(),
        _password.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration successful! Please verify your email.")),
      );

      // Show OTP Verification widget after registration
      showDialog(
        context: context,
        builder: (_) => OtpVerificationWidget(email: _email.text.trim()),
      );

    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        await showErrorDialog(context, "Weak password: ${e.message}");
      } else if (e.code == 'email-already-in-use') {
        await showErrorDialog(context, "This email is already in use.");
      } else {
        await showErrorDialog(context, "Error: ${e.message}");
      }
    } catch (e) {
      await showErrorDialog(context, e.toString());
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Image.asset(
              'assets/images/createacc_design.png',
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
                  const SizedBox(height: 60),
                  Text(
                    'Create Account',
                    style: theme.textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _email,
                    decoration: const InputDecoration(
                      hintText: 'username@gmail.com',
                      labelText: 'Email Address',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _username,
                    decoration: const InputDecoration(
                      hintText: 'username',
                      labelText: 'User Name',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                    ),
                    value: 'Male',
                    items: const [
                      DropdownMenuItem(value: 'Male', child: Text('Male')),
                      DropdownMenuItem(value: 'Female', child: Text('Female')),
                    ],
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _birthdate,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Birthdate',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today_outlined),
                        onPressed: () async {
                          DateTime? selectedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (selectedDate != null) {
                            _birthdate.text = "${selectedDate.toLocal()}".split(' ')[0];
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    obscureText: !_isPasswordVisible,
                    controller: _password,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Checkbox(
                        value: _agreeToTerms,
                        onChanged: (val) {
                          setState(() {
                            _agreeToTerms = val ?? false;
                          });
                        },
                      ),
                      const Text("I agree to the Terms and Conditions"),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _agreeToTerms
                          ? () async {
                              await Register(
                                context,
                                _email.text.trim(),
                                _password.text.trim(),
                              );
                            }
                          : null,
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text(
                        'Log In',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
