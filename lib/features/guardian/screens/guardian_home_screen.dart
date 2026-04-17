import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../models/models.dart';
import '../../../services/providers.dart';

class GuardianHomeScreen extends ConsumerStatefulWidget {
  const GuardianHomeScreen({super.key});

  @override
  ConsumerState<GuardianHomeScreen> createState() => _GuardianHomeScreenState();
}

class _GuardianHomeScreenState extends ConsumerState<GuardianHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      ref.read(profilesNotifierProvider.notifier).load(user.id);
      ref.read(alertsProvider.notifier).load(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final profilesAsync = ref.watch(profilesNotifierProvider);
    final unread = ref.watch(unreadAlertsCountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: QlinkAppBar(
        avatarUrl: user?.avatarUrl,
        unreadAlerts: unread,
        onAlertTap: () => context.push('/guardian/alerts'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        color: AppColors.primaryBlue,
        child: profilesAsync.when(
          loading: () => const AppLoadingWidget(),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (profiles) => _buildBody(context, user, profiles),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AppUser? user, List<Profile> profiles) {
    final connectedCount = profiles.where((p) => p.isConnected).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Greeting
        Text('Hello, ${user?.fullName ?? 'Guardian'}',
            style: AppTextStyles.heading2),
        const SizedBox(height: 2),
        Text('Your Safety Circle Command Center',
            style: AppTextStyles.bodySmall),
        const SizedBox(height: 20),

        // Stats row
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.watch_outlined,
                count: connectedCount,
                label: 'Active Devices',
                color: AppColors.primaryBlue,
                tag: connectedCount == 0 ? 'OFFLINE' : null,
                tagColor: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.people_alt_outlined,
                count: profiles.length,
                label: 'Protected Members',
                color: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // System status
        SectionCard(
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle_outline,
                    color: AppColors.success, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('System Status',
                        style: AppTextStyles.labelMedium
                            .copyWith(color: AppColors.success)),
                    const SizedBox(height: 2),
                    Text(
                      profiles.isEmpty
                          ? 'No devices connected till now. No alerts detected.'
                          : '${profiles.length} profile(s) monitored. System active.',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Profiles list (if any)
        if (profiles.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Protected Member', style: AppTextStyles.heading3),
              TextButton(
                onPressed: () => context.push('/guardian/add-profile'),
                child: Text('+ Add Member',
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.primaryBlue)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...profiles.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ProfileCard(profile: p),
              )),
          const SizedBox(height: 8),
        ],

        // CTA cards
        if (profiles.isEmpty)
          _CtaCard(
            title: 'Create a Profile',
            subtitle:
                'Create a medical ID for a loved one to activate their emergency QR protection immediately.',
            buttonLabel: '+ Add First Profile',
            gradient: const LinearGradient(
              colors: [Color(0xFF01A86F), Color(0xFF00C982)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onTap: () => context.push('/guardian/add-profile'),
          )
        else
          _CtaCard(
            title: 'Connect a Bracelet',
            subtitle:
                'Pair a Qlink bracelet to start protecting your loved ones in real time and expand your safety circle.',
            buttonLabel: '+ Add First Bracelet',
            gradient: AppGradients.card,
            onTap: () => context.push('/guardian/add-profile'),
          ),

        const SizedBox(height: 16),

        // Recent activity
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Activity', style: AppTextStyles.heading3),
            TextButton(
              onPressed: () => context.push('/guardian/alerts'),
              child: Text('See all',
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.primaryBlue)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SectionCard(
          child: const EmptyStateWidget(
            icon: Icons.history,
            title: 'No activity yet',
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;
  final Color color;
  final String? tag;
  final Color? tagColor;

  const _StatCard({
    required this.icon,
    required this.count,
    required this.label,
    required this.color,
    this.tag,
    this.tagColor,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              if (tag != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (tagColor ?? AppColors.textSecondary).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(tag!,
                      style: TextStyle(
                          color: tagColor ?? AppColors.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text('$count',
              style: AppTextStyles.heading2.copyWith(color: color, fontSize: 24)),
          Text(label, style: AppTextStyles.bodySmall.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _ProfileCard extends ConsumerWidget {
  final Profile profile;
  const _ProfileCard({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SectionCard(
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryNavy,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: profile.avatarUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(profile.avatarUrl!, fit: BoxFit.cover),
                      )
                    : Center(
                        child: Text(
                          profile.initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile.name, style: AppTextStyles.labelMedium),
                    Text(profile.relationship ?? 'Member',
                        style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              if (profile.isConnected)
                StatusBadge(label: 'Active', color: AppColors.success)
              else
                StatusBadge(
                    label: 'No Device',
                    color: AppColors.textSecondary,
                    textColor: AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.push('/guardian/profile/${profile.id}'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryBlue),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text('View Profile',
                      style: AppTextStyles.labelMedium
                          .copyWith(color: AppColors.primaryBlue)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      context.push('/guardian/add-profile?profileId=${profile.id}&step=3'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF7C3AED)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text(
                    profile.hasDevice ? 'Manage Device' : '+ Add Device',
                    style: AppTextStyles.labelMedium
                        .copyWith(color: const Color(0xFF7C3AED)),
                  ),
                ),
              ),
            ],
          ),
          if (profile.isConnected) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Home · Just now',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary)),
            ),
          ],
        ],
      ),
    );
  }
}

class _CtaCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonLabel;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _CtaCard({
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 17)),
          const SizedBox(height: 8),
          Text(subtitle,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.85), fontSize: 13, height: 1.4)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22)),
                foregroundColor: Colors.white,
              ),
              child: Text(buttonLabel,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
