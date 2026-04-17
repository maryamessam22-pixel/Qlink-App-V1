import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/providers.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/role_selection_screen.dart';
import '../features/auth/screens/sign_in_screen.dart';
import '../features/auth/screens/sign_up_screen.dart';
import '../features/guardian/screens/guardian_shell.dart';
import '../features/guardian/screens/guardian_home_screen.dart';
import '../features/guardian/screens/add_profile_screen.dart';
import '../features/guardian/screens/map_screen.dart';
import '../features/guardian/screens/vault_screen.dart';
import '../features/guardian/screens/profile_vault_screen.dart';
import '../features/guardian/screens/guardian_settings_screen.dart';
import '../features/guardian/screens/profile_detail_screen.dart';
import '../features/guardian/screens/geofence_screen.dart';
import '../features/wearer/screens/wearer_shell.dart';
import '../features/wearer/screens/wearer_home_screen.dart';
import '../features/wearer/screens/health_screen.dart';
import '../features/wearer/screens/qr_code_screen.dart';
import '../features/wearer/screens/wearer_settings_screen.dart';
import '../features/wearer/screens/find_bracelet_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      if (isLoading) return '/splash';

      final user = authState.valueOrNull;
      final isAuth = user != null;
      final isAuthRoute = state.matchedLocation.startsWith('/auth') ||
          state.matchedLocation == '/splash';

      if (!isAuth && !isAuthRoute) return '/auth/role';
      if (isAuth) {
        if (state.matchedLocation == '/splash' || state.matchedLocation == '/auth/role') {
          return user.role == 'wearer' ? '/wearer' : '/guardian';
        }
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),

      // Auth
      GoRoute(path: '/auth/role', builder: (_, __) => const RoleSelectionScreen()),
      GoRoute(
        path: '/auth/signin',
        builder: (_, state) {
          final role = state.uri.queryParameters['role'] ?? 'guardian';
          return SignInScreen(role: role);
        },
      ),
      GoRoute(
        path: '/auth/signup',
        builder: (_, state) {
          final role = state.uri.queryParameters['role'] ?? 'guardian';
          return SignUpScreen(role: role);
        },
      ),

      // Guardian Shell
      ShellRoute(
        builder: (context, state, child) => GuardianShell(child: child),
        routes: [
          GoRoute(
            path: '/guardian',
            builder: (_, __) => const GuardianHomeScreen(),
          ),
          GoRoute(
            path: '/guardian/map',
            builder: (_, __) => const MapScreen(),
          ),
          GoRoute(
            path: '/guardian/vault',
            builder: (_, __) => const VaultScreen(),
          ),
          GoRoute(
            path: '/guardian/settings',
            builder: (_, __) => const GuardianSettingsScreen(),
          ),
        ],
      ),

      // Guardian full-screen routes (outside shell)
      GoRoute(
        path: '/guardian/add-profile',
        builder: (_, __) => const AddProfileScreen(),
      ),
      GoRoute(
        path: '/guardian/profile/:id',
        builder: (_, state) {
          final profileId = state.pathParameters['id']!;
          return ProfileDetailScreen(profileId: profileId);
        },
      ),
      GoRoute(
        path: '/guardian/vault/:id',
        builder: (_, state) {
          final profileId = state.pathParameters['id']!;
          final profileName = state.uri.queryParameters['name'] ?? '';
          return ProfileVaultScreen(profileId: profileId, profileName: profileName);
        },
      ),
      GoRoute(
        path: '/guardian/geofence',
        builder: (_, __) => const GeofenceScreen(),
      ),
      GoRoute(
        path: '/guardian/alerts',
        builder: (_, __) => const AlertsScreen(),
      ),
      GoRoute(
        path: '/guardian/qr-scanner',
        builder: (_, __) => const QrScannerScreen(),
      ),

      // Wearer Shell
      ShellRoute(
        builder: (context, state, child) => WearerShell(child: child),
        routes: [
          GoRoute(
            path: '/wearer',
            builder: (_, __) => const WearerHomeScreen(),
          ),
          GoRoute(
            path: '/wearer/health',
            builder: (_, __) => const HealthScreen(),
          ),
          GoRoute(
            path: '/wearer/qrcode',
            builder: (_, __) => const QrCodeScreen(),
          ),
          GoRoute(
            path: '/wearer/settings',
            builder: (_, __) => const WearerSettingsScreen(),
          ),
        ],
      ),

      // Wearer full-screen
      GoRoute(
        path: '/wearer/find-bracelet',
        builder: (_, __) => const FindBraceletScreen(),
      ),
      GoRoute(
        path: '/wearer/qr-scanner',
        builder: (_, __) => const QrScannerScreen(),
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );
});
