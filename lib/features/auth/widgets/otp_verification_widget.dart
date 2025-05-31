import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/supabase/auth_service.dart';

class OtpVerificationWidget extends StatefulWidget {
  final String email;

  const OtpVerificationWidget({super.key, required this.email});

  @override
  State<OtpVerificationWidget> createState() => _OtpVerificationWidgetState();
}

class _OtpVerificationWidgetState extends State<OtpVerificationWidget> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  final AuthService _authService = AuthService();
  bool _isVerifying = false;
  bool _isResending = false;
  int _remainingSeconds = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _remainingSeconds = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  String _maskEmail(String email) {
    var parts = email.split('@');
    if (parts.length != 2) return email;
    var name = parts[0];
    if (name.length <= 3) return email;
    var maskedName = '${name.substring(0, 3)}*****';
    return '$maskedName@${parts[1]}';
  }

  void _onOtpFieldChanged(int index, String value) {
    if (value.length == 1 && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  Future<void> _resendOtp() async {
    if (_remainingSeconds > 0) return;
    
    setState(() => _isResending = true);
    
    try {
      final result = await _authService.sendOtpViaEmail(context, widget.email);
      if (result && mounted) {
        setState(() {
          _isResending = false;
        });
        _startTimer();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  Future<void> _verifyOtp() async {
    String otpCode = _controllers.map((c) => c.text).join();
    
    if (otpCode.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all verification digits')),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      bool result = await _authService.verifyOtpCode(context, widget.email, otpCode);
      
      if (result) {
        if (!mounted) return;
        Navigator.pop(context, true); // Close dialog with success result
        context.go('/home'); // Navigate to home page
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid verification code. Please try again')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/icons/letter.png', 
              height: 70,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.email, size: 60, color: Color(0xFF00264D)),
            ),
            const SizedBox(height: 24),
            const Text(
              'Enter Verification Code',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF00264D)),
            ),
            const SizedBox(height: 12),
            Text(
              'We sent a code to:\n${_maskEmail(widget.email)}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) => _buildOtpField(index)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isVerifying ? null : _verifyOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00264D),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                child: _isVerifying
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2.0,
                        ),
                      )
                    : const Text('Submit', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
            _remainingSeconds > 0
                ? Text('Resend code in $_remainingSeconds seconds', style: const TextStyle(color: Colors.grey))
                : TextButton(
                    onPressed: _isResending ? null : _resendOtp,
                    child: _isResending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Resend Code',
                            style: TextStyle(color: Color(0xFF00264D)),
                          ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpField(int index) {
    return SizedBox(
      width: 50,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        maxLength: 1,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        onChanged: (value) => _onOtpFieldChanged(index, value),
        decoration: const InputDecoration(
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
    );
  }
}
