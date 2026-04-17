import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import '../core/constants/app_constants.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  // ─── Auth ─────────────────────────────────────────────────────────────────
  static Future<AuthResponse> signIn(String email, String password) async {
    return await client.auth.signInWithPassword(email: email, password: password);
  }

  static Future<AuthResponse> signUp(
      String email, String password, String fullName, String role) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName, 'role': role},
    );
    if (response.user != null) {
      await client.from(AppConstants.tableUsers).upsert({
        'id': response.user!.id,
        'email': email,
        'full_name': fullName,
        'role': role,
      });
    }
    return response;
  }

  static Future<void> signOut() async => await client.auth.signOut();

  static User? get currentUser => client.auth.currentUser;

  static Future<AppUser?> fetchCurrentUser() async {
    final uid = currentUser?.id;
    if (uid == null) return null;
    try {
      final data = await client
          .from(AppConstants.tableUsers)
          .select()
          .eq('id', uid)
          .maybeSingle();
      if (data == null) {
        // Create if not exists
        final meta = currentUser!.userMetadata;
        final newUser = {
          'id': uid,
          'email': currentUser!.email ?? '',
          'full_name': meta?['full_name'] ?? '',
          'role': meta?['role'] ?? AppConstants.roleGuardian,
        };
        await client.from(AppConstants.tableUsers).upsert(newUser);
        return AppUser.fromJson(newUser);
      }
      return AppUser.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  static Future<void> updateUserProfile(
      {String? fullName, String? avatarUrl, String? role}) async {
    final uid = currentUser?.id;
    if (uid == null) return;
    final updates = <String, dynamic>{};
    if (fullName != null) updates['full_name'] = fullName;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
    if (role != null) updates['role'] = role;
    await client.from(AppConstants.tableUsers).update(updates).eq('id', uid);
    await client.auth.updateUser(UserAttributes(data: updates));
  }

  static Future<void> changePassword(String newPassword) async {
    await client.auth.updateUser(UserAttributes(password: newPassword));
  }

  // ─── Profiles ────────────────────────────────────────────────────────────
  static Future<List<Profile>> fetchProfiles(String guardianId) async {
    final data = await client
        .from(AppConstants.tableProfiles)
        .select('*, app_emergency_contacts(*), app_devices(*)')
        .eq('guardian_id', guardianId)
        .order('created_at', ascending: true);
    return (data as List).map((e) => Profile.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<Profile?> fetchProfileById(String profileId) async {
    final data = await client
        .from(AppConstants.tableProfiles)
        .select('*, app_emergency_contacts(*), app_devices(*)')
        .eq('id', profileId)
        .maybeSingle();
    if (data == null) return null;
    return Profile.fromJson(data);
  }

  static Future<Profile> createProfile({
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
    final row = await client.from(AppConstants.tableProfiles).insert({
      'guardian_id': guardianId,
      'name': name,
      if (relationship != null) 'relationship': relationship,
      if (birthYear != null) 'birth_year': birthYear,
      if (bloodType != null) 'blood_type': bloodType,
      if (allergies != null) 'allergies': allergies,
      if (conditions != null) 'conditions': conditions,
      if (safetyNotes != null) 'safety_notes': safetyNotes,
    }).select().single();

    final profile = Profile.fromJson(row);

    // Insert emergency contacts
    for (int i = 0; i < emergencyPhones.length; i++) {
      if (emergencyPhones[i].isNotEmpty) {
        await client.from(AppConstants.tableEmergencyContacts).insert({
          'profile_id': profile.id,
          'phone': emergencyPhones[i],
          'is_primary': i == 0,
        });
      }
    }

    return profile;
  }

  static Future<void> updateProfile(String profileId, Map<String, dynamic> updates) async {
    await client
        .from(AppConstants.tableProfiles)
        .update(updates)
        .eq('id', profileId);
  }

  static Future<void> deleteProfile(String profileId) async {
    await client.from(AppConstants.tableProfiles).delete().eq('id', profileId);
  }

  // ─── Devices ─────────────────────────────────────────────────────────────
  static Future<Device?> connectDevice(String code, String profileId) async {
    // Check if bracelet code exists in bracelets table
    final bracelet = await client
        .from(AppConstants.tableBracelets)
        .select()
        .eq('code', code)
        .maybeSingle();

    if (bracelet == null) return null;

    // Check if already exists in devices for this profile
    final existing = await client
        .from(AppConstants.tableDevices)
        .select()
        .eq('profile_id', profileId)
        .maybeSingle();

    if (existing != null) {
      await client.from(AppConstants.tableDevices).update({
        'code': code,
        'connected': true,
        'type': bracelet['type'] ?? 'Qlink Bracelet',
      }).eq('id', existing['id']);
      return Device.fromJson({...existing, 'connected': true, 'code': code});
    }

    final row = await client.from(AppConstants.tableDevices).insert({
      'profile_id': profileId,
      'code': code,
      'connected': true,
      'type': bracelet['type'] ?? 'Qlink Bracelet',
      'battery_level': bracelet['battery_level'] ?? 85,
    }).select().single();

    return Device.fromJson(row);
  }

  static Future<Device?> fetchDeviceByProfileId(String profileId) async {
    final data = await client
        .from(AppConstants.tableDevices)
        .select()
        .eq('profile_id', profileId)
        .maybeSingle();
    if (data == null) return null;
    return Device.fromJson(data);
  }

  // ─── Locations ───────────────────────────────────────────────────────────
  static Future<LocationRecord?> fetchLatestLocation(String profileId) async {
    final data = await client
        .from(AppConstants.tableLocations)
        .select()
        .eq('profile_id', profileId)
        .order('timestamp', ascending: false)
        .limit(1)
        .maybeSingle();
    if (data == null) return null;
    return LocationRecord.fromJson(data);
  }

  static Future<void> insertLocation({
    required String profileId,
    required double lat,
    required double lng,
  }) async {
    await client.from(AppConstants.tableLocations).insert({
      'profile_id': profileId,
      'latitude': lat,
      'longitude': lng,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // ─── Alerts ───────────────────────────────────────────────────────────────
  static Future<List<AppAlert>> fetchAlerts(String guardianId) async {
    // Get profile ids for this guardian
    final profiles = await client
        .from(AppConstants.tableProfiles)
        .select('id')
        .eq('guardian_id', guardianId);
    final ids = (profiles as List).map((e) => e['id'] as String).toList();
    if (ids.isEmpty) return [];

    final data = await client
        .from(AppConstants.tableAlerts)
        .select('*, profiles(name)')
        .inFilter('profile_id', ids)
        .order('timestamp', ascending: false)
        .limit(50);
    return (data as List).map((e) => AppAlert.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<void> triggerSOS(String userIdOrProfileId, String? message) async {
    // Try to find a profile linked to this user ID first
    String profileId = userIdOrProfileId;
    try {
      final profile = await client
          .from(AppConstants.tableProfiles)
          .select('id')
          .eq('guardian_id', userIdOrProfileId)
          .limit(1)
          .maybeSingle();
      if (profile != null) profileId = profile['id'] as String;
    } catch (_) {}

    await client.from(AppConstants.tableAlerts).insert({
      'profile_id': profileId,
      'type': AppConstants.alertSOS,
      'message': message ?? 'SOS Emergency triggered',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> markAlertRead(String alertId) async {
    await client
        .from(AppConstants.tableAlerts)
        .update({'is_read': true})
        .eq('id', alertId);
  }

  // ─── Vault ────────────────────────────────────────────────────────────────
  static Future<List<VaultFile>> fetchVaultFiles(String profileId) async {
    final data = await client
        .from(AppConstants.tableVault)
        .select()
        .eq('profile_id', profileId)
        .order('uploaded_at', ascending: false);
    return (data as List).map((e) => VaultFile.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<VaultFile> uploadVaultFile(
      String profileId, File file, String fileName) async {
    final ext = fileName.split('.').last;
    final path = '$profileId/${DateTime.now().millisecondsSinceEpoch}.$ext';

    await client.storage.from(AppConstants.bucketVault).upload(path, file);
    final url = client.storage.from(AppConstants.bucketVault).getPublicUrl(path);

    final row = await client.from(AppConstants.tableVault).insert({
      'profile_id': profileId,
      'file_url': url,
      'file_name': fileName,
      'file_type': _mimeType(ext),
      'uploaded_at': DateTime.now().toIso8601String(),
    }).select().single();

    return VaultFile.fromJson(row);
  }

  static Future<void> deleteVaultFile(String vaultId, String fileUrl) async {
    await client.from(AppConstants.tableVault).delete().eq('id', vaultId);
  }

  // ─── Avatar Upload ────────────────────────────────────────────────────────
  static Future<String> uploadAvatar(String userId, File file) async {
    final ext = file.path.split('.').last;
    final path = '$userId/avatar.$ext';
    await client.storage.from(AppConstants.bucketAvatars).upload(
          path,
          file,
          fileOptions: const FileOptions(upsert: true),
        );
    return client.storage.from(AppConstants.bucketAvatars).getPublicUrl(path);
  }

  // ─── Real-time ────────────────────────────────────────────────────────────
  static RealtimeChannel subscribeToAlerts(
      String profileId, void Function(AppAlert) onAlert) {
    return client
        .channel('alerts:$profileId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: AppConstants.tableAlerts,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'profile_id',
            value: profileId,
          ),
          callback: (payload) {
            try {
              final alert = AppAlert.fromJson(payload.newRecord);
              onAlert(alert);
            } catch (_) {}
          },
        )
        .subscribe();
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────
  static String _mimeType(String ext) {
    switch (ext.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }
}
