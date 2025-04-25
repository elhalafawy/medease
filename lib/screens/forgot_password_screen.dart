import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordFlow extends StatefulWidget {
  const ForgotPasswordFlow({super.key});

  @override
  State<ForgotPasswordFlow> createState() => _ForgotPasswordFlowState();
}

class _ForgotPasswordFlowState extends State<ForgotPasswordFlow> {
  int _currentStep = 0;
  final _emailController = TextEditingController();
  final _otpControllers = List.generate(4, (_) => TextEditingController());
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _getStepWidget(),
        ),
      ),
    );
  }

  Widget _getStepWidget() {
    switch (_currentStep) {
      case 0:
        return _buildForgotPassword();
      case 1:
        return _buildEmailVerification();
      case 2:
        return _buildResetPassword();
      case 3:
        return _buildPasswordChanged();
      default:
        return const SizedBox();
    }
  }

  Widget _buildForgotPassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 100),
        const Text('Forgot Password?', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF022E5B))),
        const SizedBox(height: 12),
        const Text('Enter your email address to reset your password', style: TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 24),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            hintText: 'Email Address',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 24),
        _buildMainButton('Submit', () => setState(() => _currentStep = 1)),
        _buildTextButton(),
      ],
    );
  }

  Widget _buildEmailVerification() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 100),
        const Text('Email Verification', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF022E5B))),
        const SizedBox(height: 12),
        const Text('Enter the verification code we sent to your email', style: TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _otpControllers.map((controller) {
            return SizedBox(
              width: 60,
              child: TextField(
                controller: controller,
                maxLength: 1,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  counterText: '',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        _buildMainButton('Submit', () => setState(() => _currentStep = 2)),
        _buildTextButton(),
      ],
    );
  }

  Widget _buildResetPassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 100),
        const Text('Reset Password', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF022E5B))),
        const SizedBox(height: 12),
        const Text('Set your new password to login into your account', style: TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 24),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'New Password',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            suffixIcon: const Icon(Icons.visibility_off),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _confirmController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'Confirm Password',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            suffixIcon: const Icon(Icons.visibility_off),
          ),
        ),
        const SizedBox(height: 24),
        _buildMainButton('Confirm', () => setState(() => _currentStep = 3)),
      ],
    );
  }

  Widget _buildPasswordChanged() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/password_success.png', width: 200),
          const SizedBox(height: 24),
          const Text('Password Changed', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF022E5B))),
          const SizedBox(height: 12),
          const Text('Password changed successfully,\nyou can login again with a new password.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 32),
          _buildMainButton('Verify Account', () => context.go('/login')),
        ],
      ),
    );
  }

  Widget _buildMainButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF022E5B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 0,
        ),
        child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
      ),
    );
  }

  Widget _buildTextButton() {
    return Center(
      child: TextButton(
        onPressed: () => context.go('/login'),
        child: const Text('Back to Login', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF022E5B))),
      ),
    );
  }
}
