import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';
import '../models/user_model.dart';
import '../models/settings_model.dart';
import '../models/daily_record_model.dart';

class StorageService {
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;

  StorageService(this._prefs, this._secureStorage);

  static const String _keyCachedUser = 'monance_cached_user';
  static const String _keyCachedSettings = 'monance_cached_settings';
  static const String _keyCachedRecords = 'monance_cached_records';
  static const String _keySyncQueue = 'monance_sync_queue';
  static const String _keyLastSyncTime = 'monance_last_sync_time';
  static const String _keyTheme = 'monance_theme';

  // --- Auth & JWT Token (Secure Storage) ---

  Future<String?> getToken() async {
    return await _secureStorage.read(key: ApiConstants.authTokenKey);
  }

  Future<void> setToken(String token) async {
    await _secureStorage.write(key: ApiConstants.authTokenKey, value: token);
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: ApiConstants.authTokenKey);
  }

  // --- Server Base URL ---

  String getServerUrl() {
    return _prefs.getString(ApiConstants.serverUrlKey) ?? ApiConstants.defaultEmulatorBaseUrl;
  }

  Future<void> setServerUrl(String url) async {
    await _prefs.setString(ApiConstants.serverUrlKey, url.trim());
  }

  // --- Theme ---

  String getThemeMode() {
    return _prefs.getString(_keyTheme) ?? 'dark';
  }

  Future<void> setThemeMode(String mode) async {
    await _prefs.setString(_keyTheme, mode);
  }

  // --- Cached User ---

  UserModel? getCachedUser() {
    final raw = _prefs.getString(_keyCachedUser);
    if (raw == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> setCachedUser(UserModel user) async {
    await _prefs.setString(_keyCachedUser, jsonEncode(user.toJson()));
  }

  Future<void> clearCachedUser() async {
    await _prefs.remove(_keyCachedUser);
  }

  // --- Cached Settings ---

  SettingsModel getCachedSettings() {
    final raw = _prefs.getString(_keyCachedSettings);
    if (raw == null) return SettingsModel();
    try {
      return SettingsModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return SettingsModel();
    }
  }

  Future<void> setCachedSettings(SettingsModel settings) async {
    await _prefs.setString(_keyCachedSettings, jsonEncode(settings.toJson()));
  }

  // --- Cached Daily Records ---

  Map<String, DailyRecordModel> getCachedRecords() {
    final raw = _prefs.getString(_keyCachedRecords);
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final Map<String, DailyRecordModel> map = {};
      decoded.forEach((key, val) {
        if (val is Map<String, dynamic>) {
          map[key] = DailyRecordModel.fromJson(val);
        }
      });
      return map;
    } catch (_) {
      return {};
    }
  }

  Future<void> setCachedRecords(Map<String, DailyRecordModel> records) async {
    final Map<String, dynamic> rawMap = {};
    records.forEach((key, record) {
      rawMap[key] = record.toJson();
    });
    await _prefs.setString(_keyCachedRecords, jsonEncode(rawMap));
  }

  // --- Sync Queue & Timestamps ---

  int getLastSyncTime() {
    return _prefs.getInt(_keyLastSyncTime) ?? 0;
  }

  Future<void> setLastSyncTime(int timestamp) async {
    await _prefs.setInt(_keyLastSyncTime, timestamp);
  }

  Future<void> resetLastSyncTime() async {
    await _prefs.remove(_keyLastSyncTime);
  }

  List<DailyRecordModel> getPendingSyncQueue() {
    final raw = _prefs.getString(_keySyncQueue);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      final List<DailyRecordModel> result = [];
      for (final item in list) {
        if (item is Map) {
          result.add(DailyRecordModel.fromJson(Map<String, dynamic>.from(item)));
        }
      }
      return result;
    } catch (_) {
      return [];
    }
  }

  Future<void> addToSyncQueue(DailyRecordModel record) async {
    final current = getPendingSyncQueue();
    // Replace any existing queue entry for this date
    current.removeWhere((r) => r.date == record.date);
    current.add(record);
    await _prefs.setString(
      _keySyncQueue,
      jsonEncode(current.map((r) => r.toJson()).toList()),
    );
  }

  Future<void> clearSyncQueue() async {
    await _prefs.remove(_keySyncQueue);
  }

  Future<void> clearAllSessionData() async {
    await deleteToken();
    await clearCachedUser();
    await _prefs.remove(_keyCachedRecords);
    await _prefs.remove(_keyCachedSettings);
    await _prefs.remove(_keySyncQueue);
    await _prefs.remove(_keyLastSyncTime);
  }
}
