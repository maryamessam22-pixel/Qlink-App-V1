import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';

class FindBraceletScreen extends StatefulWidget {
  const FindBraceletScreen({super.key});

  @override
  ConsumerState<FindBraceletScreen> createState() => _FindBraceletScreenState();
}

class _FindBraceletScreenState extends State<FindBraceletScreen>
    with SingleTickerProviderStateMixin {
  bool _searching = false;
  bool _found = false;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;
  Timer? _timer;

  final _lastKnown = LatLng(30.0444, 31.2357); // Simulated Cairo

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startSearch() {
    setState(() { _searching = true; _found = false; });
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() { _searching = false; _found = true; });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Find My Bracelet', style: AppTextStyles.heading3),
            Text('Last known location', style: AppTextStyles.bodySmall),
          ],
        ),
      ),
      body: Column(
        children: [
          // Map
          SizedBox(
            height: 300,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _lastKnown,
                initialZoom: 15,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.qlink.app',
                ),
                if (_found)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _lastKnown,
                        width: 60,
                        height: 60,
                        child: _BraceletMarker(pulse: _pulse),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Status card
                  SectionCard(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48, height: 48,
                              decoration: BoxDecoration(
                                color: _found
                                    ? AppColors.success.withOpacity(0.1)
                                    : AppColors.primaryBlue.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _found ? Icons.location_on : Icons.watch_outlined,
                                color: _found ? AppColors.success : AppColors.primaryBlue,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _found
                                        ? 'Bracelet Located!'
                                        : _searching
                                            ? 'Searching...'
                                            : 'Bracelet Last Seen',
                                    style: AppTextStyles.labelMedium,
                                  ),
                                  Text(
                                    _found
                                        ? 'Cairo, Egypt · Just now'
                                        : _searching
                                            ? 'Scanning nearby signals...'
                                            : 'Signal lost 2 hours ago',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            if (_found)
                              StatusBadge(label: 'FOUND', color: AppColors.success),
                          ],
                        ),
                        if (_searching) ...[
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: const LinearProgressIndicator(
                              backgroundColor: AppColors.borderColor,
                              valueColor: AlwaysStoppedAnimation(AppColors.primaryBlue),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Signal bars
                  SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Signal Strength', style: AppTextStyles.labelMedium),
                        const SizedBox(height: 10),
                        Row(
                          children: List.generate(5, (i) {
                            final filled = _found ? i < 3 : i < 1;
                            return Expanded(
                              child: Container(
                                height: 20 + (i * 6.0),
                                margin: const EdgeInsets.only(right: 4),
                                decoration: BoxDecoration(
                                  color: filled
                                      ? AppColors.success
                                      : AppColors.borderColor,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _found ? 'Good Signal (3/5)' : 'Weak Signal (1/5)',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // Action buttons
                  GradientButton(
                    label: _searching ? 'Searching...' : 'Find Bracelet',
                    icon: Icons.search,
                    onTap: _searching ? null : _startSearch,
                    isLoading: _searching,
                  ),
                  if (_found) ...[
                    const SizedBox(height: 10),
                    OutlineAppButton(
                      label: 'Ring Bracelet',
                      icon: Icons.volume_up_outlined,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Ringing bracelet...'),
                            backgroundColor: AppColors.primaryBlue,
                          ),
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BraceletMarker extends StatelessWidget {
  final Animation<double> pulse;
  const _BraceletMarker({required this.pulse});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (_, child) => Transform.scale(
        scale: pulse.value,
        child: child,
      ),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.15),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.success, width: 2),
        ),
        child: const Icon(Icons.watch_outlined, color: AppColors.success, size: 26),
      ),
    );
  }
}
