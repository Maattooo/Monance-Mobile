import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/user_model.dart';
import '../models/settings_model.dart';

class AuthResult {
  final bool success;
  final String? token;
  final UserModel? user;
  final SettingsModel? settings;
  final String? errorMessage;

  AuthResult({
    required this.success,
    this.token,
    this.user,
    this.settings,
    this.errorMessage,
  });
}

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  Future<AuthResult> login({required String email, required String password}) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.loginEndpoint,
        data: {
          'email': email.trim().toLowerCase(),
          'password': password,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final token = data['token'] as String?;
      final userData = data['user'] as Map<String, dynamic>?;

      if (data['success'] == true && token != null && userData != null) {
        return AuthResult(
          success: true,
          token: token,
          user: UserModel.fromJson(userData),
        );
      }

      return AuthResult(
        success: false,
        errorMessage: data['error'] as String? ?? 'Login failed. Please check your credentials.',
      );
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response?.data['error'] as String? ?? e.message)
          : e.message;
      return AuthResult(success: false, errorMessage: msg ?? 'Connection error. Is the server running?');
    } catch (e) {
      return AuthResult(success: false, errorMessage: e.toString());
    }
  }

  Future<AuthResult> register({required String email, required String password}) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.registerEndpoint,
        data: {
          'email': email.trim().toLowerCase(),
          'password': password,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final token = data['token'] as String?;
      final userData = data['user'] as Map<String, dynamic>?;

      if (data['success'] == true && token != null && userData != null) {
        return AuthResult(
          success: true,
          token: token,
          user: UserModel.fromJson(userData),
        );
      }

      return AuthResult(
        success: false,
        errorMessage: data['error'] as String? ?? 'Registration failed.',
      );
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response?.data['error'] as String? ?? e.message)
          : e.message;
      return AuthResult(success: false, errorMessage: msg ?? 'Connection error.');
    } catch (e) {
      return AuthResult(success: false, errorMessage: e.toString());
    }
  }

  Future<AuthResult> fetchMe() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.meEndpoint);
      final data = response.data as Map<String, dynamic>;

      if (data['authenticated'] == true && data['user'] != null) {
        final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
        final settings = data['settings'] != null
            ? SettingsModel.fromJson(data['settings'] as Map<String, dynamic>)
            : SettingsModel();

        return AuthResult(
          success: true,
          user: user,
          settings: settings,
        );
      }

      return AuthResult(success: false, errorMessage: 'Unauthenticated session');
    } catch (e) {
      return AuthResult(success: false, errorMessage: e.toString());
    }
  }
}
