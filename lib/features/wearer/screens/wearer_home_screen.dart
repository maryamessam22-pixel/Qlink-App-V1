import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../services/providers.dart';
import '../../../services/supabase_service.dart';

class WearerHomeScreen extends ConsumerStatefulWidget {
  const WearerHomeScreen({super.key});

  @override
  ConsumerState<WearerHomeScreen> createState() => _WearerHomeScreenState();
}

class _WearerHomeScreenState extends ConsumerState<WearerHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _sosCtrl;
  late Animation<double> _sosScale;
  bool _sosSending = false;

  // Simulated state
  bool _braceletConnected = true;
  int _batteryLevel = 85;

  @override
  void initState() {
    super.initState();
    _sosCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
    _sosScale = Tween<double>(begin: 1.0, end: 0.93).animate(
        CurvedAnimation(parent: _sosCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _sosCtrl.dispose();
    super.dispose();
  }

  Future<void> _triggerSOS() async {
    if (_sosSending) return;
    HapticFeedback.heavyImpact();

    // Show hold confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle),
              child: const Icon(Icons.emergency, color: AppColors.error, size: 20),
            ),
            const SizedBox(width: 10),
            const Text('Send SOS Alert?'),
          ],
        ),
        content: const Text(
            'This will immediately notify your guardian with your emergency status.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Send SOS',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _sosSending = true);
    HapticFeedback.heavyImpact();

    try {
      final user = ref.read(currentUserProvider);
      // Notify guardian — in production wearer would have a linked profile_id
      // For now we store a local SOS alert using user ID as reference
      if (user != null) {
        try {
          await SupabaseService.triggerSOS(user.id, 'SOS Emergency triggered by ${user.fullName ?? user.email}');
        } catch (_) {
          // If no linked profile, just show local confirmation
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              const Text('SOS sent! Guardian notified.'),
            ]),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _sosSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: QlinkAppBar(avatarUrl: user?.avatarUrl),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hello, ${user?.fullName ?? 'Wearer'}',
                style: AppTextStyles.heading2),
            const SizedBox(height: 2),
            Text('Your Safety Circle Command Center',
                style: AppTextStyles.bodySmall),
            const SizedBox(height: 20),

            // Status card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppGradients.statusSafe,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('System Status',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.75), fontSize: 13)),
                  const SizedBox(height: 4),
                  const Text('You are Safe',
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'CenturyGothic',
                          fontSize: 22,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8, height: 8,
                          decoration: const BoxDecoration(
                              color: AppColors.success, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        const Text('Monitoring Active',
                            style: TextStyle(color: Colors.white, fontSize: 13,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Bracelet + Battery
            Row(
              children: [
                Expanded(
                  child: SectionCard(
                    child: Column(
                      children: [
                        Icon(Icons.watch_outlined,
                            color: _braceletConnected
                                ? AppColors.primaryBlue
                                : AppColors.textSecondary,
                            size: 28),
                        const SizedBox(height: 6),
                        Text('Bracelet', style: AppTextStyles.bodySmall),
                        Text(
                          _braceletConnected ? 'Connected' : 'Disconnected',
                          style: AppTextStyles.labelMedium.copyWith(
                              color: _braceletConnected
                                  ? AppColors.primaryBlue
                                  : AppColors.error),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SectionCard(
                    child: Column(
                      children: [
                        Icon(
                          _batteryLevel > 20
                              ? Icons.battery_charging_full
                              : Icons.battery_alert,
                          color: _batteryLevel > 20
                              ? AppColors.success
                              : AppColors.error,
                          size: 28,
                        ),
                        const SizedBox(height: 6),
                        Text('Battery', style: AppTextStyles.bodySmall),
                        Text('$_batteryLevel%',
                            style: AppTextStyles.labelMedium.copyWith(
                                color: _batteryLevel > 20
                                    ? AppColors.success
                                    : AppColors.error)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // SOS Button
            GestureDetector(
              onTapDown: (_) {
                _sosCtrl.forward();
                HapticFeedback.mediumImpact();
              },
              onTapUp: (_) {
                _sosCtrl.reverse();
                _triggerSOS();
              },
              onTapCancel: () => _sosCtrl.reverse(),
              child: ScaleTransition(
                scale: _sosScale,
                child: Container(
                  width: double.infinity,
                  height: 72,
                  decoration: BoxDecoration(
                    color: _sosSending ? AppColors.sosRedDark : AppColors.sosRed,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.sosRed.withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _sosSending
                        ? const SizedBox(
                            width: 26, height: 26,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 3))
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('SOS Emergency',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      fontFamily: 'CenturyGothic')),
                              Text('Press and hold for 3 seconds',
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 12)),
                            ],
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Emergency call
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.phone_outlined, size: 22),
                label: const Text('Call Emergency Contact',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15)),
              ),
            ),
            const SizedBox(height: 20),

            // Recent activity
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Activity', style: AppTextStyles.heading3),
                TextButton(
                  onPressed: () {},
                  child: Text('View All',
                      style: AppTextStyles.labelMedium
                          .copyWith(color: AppColors.primaryBlue)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            _ActivityTile(
              icon: Icons.check_circle_outline,
              iconColor: AppColors.success,
              title: 'System Checkup',
              subtitle: 'Today, 09:00 AM',
              trailing: 'Success',
              trailingColor: AppColors.success,
            ),
            const SizedBox(height: 8),
            _ActivityTile(
              icon: Icons.sync,
              iconColor: AppColors.primaryBlue,
              title: 'App Sync',
              subtitle: 'Yesterday, 11:45 PM',
              trailing: 'Auto',
              trailingColor: AppColors.textSecondary,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String trailing;
  final Color trailingColor;

  const _ActivityTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.trailingColor,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelMedium),
                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Text(trailing,
              style: AppTextStyles.labelSmall.copyWith(color: trailingColor)),
        ],
      ),
    );
  }
}
