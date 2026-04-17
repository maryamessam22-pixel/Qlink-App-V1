import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../services/providers.dart';
import '../../guardian/screens/guardian_settings_screen.dart';

class WearerSettingsScreen extends ConsumerWidget {
  const WearerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: QlinkAppBar(avatarUrl: user?.avatarUrl),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Settings', style: AppTextStyles.heading2),
              Text('Security & Preferences', style: AppTextStyles.bodySmall),
            ],
          ),
          const SizedBox(height: 20),

          // Profile
          SettingsGroup(title: 'Profile', items: [
            SettingsTile(
              icon: Icons.person_outline,
              label: 'Edit Profile',
              onTap: () => _showEditProfile(context, ref),
            ),
            SettingsTile(
              icon: Icons.lock_outline,
              label: 'Change Password',
              onTap: () {},
            ),
            SettingsTile(
              icon: Icons.email_outlined,
              label: 'Email Preferences',
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 16),

          // Role
          SettingsGroup(title: 'Role', items: [
            SettingsTile(
              icon: Icons.watch_outlined,
              label: 'Current Role: Wearer',
              subtitle: 'Wearer Account',
              subtitleColor: const Color(0xFF7C3AED),
              trailing: const SizedBox.shrink(),
            ),
            SettingsTile(
              icon: Icons.swap_horiz,
              label: 'Switch to Guardian',
              onTap: () async {
                await ref.read(authProvider.notifier).updateProfile(role: 'guardian');
                if (context.mounted) context.go('/guardian');
              },
            ),
          ]),
          const SizedBox(height: 16),

          // Bracelet
          SettingsGroup(title: 'Bracelet', items: [
            SettingsTile(
              icon: Icons.search,
              label: 'Find My Bracelet',
              onTap: () => context.push('/wearer/find-bracelet'),
            ),
            SettingsTile(
              icon: Icons.qr_code_scanner,
              label: 'Scan QR Code',
              onTap: () => context.push('/wearer/qr-scanner'),
            ),
            SettingsTile(
              icon: Icons.history,
              label: 'QR Scan History',
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 16),

          // Data
          SettingsGroup(title: 'Data', items: [
            SettingsTile(
              icon: Icons.download_outlined,
              label: 'Data Export',
              onTap: () {},
            ),
            SettingsTile(
              icon: Icons.policy_outlined,
              label: 'Privacy Policy',
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 16),

          // Support
          SettingsGroup(title: 'Support', items: [
            SettingsTile(
              icon: Icons.help_outline,
              label: 'Help Center',
              onTap: () {},
            ),
            SettingsTile(
              icon: Icons.info_outline,
              label: 'App Version',
              trailing: Text('v2.4.0 (Wearer Edition)',
                  style: AppTextStyles.bodySmall),
            ),
          ]),
          const SizedBox(height: 20),

          // Logout
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () async {
                await ref.read(authProvider.notifier).signOut();
                if (context.mounted) context.go('/auth/role');
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.logout, color: AppColors.error, size: 20),
              label: const Text('Logout',
                  style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                      fontSize: 16)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showEditProfile(BuildContext context, WidgetRef ref) {
    final user = ref.read(currentUserProvider);
    final ctrl = TextEditingController(text: user?.fullName ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Edit Profile', style: AppTextStyles.heading3),
            const SizedBox(height: 16),
            AppTextField(hint: 'Full Name', label: 'Full Name', controller: ctrl),
            const SizedBox(height: 16),
            GradientButton(
              label: 'Save',
              onTap: () async {
                await ref.read(authProvider.notifier).updateProfile(fullName: ctrl.text.trim());
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
