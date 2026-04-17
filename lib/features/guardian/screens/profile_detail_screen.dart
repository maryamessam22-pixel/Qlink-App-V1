import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../models/models.dart';
import '../../../services/providers.dart';
import '../../../services/supabase_service.dart';

// ─── Profile Detail Screen ────────────────────────────────────────────────────
class ProfileDetailScreen extends ConsumerStatefulWidget {
  final String profileId;
  const ProfileDetailScreen({super.key, required this.profileId});

  @override
  ConsumerState<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends ConsumerState<ProfileDetailScreen> {
  Profile? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _profile = await SupabaseService.fetchProfileById(widget.profileId);
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Profile Details', style: AppTextStyles.heading3),
      ),
      body: _loading
          ? const AppLoadingWidget()
          : _profile == null
              ? const Center(child: Text('Profile not found'))
              : _buildBody(),
    );
  }

  Widget _buildBody() {
    final p = _profile!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header card
        SectionCard(
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primaryNavy,
                  shape: BoxShape.circle,
                ),
                child: p.avatarUrl != null
                    ? ClipOval(
                        child: Image.network(p.avatarUrl!, fit: BoxFit.cover))
                    : Center(
                        child: Text(p.initials,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold))),
              ),
              const SizedBox(height: 10),
              Text(p.name, style: AppTextStyles.heading3),
              Text(p.relationship ?? 'Member', style: AppTextStyles.bodySmall),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StatusBadge(
                    label: p.isConnected ? 'Connected' : 'No Device',
                    color: p.isConnected ? AppColors.success : AppColors.textSecondary,
                  ),
                  if (p.bloodType != null) ...[
                    const SizedBox(width: 8),
                    StatusBadge(label: p.bloodType!, color: AppColors.error),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Medical info
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Medical Information', style: AppTextStyles.heading3),
              const SizedBox(height: 12),
              _InfoRow('Blood Type', p.bloodType ?? 'Not set'),
              _InfoRow('Allergies', p.allergies ?? 'None'),
              _InfoRow('Conditions', p.conditions ?? 'None'),
              _InfoRow('Safety Notes', p.safetyNotes ?? 'None'),
              _InfoRow('Birth Year', p.birthYear?.toString() ?? 'Not set'),
              if (p.age != null) _InfoRow('Age', '${p.age} years'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Emergency contacts
        if (p.emergencyContacts.isNotEmpty) ...[
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Emergency Contacts', style: AppTextStyles.heading3),
                const SizedBox(height: 12),
                ...p.emergencyContacts.map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.phone_outlined,
                                color: AppColors.success, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Text(c.phone, style: AppTextStyles.bodyMedium),
                          if (c.isPrimary) ...[
                            const SizedBox(width: 8),
                            StatusBadge(label: 'Primary', color: AppColors.primaryBlue),
                          ],
                        ],
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Device info
        if (p.device != null) ...[
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Connected Device', style: AppTextStyles.heading3),
                const SizedBox(height: 12),
                _InfoRow('Code', p.device!.code),
                _InfoRow('Type', p.device!.type ?? 'Qlink Bracelet'),
                _InfoRow('Battery', '${p.device!.batteryLevel ?? 85}%'),
                _InfoRow('Status', p.device!.connected ? 'Connected' : 'Disconnected'),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Actions
        GradientButton(
          label: 'Open Medical Vault',
          icon: Icons.lock_outline,
          onTap: () => context.push(
              '/guardian/vault/${p.id}?name=${Uri.encodeComponent(p.name)}'),
        ),
        const SizedBox(height: 10),
        OutlineAppButton(
          label: 'View QR Code',
          icon: Icons.qr_code,
          onTap: () {},
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: AppTextStyles.bodySmall),
          ),
          Expanded(
            child: Text(value,
                style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
