import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../services/providers.dart';
import 'sign_in_screen.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  final String role;
  const SignUpScreen({super.key, required this.role});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(authProvider.notifier).signUp(
        _emailCtrl.text.trim(),
        _passCtrl.text.trim(),
        _nameCtrl.text.trim(),
        widget.role,
      );
    } catch (e) {
      setState(() {
        _error = e.toString().contains('already registered')
            ? 'This email is already registered.'
            : 'Sign up failed. Please try again.';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          'Qlink',
                          style: TextStyle(
                            fontFamily: 'CenturyGothic',
                            fontSize: 38,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Create Account',
                          style: TextStyle(
                            fontFamily: 'CenturyGothic',
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Starts your safety journey',
                          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),

                  AuthField(
                    hint: 'Full Name',
                    controller: _nameCtrl,
                    prefix: Icons.person_outline,
                    validator: (v) => (v == null || v.isEmpty) ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 12),
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
                  const SizedBox(height: 8),

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
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryNavy,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 22, height: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : Text(
                              isGuardian ? 'Create a Guardian Hub' : 'Create Wearer Account',
                              style: AppTextStyles.buttonText,
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.white.withOpacity(0.3))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('OR', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                      ),
                      Expanded(child: Divider(color: Colors.white.withOpacity(0.3))),
                    ],
                  ),
                  const SizedBox(height: 20),

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

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account? ',
                          style: TextStyle(color: Colors.white.withOpacity(0.7))),
                      GestureDetector(
                        onTap: () => context.go('/auth/signin?role=${widget.role}'),
                        child: const Text(
                          'Sign In',
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
