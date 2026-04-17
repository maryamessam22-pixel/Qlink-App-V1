import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../services/providers.dart';

class SignInScreen extends ConsumerStatefulWidget {
  final String role;
  const SignInScreen({super.key, required this.role});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(authProvider.notifier).signIn(
        _emailCtrl.text.trim(),
        _passCtrl.text.trim(),
      );
    } catch (e) {
      setState(() { _error = _friendlyError(e.toString()); });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _friendlyError(String e) {
    if (e.contains('Invalid login')) return 'Incorrect email or password.';
    if (e.contains('Email not confirmed')) return 'Please verify your email first.';
    if (e.contains('network')) return 'Network error. Check your connection.';
    return 'Sign in failed. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final isGuardian = widget.role == 'guardian';
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.auth),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 48),
                  const Text(
                    'Qlink',
                    style: TextStyle(
                      fontFamily: 'CenturyGothic',
                      fontSize: 42,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isGuardian ? 'Guardian Hub' : 'Wearer Access',
                    style: const TextStyle(
                      fontFamily: 'CenturyGothic',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Secure Access Required',
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                  ),
                  const SizedBox(height: 40),

                  // Email
                  AuthField(
                    hint: 'Email address',
                    controller: _emailCtrl,
                    prefix: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Email is required';
                      if (!v.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Password
                  AuthField(
                    hint: 'Password',
                    controller: _passCtrl,
                    prefix: Icons.lock_outline,
                    obscure: _obscure,
                    suffix: GestureDetector(
                      onTap: () => setState(() => _obscure = !_obscure),
                      child: Icon(
                        _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: Colors.white54,
                        size: 20,
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Password is required';
                      if (v.length < 6) return 'Min 6 characters';
                      return null;
                    },
                  ),

                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  if (_error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.error.withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(_error!,
                                style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  const SizedBox(height: 8),

                  // Sign In Button (no gradient on auth screen)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _signIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryNavy,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5),
                            )
                          : Text('Sign In', style: AppTextStyles.buttonText),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // OR divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.white.withOpacity(0.3))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('OR',
                            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                      ),
                      Expanded(child: Divider(color: Colors.white.withOpacity(0.3))),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Social buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SocialBtn(icon: Icons.facebook, color: const Color(0xFF1877F2)),
                      const SizedBox(width: 16),
                      SocialBtn(icon: Icons.g_mobiledata, color: Colors.white),
                      const SizedBox(width: 16),
                      SocialBtn(icon: Icons.apple, color: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Emergency scan
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.white.withOpacity(0.3))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('EMERGENCY',
                            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11)),
                      ),
                      Expanded(child: Divider(color: Colors.white.withOpacity(0.3))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/guardian/qr-scanner'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      icon: const Icon(Icons.qr_code_scanner, size: 20),
                      label: const Text(
                        'PUBLIC EMERGENCY SCAN',
                        style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sign up link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('New to Qlink? ',
                          style: TextStyle(color: Colors.white.withOpacity(0.7))),
                      GestureDetector(
                        onTap: () => context.go('/auth/signup?role=${widget.role}'),
                        child: const Text(
                          'Create Account',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AuthField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final IconData prefix;
  final bool obscure;
  final Widget? suffix;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const AuthField({
    required this.hint,
    required this.controller,
    required this.prefix,
    this.obscure = false,
    this.suffix,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        prefixIcon: Icon(prefix, color: Colors.white54, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white.withOpacity(0.12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
    );
  }
}

class SocialBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  const SocialBtn({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: Icon(icon, color: color, size: 26),
    );
  }
}
