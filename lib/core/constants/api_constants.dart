class ApiConstants {
  // Default Android Emulator IP for localhost
  static const String defaultEmulatorBaseUrl = 'http://10.0.2.2:3000';
  
  // Default Physical Device IP (your computer's local network IP)
  static const String defaultPhysicalBaseUrl = 'http://192.168.2.12:3000';

  // Storage key for custom server base URL
  static const String serverUrlKey = 'monance_mobile_base_url';

  // Storage key for JWT token
  static const String authTokenKey = 'monance_jwt_token';

  // API Endpoints
  static const String loginEndpoint = '/api/auth/login';
  static const String registerEndpoint = '/api/auth/register';
  static const String meEndpoint = '/api/auth/me';
  static const String syncEndpoint = '/api/sync';
  static const String settingsEndpoint = '/api/settings';
  static const String hangoutsEndpoint = '/api/hangouts';
}
