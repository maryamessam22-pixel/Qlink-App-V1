import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.auth),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 56),
                // Logo
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
                const SizedBox(height: 8),
                const Text(
                  'Welcome to Qlink',
                  style: TextStyle(
                    fontFamily: 'CenturyGothic',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose how you want to use the app.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 48),

                // Guardian Card
                _RoleCard(
                  icon: Icons.shield_outlined,
                  title: 'Guardian',
                  subtitle:
                      'Monitor and protect your loved ones, receive alerts, and track real-time locations.',
                  buttonLabel: 'Continue as Guardian',
                  iconBgColor: const Color(0xFFEEF2FF),
                  iconColor: AppColors.primaryBlue,
                  onTap: () => context.go('/auth/signin?role=guardian'),
                ),

                const SizedBox(height: 16),

                // Wearer Card
                _RoleCard(
                  icon: Icons.watch_outlined,
                  title: 'Wearer',
                  subtitle:
                      'Use the app with your Qlink safety bracelet to stay connected and send emergency alerts.',
                  buttonLabel: 'Continue as Wearer',
                  iconBgColor: const Color(0xFFF3EEFF),
                  iconColor: const Color(0xFF7C3AED),
                  onTap: () => context.go('/auth/signin?role=wearer'),
                ),

                const SizedBox(height: 32),

                // Emergency scan
                GestureDetector(
                  onTap: () => context.go('/guardian/qr-scanner'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.qr_code_scanner, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'PUBLIC EMERGENCY SCAN',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final Color iconBgColor;
  final Color iconColor;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.iconBgColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(height: 1.4),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryNavy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(buttonLabel, style: AppTextStyles.buttonText.copyWith(fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }
}
