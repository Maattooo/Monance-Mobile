import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/daily_record_model.dart';
import 'storage_service.dart';

class SyncResult {
  final bool success;
  final Map<String, DailyRecordModel>? updatedRecords;
  final int? newSyncTime;
  final String? errorMessage;

  SyncResult({
    required this.success,
    this.updatedRecords,
    this.newSyncTime,
    this.errorMessage,
  });
}

class SyncService {
  final ApiClient _apiClient;
  final StorageService _storageService;

  SyncService(this._apiClient, this._storageService);

  Future<SyncResult> performSync({bool fullSync = false}) async {
    try {
      final pendingQueue = _storageService.getPendingSyncQueue();
      final lastSyncTime = fullSync ? 0 : _storageService.getLastSyncTime();
      final localRecords = _storageService.getCachedRecords();

      final payload = {
        'clientRecords': pendingQueue.map((r) => r.toJson()).toList(),
        'lastSyncTime': lastSyncTime,
      };

      final response = await _apiClient.dio.post(
        ApiConstants.syncEndpoint,
        data: payload,
      );

      final data = response.data as Map<String, dynamic>;
      if (data['success'] != true) {
        return SyncResult(
          success: false,
          errorMessage: data['error'] as String? ?? 'Sync operation failed on server.',
        );
      }

      // Next.js returns 'updates' and 'serverTime'
      final serverRecordsRaw = (data['updates'] ?? data['serverRecords']) as List? ?? [];
      final serverTime = (data['serverTime'] ?? data['syncTime'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch;

      // Merge server records with local records using timestamp comparison
      final Map<String, DailyRecordModel> merged = Map.from(localRecords);

      for (final raw in serverRecordsRaw) {
        if (raw is Map) {
          final serverRecord = DailyRecordModel.fromJson(Map<String, dynamic>.from(raw));
          final existingLocal = merged[serverRecord.date];

          // If local record is pending or newer, keep local; otherwise adopt server record
          if (existingLocal == null || serverRecord.updatedAt >= existingLocal.updatedAt) {
            merged[serverRecord.date] = serverRecord;
          }
        }
      }

      // Fetch remaining records if server signaled hasMore
      bool hasMore = data['hasMore'] == true;
      int currentLastSync = serverTime;
      while (hasMore) {
        final nextResponse = await _apiClient.dio.post(
          ApiConstants.syncEndpoint,
          data: {
            'clientRecords': [],
            'lastSyncTime': currentLastSync,
          },
        );
        final nextData = nextResponse.data as Map<String, dynamic>;
        if (nextData['success'] == true) {
          final nextUpdates = (nextData['updates'] ?? nextData['serverRecords']) as List? ?? [];
          for (final raw in nextUpdates) {
            if (raw is Map) {
              final serverRecord = DailyRecordModel.fromJson(Map<String, dynamic>.from(raw));
              final existingLocal = merged[serverRecord.date];
              if (existingLocal == null || serverRecord.updatedAt >= existingLocal.updatedAt) {
                merged[serverRecord.date] = serverRecord;
              }
            }
          }
          currentLastSync = (nextData['serverTime'] as num?)?.toInt() ?? currentLastSync;
          hasMore = nextData['hasMore'] == true;
        } else {
          hasMore = false;
        }
      }

      // Persist merged records, update sync time, and clear queue
      await _storageService.setCachedRecords(merged);
      await _storageService.setLastSyncTime(currentLastSync);
      await _storageService.clearSyncQueue();

      return SyncResult(
        success: true,
        updatedRecords: merged,
        newSyncTime: currentLastSync,
      );
    } catch (e) {
      return SyncResult(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<bool> saveSettingsToServer({
    int? defaultAllowance,
    int? goalAmount,
    int? currentBalance,
    String? goalStartDate,
    List<Map<String, dynamic>>? categories,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (defaultAllowance != null) data['defaultAllowance'] = defaultAllowance;
      if (goalAmount != null) data['goalAmount'] = goalAmount;
      if (currentBalance != null) data['currentBalance'] = currentBalance;
      if (goalStartDate != null) data['goalStartDate'] = goalStartDate;
      if (categories != null) data['categories'] = categories;

      final response = await _apiClient.dio.post(
        ApiConstants.settingsEndpoint,
        data: data,
      );

      return response.data['success'] == true;
    } catch (_) {
      return false;
    }
  }
}
