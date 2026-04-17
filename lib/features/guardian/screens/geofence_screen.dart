import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../models/models.dart';
import '../../../services/providers.dart';
import '../../../services/supabase_service.dart';

// ─── Geofence Screen ──────────────────────────────────────────────────────────
class GeofenceScreen extends ConsumerStatefulWidget {
  const GeofenceScreen({super.key});

  @override
  ConsumerState<GeofenceScreen> createState() => _GeofenceScreenState();
}

class _GeofenceScreenState extends ConsumerState<GeofenceScreen> {
  final _mapCtrl = MapController();
  LatLng _center = const LatLng(30.0444, 31.2357);
  double _radius = 500;
  String? _selectedProfileId;

  @override
  Widget build(BuildContext context) {
    final profilesAsync = ref.watch(profilesNotifierProvider);

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Geofence Setup', style: AppTextStyles.heading3),
            Text('Define safe zone', style: AppTextStyles.bodySmall),
          ],
        ),
      ),
      body: Column(
        children: [
          // Select member
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: profilesAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => const SizedBox.shrink(),
              data: (profiles) => DropdownButtonFormField<String>(
                value: _selectedProfileId,
                hint: const Text('Select Member'),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderColor),
                  ),
                ),
                items: profiles
                    .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedProfileId = v),
              ),
            ),
          ),

          // Map
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapCtrl,
                  options: MapOptions(
                    initialCenter: _center,
                    initialZoom: 14,
                    onTap: (_, point) => setState(() => _center = point),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.qlink.app',
                    ),
                    CircleLayer(
                      circles: [
                        CircleMarker(
                          point: _center,
                          radius: _radius,
                          useRadiusInMeter: true,
                          color: AppColors.primaryBlue.withOpacity(0.15),
                          borderColor: AppColors.primaryBlue,
                          borderStrokeWidth: 2,
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _center,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryBlue,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  top: 12,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6),
                        ],
                      ),
                      child: Text('Tap map to move the zone center',
                          style: AppTextStyles.bodySmall),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Controls
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Radius: ${_radius.toInt()} m',
                        style: AppTextStyles.labelMedium),
                    Text('${(_radius / 1000).toStringAsFixed(1)} km',
                        style: AppTextStyles.bodySmall),
                  ],
                ),
                Slider(
                  value: _radius,
                  min: 100,
                  max: 5000,
                  divisions: 49,
                  activeColor: AppColors.primaryBlue,
                  onChanged: (v) => setState(() => _radius = v),
                ),
                const SizedBox(height: 8),
                GradientButton(
                  label: 'Save Geofence Zone',
                  icon: Icons.save_outlined,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Geofence zone saved!'),
                          backgroundColor: AppColors.success),
                    );
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Alerts Screen ────────────────────────────────────────────────────────────
class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key});

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider);
      if (user != null) ref.read(alertsProvider.notifier).load(user.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final alertsAsync = ref.watch(alertsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Alerts', style: AppTextStyles.heading3),
      ),
      body: alertsAsync.when(
        loading: () => const AppLoadingWidget(),
        error: (e, _) => Center(child: Text('$e')),
        data: (alerts) => alerts.isEmpty
            ? const EmptyStateWidget(
                icon: Icons.notifications_none_outlined,
                title: 'No alerts yet',
                subtitle: 'You\'ll be notified when something happens',
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: alerts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _AlertCard(alert: alerts[i]),
              ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final AppAlert alert;
  const _AlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    final isSOS = alert.isSOS;
    final color = isSOS ? AppColors.error : AppColors.warning;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSOS ? Icons.emergency : Icons.fence,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isSOS ? 'SOS Emergency' : 'Geofence Alert',
                      style: AppTextStyles.labelMedium.copyWith(color: color),
                    ),
                    if (!alert.isRead) ...[
                      const SizedBox(width: 6),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                            color: color, shape: BoxShape.circle),
                      ),
                    ],
                  ],
                ),
                if (alert.profileName != null)
                  Text(alert.profileName!, style: AppTextStyles.bodySmall),
                if (alert.message != null)
                  Text(alert.message!, style: AppTextStyles.bodySmall),
                const SizedBox(height: 2),
                Text(
                  _formatTime(alert.timestamp),
                  style: AppTextStyles.labelSmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

// ─── QR Scanner Screen ────────────────────────────────────────────────────────
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  MobileScannerController? _controller;
  bool _scanned = false;
  Map<String, dynamic>? _scannedData;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned || !mounted) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;
    setState(() => _scanned = true);
    _controller?.stop();

    final raw = barcode!.rawValue!;
    if (raw.contains('|')) {
      final parts = raw.split('|');
      _scannedData = {
        'name': parts.isNotEmpty ? parts[0] : '',
        'blood_type': parts.length > 1 ? parts[1] : '',
        'phone': parts.length > 2 ? parts[2] : '',
        'profile_id': parts.length > 3 ? parts[3] : '',
      };
    } else {
      _scannedData = {'raw': raw};
    }

    _showResult();
  }

  void _showResult() {
    if (_scannedData == null || !mounted) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle,
                      color: AppColors.success, size: 22),
                ),
                const SizedBox(width: 12),
                Text('QR Code Scanned', style: AppTextStyles.heading3),
              ],
            ),
            const SizedBox(height: 16),
            if (_scannedData!['name'] != null && _scannedData!['name'] != '') ...[
              _QrRow('Name', _scannedData!['name']),
              _QrRow('Blood Type', _scannedData!['blood_type'] ?? ''),
              _QrRow('Emergency Phone', _scannedData!['phone'] ?? ''),
            ] else ...[
              _QrRow('Data', _scannedData!['raw'] ?? ''),
            ],
            const SizedBox(height: 16),
            GradientButton(
              label: 'Done',
              onTap: () {
                Navigator.pop(context);
                if (mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    ).then((_) {
      if (mounted) {
        setState(() {
          _scanned = false;
          _scannedData = null;
        });
        _controller?.start();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('QR Scanner',
            style: TextStyle(color: Colors.white, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on, color: Colors.white),
            onPressed: () => _controller?.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller!,
            onDetect: _onDetect,
          ),
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primaryBlue, width: 2.5),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Scan a Qlink QR code',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.8), fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QrRow extends StatelessWidget {
  final String label;
  final String value;
  const _QrRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: AppTextStyles.bodySmall),
          ),
          Expanded(
            child: Text(value,
                style: AppTextStyles.bodyMedium
                    .copyWith(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
