class AppConstants {
  // Supabase
  static const String supabaseUrl = 'https://vveftffbvwptlsqgeygp.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ2ZWZ0ZmZidndwdGxzcWdleWdwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI2NjQ3MDcsImV4cCI6MjA1ODI0MDcwN30.RGy8fTpCQ7N48IwYQhgGLFHJAWH0a1AXTaKQ4vSsVX4';

  // Supabase Tables — prefixed with "app_" to avoid conflict with website tables
  static const String tableUsers = 'app_users';
  static const String tableProfiles = 'app_profiles';
  static const String tableEmergencyContacts = 'app_emergency_contacts';
  static const String tableDevices = 'app_devices';
  static const String tableBracelets = 'app_bracelets';
  static const String tableLocations = 'app_locations';
  static const String tableAlerts = 'app_alerts';
  static const String tableVault = 'app_vault';

  // Storage Buckets
  static const String bucketVault = 'app-vault';
  static const String bucketAvatars = 'app-avatars';

  // User Roles
  static const String roleGuardian = 'guardian';
  static const String roleWearer = 'wearer';

  // Alert Types
  static const String alertSOS = 'SOS';
  static const String alertGeofence = 'GEOFENCE';

  // Blood Types
  static const List<String> bloodTypes = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  // Device Types
  static const List<String> deviceTypes = [
    'Qlink Bracelet',
    'Qlink Smart Bracelet "Nova"',
    'Qlink Smart Bracelet "Pulse"',
    'Apple Watch',
    'Smartwatch',
  ];
}
