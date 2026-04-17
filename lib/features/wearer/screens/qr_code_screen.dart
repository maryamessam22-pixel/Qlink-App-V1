import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../services/providers.dart';

class QrCodeScreen extends ConsumerWidget {
  const QrCodeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    // Build QR data: NAME|BLOODTYPE|PHONE|USERID
    final qrData = '${user?.fullName ?? 'Unknown'}|Unknown|000000000|${user?.id ?? ''}';
    final profileId = 'QRGUARD-KLS-${(user?.id ?? 'XXX').substring(0, 3).toUpperCase()}';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: QlinkAppBar(avatarUrl: user?.avatarUrl),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Emergency QR', style: AppTextStyles.heading2),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Let others scan this in emergencies',
                style: AppTextStyles.bodySmall,
              ),
            ),
            const SizedBox(height: 32),

            // QR Code
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 220,
                backgroundColor: Colors.white,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: AppColors.primaryNavy,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: AppColors.primaryNavy,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Profile ID badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Text(
                    'Profile ID: $profileId',
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.primaryBlue),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Valid for: ${user?.fullName ?? 'User'}',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Download PDF
            GradientButton(
              label: 'Download PDF',
              icon: Icons.picture_as_pdf_outlined,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Generating PDF...'),
                      backgroundColor: AppColors.primaryBlue),
                );
              },
            ),
            const SizedBox(height: 12),

            // Share QR
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => Share.share(
                  'My Emergency QR Data: $qrData\nProfile: $profileId',
                  subject: 'Qlink Emergency QR',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.share_outlined),
                label: Text('Share QR Code', style: AppTextStyles.buttonText),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Allow first responders to scan this code to access your emergency medical information.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(height: 1.5),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
