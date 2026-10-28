import 'package:dio/dio.dart';
import '../../services/storage_service.dart';

class ApiClient {
  final StorageService _storageService;
  late final Dio _dio;
  void Function()? onUnauthorized;

  ApiClient(this._storageService, {this.onUnauthorized}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: _storageService.getServerUrl(),
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Dynamic base URL update in case user changed it in Settings
          options.baseUrl = _storageService.getServerUrl();

          final token = await _storageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            // Invalidate session on 401 Unauthorized
            await _storageService.deleteToken();
            onUnauthorized?.call();
          }
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;

  void updateBaseUrl(String newUrl) {
    _dio.options.baseUrl = newUrl;
  }
}
