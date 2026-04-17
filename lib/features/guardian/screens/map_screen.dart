import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../models/models.dart';
import '../../../services/providers.dart';

// Simulated Cairo coordinates for profiles
final _simulatedLocations = {
  'default': LatLng(30.0444, 31.2357), // Cairo
};

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final _mapCtrl = MapController();
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
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
      body: profilesAsync.when(
        loading: () => const AppLoadingWidget(),
        error: (e, _) => Center(child: Text('$e')),
        data: (profiles) => _buildMap(profiles),
      ),
    );
  }

  Widget _buildMap(List<Profile> profiles) {
    final connectedProfiles = profiles.where((p) => p.isConnected).toList();

    return Stack(
      children: [
        // Map
        FlutterMap(
          mapController: _mapCtrl,
          options: MapOptions(
            initialCenter: LatLng(30.0444, 31.2357),
            initialZoom: 12,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.qlink.app',
            ),
            MarkerLayer(
              markers: [
                ...profiles.map((p) {
                  // Slight offset per profile for demo
                  final baseIdx = profiles.indexOf(p);
                  final lat = 30.0444 + (baseIdx * 0.015);
                  final lng = 31.2357 + (baseIdx * 0.010);
                  return Marker(
                    point: LatLng(lat, lng),
                    width: 100,
                    height: 70,
                    child: _ProfileMarker(profile: p),
                  );
                }),
              ],
            ),
          ],
        ),

        // Top UI
        SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Map', style: AppTextStyles.heading2),
                        const SizedBox(width: 8),
                        StatusBadge(
                          label: '${connectedProfiles.length} Bracelets  Active',
                          color: AppColors.success,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 8),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Icon(Icons.search,
                                color: AppColors.textSecondary, size: 20),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _searchCtrl,
                              style: AppTextStyles.bodyMedium,
                              decoration: const InputDecoration(
                                hintText: 'Search saved places...',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.my_location,
                                color: AppColors.primaryBlue, size: 20),
                            onPressed: () => _mapCtrl.move(
                              LatLng(30.0444, 31.2357), 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Bottom controls
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Row(
            children: [
              // Geofencing button
              GestureDetector(
                onTap: () => context.push('/guardian/geofence'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryNavy,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.fence, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      const Text('Geofencing',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              // Zoom controls
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1), blurRadius: 6),
                  ],
                ),
                child: Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        final zoom = _mapCtrl.camera.zoom;
                        _mapCtrl.move(_mapCtrl.camera.center, zoom + 1);
                      },
                      icon: const Icon(Icons.add, size: 20),
                    ),
                    Container(height: 1, color: AppColors.borderColor),
                    IconButton(
                      onPressed: () {
                        final zoom = _mapCtrl.camera.zoom;
                        _mapCtrl.move(_mapCtrl.camera.center, zoom - 1);
                      },
                      icon: const Icon(Icons.remove, size: 20),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Navigation arrow
        Positioned(
          bottom: 80,
          right: 16,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.1), blurRadius: 6),
              ],
            ),
            child: const Icon(Icons.navigation, color: AppColors.primaryBlue),
          ),
        ),
      ],
    );
  }
}

class _ProfileMarker extends StatelessWidget {
  final Profile profile;
  const _ProfileMarker({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.15), blurRadius: 4),
            ],
          ),
          child: Text(
            profile.name.split(' ').take(2).join(' ').toUpperCase(),
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 3),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.success, width: 2.5),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.15), blurRadius: 6),
            ],
          ),
          child: profile.avatarUrl != null
              ? ClipOval(
                  child: Image.network(profile.avatarUrl!, fit: BoxFit.cover))
              : Center(
                  child: Text(
                    profile.initials,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                ),
        ),
        Container(
          width: 2,
          height: 8,
          color: AppColors.success,
        ),
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}
