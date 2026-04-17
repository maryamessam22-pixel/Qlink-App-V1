
// ─── User Model ───────────────────────────────────────────────────────────────
class AppUser {
  final String id;
  final String email;
  final String role;
  final String? fullName;
  final String? avatarUrl;
  final DateTime? createdAt;

  const AppUser({
    required this.id,
    required this.email,
    required this.role,
    this.fullName,
    this.avatarUrl,
    this.createdAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String,
        email: json['email'] as String,
        role: json['role'] as String? ?? 'guardian',
        fullName: json['full_name'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'role': role,
        if (fullName != null) 'full_name': fullName,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      };

  AppUser copyWith({
    String? fullName,
    String? avatarUrl,
    String? role,
  }) =>
      AppUser(
        id: id,
        email: email,
        role: role ?? this.role,
        fullName: fullName ?? this.fullName,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        createdAt: createdAt,
      );
}

// ─── Profile Model ───────────────────────────────────────────────────────────
class Profile {
  final String id;
  final String guardianId;
  final String name;
  final String? relationship;
  final int? birthYear;
  final String? bloodType;
  final String? allergies;
  final String? conditions;
  final String? safetyNotes;
  final String? avatarUrl;
  final bool isActive;
  final DateTime? createdAt;
  final List<EmergencyContact> emergencyContacts;
  final Device? device;

  const Profile({
    required this.id,
    required this.guardianId,
    required this.name,
    this.relationship,
    this.birthYear,
    this.bloodType,
    this.allergies,
    this.conditions,
    this.safetyNotes,
    this.avatarUrl,
    this.isActive = true,
    this.createdAt,
    this.emergencyContacts = const [],
    this.device,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        id: json['id'] as String,
        guardianId: json['guardian_id'] as String,
        name: json['name'] as String,
        relationship: json['relationship'] as String?,
        birthYear: json['birth_year'] as int?,
        bloodType: json['blood_type'] as String?,
        allergies: json['allergies'] as String?,
        conditions: json['conditions'] as String?,
        safetyNotes: json['safety_notes'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        isActive: json['is_active'] as bool? ?? true,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
        emergencyContacts: (json['app_emergency_contacts'] as List<dynamic>?)
                ?.map((e) => EmergencyContact.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        device: json['app_devices'] != null && (json['app_devices'] as List).isNotEmpty
            ? Device.fromJson((json['app_devices'] as List).first as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'guardian_id': guardianId,
        'name': name,
        if (relationship != null) 'relationship': relationship,
        if (birthYear != null) 'birth_year': birthYear,
        if (bloodType != null) 'blood_type': bloodType,
        if (allergies != null) 'allergies': allergies,
        if (conditions != null) 'conditions': conditions,
        if (safetyNotes != null) 'safety_notes': safetyNotes,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        'is_active': isActive,
      };

  int? get age {
    if (birthYear == null) return null;
    return DateTime.now().year - birthYear!;
  }

  bool get hasDevice => device != null;
  bool get isConnected => device?.connected ?? false;

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Profile copyWith({
    String? name,
    String? relationship,
    int? birthYear,
    String? bloodType,
    String? allergies,
    String? conditions,
    String? safetyNotes,
    String? avatarUrl,
    bool? isActive,
    List<EmergencyContact>? emergencyContacts,
    Device? device,
  }) =>
      Profile(
        id: id,
        guardianId: guardianId,
        name: name ?? this.name,
        relationship: relationship ?? this.relationship,
        birthYear: birthYear ?? this.birthYear,
        bloodType: bloodType ?? this.bloodType,
        allergies: allergies ?? this.allergies,
        conditions: conditions ?? this.conditions,
        safetyNotes: safetyNotes ?? this.safetyNotes,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt,
        emergencyContacts: emergencyContacts ?? this.emergencyContacts,
        device: device ?? this.device,
      );
}

// ─── Emergency Contact Model ──────────────────────────────────────────────────
class EmergencyContact {
  final String id;
  final String profileId;
  final String phone;
  final bool isPrimary;

  const EmergencyContact({
    required this.id,
    required this.profileId,
    required this.phone,
    this.isPrimary = false,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) => EmergencyContact(
        id: json['id'] as String? ?? '',
        profileId: json['profile_id'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        isPrimary: json['is_primary'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'profile_id': profileId,
        'phone': phone,
        'is_primary': isPrimary,
      };
}

// ─── Device Model ────────────────────────────────────────────────────────────
class Device {
  final String id;
  final String? profileId;
  final String code;
  final String? type;
  final bool connected;
  final int? batteryLevel;
  final DateTime? lastSync;
  final double? lastLat;
  final double? lastLng;

  const Device({
    required this.id,
    this.profileId,
    required this.code,
    this.type,
    this.connected = false,
    this.batteryLevel,
    this.lastSync,
    this.lastLat,
    this.lastLng,
  });

  factory Device.fromJson(Map<String, dynamic> json) => Device(
        id: json['id'] as String,
        profileId: json['profile_id'] as String?,
        code: json['code'] as String? ?? '',
        type: json['type'] as String?,
        connected: json['connected'] as bool? ?? false,
        batteryLevel: json['battery_level'] as int?,
        lastSync: json['last_sync'] != null
            ? DateTime.tryParse(json['last_sync'] as String)
            : null,
        lastLat: (json['last_lat'] as num?)?.toDouble(),
        lastLng: (json['last_lng'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        if (profileId != null) 'profile_id': profileId,
        'code': code,
        if (type != null) 'type': type,
        'connected': connected,
        if (batteryLevel != null) 'battery_level': batteryLevel,
      };
}

// ─── Location Model ───────────────────────────────────────────────────────────
class LocationRecord {
  final String id;
  final String profileId;
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  const LocationRecord({
    required this.id,
    required this.profileId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  factory LocationRecord.fromJson(Map<String, dynamic> json) => LocationRecord(
        id: json['id'] as String,
        profileId: json['profile_id'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        timestamp: DateTime.parse(json['timestamp'] as String),
      );

  Map<String, dynamic> toJson() => {
        'profile_id': profileId,
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': timestamp.toIso8601String(),
      };
}

// ─── Alert Model ─────────────────────────────────────────────────────────────
class AppAlert {
  final String id;
  final String profileId;
  final String type; // SOS | GEOFENCE
  final String? message;
  final bool isRead;
  final DateTime timestamp;
  final String? profileName;

  const AppAlert({
    required this.id,
    required this.profileId,
    required this.type,
    this.message,
    this.isRead = false,
    required this.timestamp,
    this.profileName,
  });

  factory AppAlert.fromJson(Map<String, dynamic> json) => AppAlert(
        id: json['id'] as String,
        profileId: json['profile_id'] as String,
        type: json['type'] as String? ?? 'SOS',
        message: json['message'] as String?,
        isRead: json['is_read'] as bool? ?? false,
        timestamp: DateTime.parse(json['timestamp'] as String),
        profileName: json['profiles'] != null
            ? (json['profiles'] as Map)['name'] as String?
            : null,
      );

  bool get isSOS => type == 'SOS';
  bool get isGeofence => type == 'GEOFENCE';
}

// ─── Vault File Model ─────────────────────────────────────────────────────────
class VaultFile {
  final String id;
  final String profileId;
  final String fileUrl;
  final String? fileName;
  final String? fileType;
  final DateTime? uploadedAt;

  const VaultFile({
    required this.id,
    required this.profileId,
    required this.fileUrl,
    this.fileName,
    this.fileType,
    this.uploadedAt,
  });

  factory VaultFile.fromJson(Map<String, dynamic> json) => VaultFile(
        id: json['id'] as String,
        profileId: json['profile_id'] as String,
        fileUrl: json['file_url'] as String,
        fileName: json['file_name'] as String?,
        fileType: json['file_type'] as String?,
        uploadedAt: json['uploaded_at'] != null
            ? DateTime.tryParse(json['uploaded_at'] as String)
            : null,
      );

  bool get isImage =>
      fileType?.startsWith('image/') ?? fileUrl.contains(RegExp(r'\.(jpg|jpeg|png|gif)$'));
}

// ─── Geofence Model ───────────────────────────────────────────────────────────
class GeofenceZone {
  final String id;
  final String profileId;
  final double centerLat;
  final double centerLng;
  final double radiusMeters;
  final String? label;
  final bool isActive;

  const GeofenceZone({
    required this.id,
    required this.profileId,
    required this.centerLat,
    required this.centerLng,
    required this.radiusMeters,
    this.label,
    this.isActive = true,
  });

  factory GeofenceZone.fromJson(Map<String, dynamic> json) => GeofenceZone(
        id: json['id'] as String,
        profileId: json['profile_id'] as String,
        centerLat: (json['center_lat'] as num).toDouble(),
        centerLng: (json['center_lng'] as num).toDouble(),
        radiusMeters: (json['radius_meters'] as num).toDouble(),
        label: json['label'] as String?,
        isActive: json['is_active'] as bool? ?? true,
      );
}
