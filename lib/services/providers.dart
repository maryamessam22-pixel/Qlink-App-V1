import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';

// ─── Auth Notifier ────────────────────────────────────────────────────────────
class AuthNotifier extends AsyncNotifier<AppUser?> {
  @override
  Future<AppUser?> build() async {
    // Listen to auth state changes
    ref.onDispose(() {});
    
    final user = SupabaseService.currentUser;
    if (user == null) return null;
    return await SupabaseService.fetchCurrentUser();
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await SupabaseService.signIn(email, password);
      final user = await SupabaseService.fetchCurrentUser();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> signUp(
      String email, String password, String fullName, String role) async {
    state = const AsyncValue.loading();
    try {
      await SupabaseService.signUp(email, password, fullName, role);
      final user = await SupabaseService.fetchCurrentUser();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> signOut() async {
    await SupabaseService.signOut();
    state = const AsyncValue.data(null);
  }

  Future<void> updateProfile(
      {String? fullName, String? avatarUrl, String? role}) async {
    await SupabaseService.updateUserProfile(
        fullName: fullName, avatarUrl: avatarUrl, role: role);
    final appUser = await SupabaseService.fetchCurrentUser();
    state = AsyncValue.data(appUser);
  }

  Future<void> refresh() async {
    final appUser = await SupabaseService.fetchCurrentUser();
    state = AsyncValue.data(appUser);
  }
}

final authProvider =
    AsyncNotifierProvider<AuthNotifier, AppUser?>(AuthNotifier.new);

// ─── Current User shortcut ────────────────────────────────────────────────────
final currentUserProvider = Provider<AppUser?>((ref) {
  return ref.watch(authProvider).valueOrNull;
});

// ─── Profiles Notifier ────────────────────────────────────────────────────────
class ProfilesNotifier extends AsyncNotifier<List<Profile>> {
  @override
  Future<List<Profile>> build() async => [];

  Future<void> load(String guardianId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => SupabaseService.fetchProfiles(guardianId));
  }

  Future<Profile> addProfile({
    required String guardianId,
    required String name,
    String? relationship,
    int? birthYear,
    String? bloodType,
    String? allergies,
    String? conditions,
    String? safetyNotes,
    List<String> emergencyPhones = const [],
  }) async {
    final profile = await SupabaseService.createProfile(
      guardianId: guardianId,
      name: name,
      relationship: relationship,
      birthYear: birthYear,
      bloodType: bloodType,
      allergies: allergies,
      conditions: conditions,
      safetyNotes: safetyNotes,
      emergencyPhones: emergencyPhones,
    );
    await load(guardianId);
    return profile;
  }

  Future<void> connectDevice(
      String code, String profileId, String guardianId) async {
    await SupabaseService.connectDevice(code, profileId);
    await load(guardianId);
  }

  Future<void> deleteProfile(String profileId, String guardianId) async {
    await SupabaseService.deleteProfile(profileId);
    await load(guardianId);
  }
}

final profilesNotifierProvider =
    AsyncNotifierProvider<ProfilesNotifier, List<Profile>>(
        ProfilesNotifier.new);

// ─── Alerts Notifier ──────────────────────────────────────────────────────────
class AlertsNotifier extends AsyncNotifier<List<AppAlert>> {
  @override
  Future<List<AppAlert>> build() async => [];

  Future<void> load(String guardianId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => SupabaseService.fetchAlerts(guardianId));
  }
}

final alertsProvider =
    AsyncNotifierProvider<AlertsNotifier, List<AppAlert>>(AlertsNotifier.new);

final unreadAlertsCountProvider = Provider<int>((ref) {
  return ref.watch(alertsProvider).valueOrNull?.where((a) => !a.isRead).length ?? 0;
});

// ─── Vault ────────────────────────────────────────────────────────────────────
final vaultProvider =
    FutureProvider.family<List<VaultFile>, String>((ref, profileId) async {
  return await SupabaseService.fetchVaultFiles(profileId);
});

// ─── Selected Profile ─────────────────────────────────────────────────────────
final selectedProfileProvider = StateProvider<Profile?>((ref) => null);

// ─── Heart Rate (simulated) ───────────────────────────────────────────────────
final heartRateProvider = StateProvider<int>((ref) => 72);
