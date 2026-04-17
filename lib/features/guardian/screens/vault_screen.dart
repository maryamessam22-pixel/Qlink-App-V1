import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../models/models.dart';
import '../../../services/providers.dart';
import '../../../services/supabase_service.dart';

// ─── Main Vault Screen ────────────────────────────────────────────────────────
class VaultScreen extends ConsumerStatefulWidget {
  const VaultScreen({super.key});

  @override
  ConsumerState<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends ConsumerState<VaultScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        ref.read(profilesNotifierProvider.notifier).load(user.id);
      }
    });
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
        title: 'Vault',
        unreadAlerts: unread,
        onAlertTap: () => context.push('/guardian/alerts'),
      ),
      body: profilesAsync.when(
        loading: () => const AppLoadingWidget(),
        error: (e, _) => Center(child: Text('$e')),
        data: (profiles) => _buildBody(profiles),
      ),
    );
  }

  Widget _buildBody(List<Profile> profiles) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Search
        TextField(
          controller: _searchCtrl,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Search records or profiles',
            prefixIcon:
                const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryBlue),
            ),
          ),
        ),
        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Monitored Profiles', style: AppTextStyles.heading3),
                Text('${profiles.length} active medical profiles linked',
                    style: AppTextStyles.bodySmall),
              ],
            ),
            TextButton(
              onPressed: () {},
              child: Text('View All',
                  style:
                      AppTextStyles.labelMedium.copyWith(color: AppColors.primaryBlue)),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (profiles.isEmpty)
          SectionCard(
            child: EmptyStateWidget(
              icon: Icons.lock_outline,
              title: 'No profiles yet',
              subtitle: 'Add a profile to start storing medical records',
              action: GradientButton(
                label: 'Add Profile',
                onTap: () => context.push('/guardian/add-profile'),
                width: 160,
              ),
            ),
          )
        else
          ...profiles.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _VaultProfileCard(profile: p),
              )),

        const SizedBox(height: 16),

        // Health tip
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: AppColors.success.withOpacity(0.25),
                style: BorderStyle.solid),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.security, color: AppColors.success, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Health Security Tip',
                        style: AppTextStyles.labelMedium
                            .copyWith(color: AppColors.success)),
                    const SizedBox(height: 3),
                    Text(
                      'Ensure two-factor authentication is active to protect sensitive medical history files.',
                      style: AppTextStyles.bodySmall.copyWith(height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _VaultProfileCard extends StatelessWidget {
  final Profile profile;
  const _VaultProfileCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.primaryNavy.withOpacity(0.1),
                ),
                child: profile.avatarUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(profile.avatarUrl!, fit: BoxFit.cover))
                    : Center(
                        child: Text(profile.initials,
                            style: const TextStyle(
                                color: AppColors.primaryNavy,
                                fontWeight: FontWeight.bold,
                                fontSize: 18)),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile.name, style: AppTextStyles.labelMedium),
                    Text('Monitored User', style: AppTextStyles.bodySmall),
                    const SizedBox(height: 3),
                    Text('Just now',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              StatusBadge(
                label: 'SECURE',
                color: AppColors.success,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GradientButton(
                  label: 'Open Vault',
                  icon: Icons.folder_outlined,
                  height: 40,
                  onTap: () => context.push(
                      '/guardian/vault/${profile.id}?name=${Uri.encodeComponent(profile.name)}'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlineAppButton(
                  label: 'Share',
                  icon: Icons.share_outlined,
                  height: 40,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
