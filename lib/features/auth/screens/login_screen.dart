import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/supabase/auth_service.dart';
import 'forgot_password_screen.dart';
import '../widgets/otp_verification_dialog.dart';
import 'package:medease/features/auth/widgets/login_success_widget.dart';
import 'package:medease/core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  final String? initialEmail;

  const LoginScreen({
    super.key,
    this.initialEmail,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  final bool _isForgotPasswordFlow = false;
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isOtpLoginMode = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null) {
      _email.text = widget.initialEmail!;
      _isOtpLoginMode = false;
    }
  }

  void _showForgotPasswordFlow() {
    showDialog(
      context: context,
      builder: (context) => ForgotPasswordScreen(),
    );
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      await _authService.signInWithGoogle();
      // Supabase handles navigation after OAuth, you may need to listen to onAuthStateChange elsewhere
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Google sign in failed: $e')));
    }
  }

  Future<void> signInWithEmailPassword(BuildContext context) async {
    try {
      final role = await _authService.loginAndGetRole(
        _email.text.trim(),
        _password.text.trim(),
      );
      if (role == 'doctor') {
        context.go('/doctor-dashboard');
      } else if (role == 'patient') {
        context.go('/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed: User not found or role undefined.')),
        );
      }
    } on AuthException catch (e) {
      // عرض رسالة خاصة في حالة عدم تأكيد البريد الإلكتروني
      if (e.message.contains('Email not confirmed')) {
        print("AuthException for unverified email: ${e.message}");
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => OtpVerificationDialog(
            email: _email.text.trim(),
            isLoginOtp: true,
          ),
        );
      } else {
        print("Other AuthException: ${e.message}");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login error: $e')));
    }
  }

  Future<void> _sendOtpForLogin() async {
    if (_email.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address.')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _authService.sendLoginOtp(_email.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP sent to your email. Please check your inbox.')),
      );
      // Show OTP verification dialog after sending OTP
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => OtpVerificationDialog(
          email: _email.text.trim(),
          isLoginOtp: true,
        ),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error sending OTP: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.kPaddingXLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 250),
                  Text(
                    'Login',
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                  ),
                  const SizedBox(height: AppTheme.kPaddingSmall),
                  Text(
                    'Good to see you back!  🖤',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                  ),
                  const SizedBox(height: AppTheme.kPaddingXLarge),
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'username@gmail.com',
                      labelText: 'Email Address',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.kBorderRadiusMedium),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.kBorderRadiusMedium),
                        borderSide: BorderSide(color: theme.colorScheme.outline, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.kBorderRadiusMedium),
                        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                      ),
                      labelStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                    ),
                  ),
                  const SizedBox(height: AppTheme.kPaddingLarge),
                  if (!_isOtpLoginMode)
                    TextField(
                      obscureText: !_isPasswordVisible, 
                      controller: _password,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off_outlined, 
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible; 
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.kBorderRadiusMedium),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.kBorderRadiusMedium),
                          borderSide: BorderSide(color: theme.colorScheme.outline, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.kBorderRadiusMedium),
                          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                        ),
                        labelStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                      ),
                    ),
                  if (!_isOtpLoginMode) const SizedBox(height: AppTheme.kPaddingSmall),
                  if (!_isOtpLoginMode)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _showForgotPasswordFlow,  
                        child: Text(
                          'Forgot password?',
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary),
                        ),
                      ),
                    ),
                  const SizedBox(height: AppTheme.kPaddingXLarge),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isOtpLoginMode ? _sendOtpForLogin : () async {
                        await signInWithEmailPassword(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.kBorderRadiusLarge),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: AppTheme.kPaddingMedium),
                      ),
                      child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(
                        _isOtpLoginMode ? 'Send OTP' : 'Login',
                        style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.kPaddingMedium),
                  Center(
                    child: TextButton(
                      onPressed: () => context.go('/register'),
                      child: Text(
                        'Sign Up',
                        style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.kPaddingSmall),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _isOtpLoginMode = !_isOtpLoginMode;
                          _password.clear();
                        });
                      },
                      child: Text(
                        _isOtpLoginMode ? 'Login with Password' : 'Login with OTP',
                        style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.kPaddingXLarge),
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: theme.dividerColor,
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppTheme.kPaddingSmall),
                        child: Text(
                          "Or sign in with",
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: theme.dividerColor,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.kPaddingXLarge),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () => signInWithGoogle(context),
                        borderRadius: BorderRadius.circular(AppTheme.kBorderRadiusXLarge),
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: theme.dividerColor),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(AppTheme.kPaddingSmall + 2),
                            child: Image.asset('assets/icons/google_icon.png'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.kPaddingXLarge),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
