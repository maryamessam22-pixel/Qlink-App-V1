import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../services/providers.dart';
import '../../../services/supabase_service.dart';

class GuardianSettingsScreen extends ConsumerWidget {
  const GuardianSettingsScreen({super.key});

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

          // Profile section
          SettingsGroup(
            title: 'Profile',
            items: [
              SettingsTile(
                icon: Icons.person_outline,
                label: 'Edit Profile',
                onTap: () => _showEditProfile(context, ref),
              ),
              SettingsTile(
                icon: Icons.lock_outline,
                label: 'Change Password',
                onTap: () => _showChangePassword(context, ref),
              ),
              SettingsTile(
                icon: Icons.email_outlined,
                label: 'Email Preferences',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Role section
          SettingsGroup(
            title: 'Role',
            items: [
              SettingsTile(
                icon: Icons.shield_outlined,
                label: 'Current Role: Guardian',
                subtitle: 'Guardian Account',
                subtitleColor: AppColors.primaryBlue,
                trailing: const SizedBox.shrink(),
              ),
              SettingsTile(
                icon: Icons.swap_horiz,
                label: 'Switch Role',
                onTap: () => _switchRole(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Security
          SettingsGroup(
            title: 'Security',
            items: [
              SettingsTile(
                icon: Icons.fingerprint,
                label: 'Biometric Lock',
                trailing: Switch(
                  value: true,
                  onChanged: (_) {},
                  activeColor: AppColors.primaryBlue,
                ),
              ),
              SettingsTile(
                icon: Icons.timer_outlined,
                label: 'Auto Lock',
                trailing: Text('5 MINUTES',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.primaryBlue)),
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),

          // App Preferences
          SettingsGroup(
            title: 'App Preferences',
            items: [
              SettingsTile(
                icon: Icons.notifications_outlined,
                label: 'Notification',
                subtitle: 'ACTIVE: QLINK PRO V2',
                subtitleColor: AppColors.success,
                onTap: () {},
              ),
              SettingsTile(
                icon: Icons.language_outlined,
                label: 'Language',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Data
          SettingsGroup(
            title: 'Data',
            items: [
              SettingsTile(
                icon: Icons.qr_code_outlined,
                label: 'QR Scan History',
                onTap: () {},
              ),
              SettingsTile(
                icon: Icons.download_outlined,
                label: 'Data Export',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Privacy
          SettingsGroup(
            title: 'Privacy Policy',
            items: [
              SettingsTile(
                icon: Icons.policy_outlined,
                label: 'Privacy Policy',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Support
          SettingsGroup(
            title: 'Support',
            items: [
              SettingsTile(
                icon: Icons.help_outline,
                label: 'Help Center',
                onTap: () {},
              ),
              SettingsTile(
                icon: Icons.info_outline,
                label: 'App Version',
                trailing: Text('v2.4.0 (Guardian Edition)',
                    style: AppTextStyles.bodySmall),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Logout
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () => _confirmLogout(context, ref),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
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

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) context.go('/auth/role');
            },
            child: const Text('Logout',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _switchRole(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Switch Role'),
        content: const Text('Switch to Wearer mode?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authProvider.notifier).updateProfile(role: 'wearer');
              if (context.mounted) context.go('/wearer');
            },
            child: const Text('Switch'),
          ),
        ],
      ),
    );
  }

  void _showEditProfile(BuildContext context, WidgetRef ref) {
    final user = ref.read(currentUserProvider);
    final nameCtrl = TextEditingController(text: user?.fullName ?? '');
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edit Profile', style: AppTextStyles.heading3),
            const SizedBox(height: 16),
            AppTextField(
              hint: 'Full Name',
              label: 'Full Name',
              controller: nameCtrl,
            ),
            const SizedBox(height: 16),
            GradientButton(
              label: 'Save Changes',
              onTap: () async {
                await ref
                    .read(authProvider.notifier)
                    .updateProfile(fullName: nameCtrl.text.trim());
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePassword(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Change Password', style: AppTextStyles.heading3),
            const SizedBox(height: 16),
            AppTextField(
              hint: 'New Password',
              label: 'New Password',
              controller: ctrl,
              obscureText: true,
            ),
            const SizedBox(height: 16),
            GradientButton(
              label: 'Update Password',
              onTap: () async {
                if (ctrl.text.length >= 6) {
                  await SupabaseService.changePassword(ctrl.text);
                  if (context.mounted) Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const SettingsGroup({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: AppTextStyles.labelMedium
                .copyWith(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Column(
            children: items.asMap().entries.map((e) {
              final isLast = e.key == items.length - 1;
              return Column(
                children: [
                  e.value,
                  if (!isLast)
                    const Divider(
                        height: 1, indent: 52, color: AppColors.borderColor),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color? subtitleColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingsTile({
    required this.icon,
    required this.label,
    this.subtitle,
    this.subtitleColor,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primaryBlue, size: 18),
      ),
      title: Text(label, style: AppTextStyles.bodyMedium),
      subtitle: subtitle != null
          ? Text(subtitle!,
              style: AppTextStyles.labelSmall
                  .copyWith(color: subtitleColor ?? AppColors.textSecondary))
          : null,
      trailing: trailing ??
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
    );
  }
}
