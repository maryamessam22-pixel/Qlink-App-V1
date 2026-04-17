import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../services/providers.dart';

// ─── Health Screen ────────────────────────────────────────────────────────────
class HealthScreen extends ConsumerStatefulWidget {
  const HealthScreen({super.key});

  @override
  ConsumerState<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends ConsumerState<HealthScreen> {
  Timer? _hrTimer;
  int _heartRate = 72;
  bool _braceletConnected = true;
  int _battery = 85;
  final _rng = Random();

  @override
  void initState() {
    super.initState();
    // Simulate heart rate
    _hrTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        setState(() {
          _heartRate = 65 + _rng.nextInt(30); // 65–94 BPM range
        });
      }
    });
  }

  @override
  void dispose() {
    _hrTimer?.cancel();
    super.dispose();
  }

  String get _hrStatus {
    if (_heartRate < 60) return 'Low';
    if (_heartRate > 100) return 'High';
    return 'Normal';
  }

  Color get _hrColor {
    if (_heartRate < 60) return AppColors.primaryBlue;
    if (_heartRate > 100) return AppColors.error;
    return AppColors.success;
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
            Text('Health Monitoring', style: AppTextStyles.heading2),
            const SizedBox(height: 20),

            // Heart Rate Card
            SectionCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Heart Rate', style: AppTextStyles.bodySmall),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '$_heartRate',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w700,
                                color: _hrColor,
                                fontFamily: 'CenturyGothic',
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8, left: 4),
                              child: Text('BPM',
                                  style: AppTextStyles.bodySmall
                                      .copyWith(color: _hrColor)),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _hrColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _hrStatus,
                            style: TextStyle(
                                color: _hrColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite_rounded,
                        color: AppColors.error, size: 26),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Connection + Battery
            Row(
              children: [
                Expanded(
                  child: SectionCard(
                    child: Row(
                      children: [
                        Icon(Icons.watch_outlined,
                            color: _braceletConnected
                                ? AppColors.primaryBlue
                                : AppColors.textSecondary,
                            size: 24),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Connection',
                                  style: AppTextStyles.bodySmall),
                              Text(
                                _braceletConnected
                                    ? 'Connected'
                                    : 'Disconnected',
                                style: AppTextStyles.labelMedium.copyWith(
                                    color: _braceletConnected
                                        ? AppColors.primaryBlue
                                        : AppColors.error),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SectionCard(
                    child: Row(
                      children: [
                        Icon(
                          _battery > 20
                              ? Icons.battery_charging_full
                              : Icons.battery_alert,
                          color: _battery > 20
                              ? AppColors.success
                              : AppColors.error,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Bracelet Battery',
                                  style: AppTextStyles.bodySmall),
                              Text('$_battery%',
                                  style: AppTextStyles.labelMedium.copyWith(
                                      color: _battery > 20
                                          ? AppColors.success
                                          : AppColors.error)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Sensors Status
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Sensors Status',
                              style: AppTextStyles.bodySmall),
                          Text('Active',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppColors.success,
                                fontFamily: 'CenturyGothic',
                              )),
                        ],
                      ),
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_circle_outline,
                            color: AppColors.success, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: ['Optical', 'Accelerometer', 'GPS']
                        .map((s) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color:
                                        AppColors.success.withOpacity(0.3)),
                              ),
                              child: Text(s,
                                  style: TextStyle(
                                      color: AppColors.success,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500)),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(
                            color: AppColors.success, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Text('All sensors are working normally.',
                          style: AppTextStyles.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
