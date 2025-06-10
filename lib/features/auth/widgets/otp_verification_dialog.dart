import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medease/core/supabase/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:medease/features/auth/widgets/login_success_widget.dart';
import 'package:medease/core/theme/app_theme.dart';

class OtpVerificationDialog extends StatefulWidget {
  final String email;
  final bool isLoginOtp;
  final String? fullName;
  final String? gender;
  final String? dateOfBirth;
  final String? phone;

  const OtpVerificationDialog({
    Key? key, 
    required this.email,
    this.isLoginOtp = false,
    this.fullName,
    this.gender,
    this.dateOfBirth,
    this.phone,
  }) : super(key: key);

  @override
  State<OtpVerificationDialog> createState() => _OtpVerificationDialogState();
}

class _OtpVerificationDialogState extends State<OtpVerificationDialog> {
  final List<TextEditingController> _otpControllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final AuthService _authService = AuthService();
  Timer? _timer;
  int _resendCountdown = 60;
  bool _canResend = false;
  bool _isLoading = false;

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name = parts[0];
    if (name.length <= 2) return email;
    return name.substring(0, 2) + '***@' + parts[1];
  }

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _resendCountdown = 60;
      _canResend = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        setState(() {
          _canResend = true;
          timer.cancel();
        });
      }
    });
  }

  String get _otp => _otpControllers.map((controller) => controller.text).join();

  Future<void> _verifyOtp() async {
    if (_otp.isEmpty || _otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit OTP')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final AuthResponse response = await _authService.verifyOtp(
        widget.email,
        _otp,
      );

      if (response.user != null) {
        if (!mounted) return;
        await _authService.ensurePatientRowExists(
          response.user!,
          email: widget.email,
          fullName: widget.fullName,
          gender: widget.gender,
          dateOfBirth: widget.dateOfBirth,
          phone: widget.phone,
        );
        Navigator.of(context).pop();
        
        if (widget.isLoginOtp) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login successful!')),
          );
          context.go('/home');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email confirmed successfully! Please login with your password.')),
          );
          context.go('/login', extra: widget.email);
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP verification failed. Please try again.')),
        );
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resendOtp() async {
    setState(() => _isLoading = true);
    try {
      await _authService.resendOtp(widget.email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP sent again. Please check your inbox.')),
      );
      _startResendTimer();
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error resending OTP: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.kBorderRadiusXLarge)),
      elevation: AppTheme.kElevationMedium,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.kPaddingXLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/icons/letter.png',
              height: 80,
            ),
            const SizedBox(height: AppTheme.kPaddingLarge),
            Text(
              widget.isLoginOtp ? 'Login with OTP' : 'Verify Your Email',
              style: theme.textTheme.headlineMedium?.copyWith(color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: AppTheme.kPaddingSmall),
            Text(
              widget.isLoginOtp
                  ? 'Enter the 6-digit OTP sent to ${_maskEmail(widget.email)} to login.'
                  : 'A 6-digit OTP has been sent to ${_maskEmail(widget.email)}. Please enter it below to verify your email.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
            ),
            const SizedBox(height: AppTheme.kPaddingLarge),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 40,
                  child: TextFormField(
                    controller: _otpControllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    style: theme.textTheme.headlineLarge?.copyWith(color: theme.colorScheme.primary),
                    decoration: InputDecoration(
                      counterText: "",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.kBorderRadiusMedium),
                        borderSide: BorderSide(color: theme.colorScheme.outline, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.kBorderRadiusMedium),
                        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: AppTheme.kPaddingMedium, horizontal: AppTheme.kPaddingSmall),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        if (index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else {
                          _focusNodes[index].unfocus();
                          _verifyOtp();
                        }
                      } else if (value.isEmpty && index > 0) {
                        _focusNodes[index - 1].requestFocus();
                      }
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: AppTheme.kPaddingLarge),
            _isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.kBorderRadiusLarge)),
                      ),
                      child: Text(
                        'Verify',
                        style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimary),
                      ),
                    ),
                  ),
            const SizedBox(height: AppTheme.kPaddingMedium),
            TextButton(
              onPressed: _canResend ? _resendOtp : null,
              child: Text(
                _canResend
                    ? 'Resend OTP'
                    : 'Resend in $_resendCountdown s',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: _canResend ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 