import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api_client.dart';
import '../core/constants.dart';
import '../core/exceptions.dart';
import '../models/user.dart';

class AuthService {
  final Dio _dio;
  final SharedPreferences _prefs;

  AuthService({Dio? dio, SharedPreferences? prefs})
      : _dio = dio ?? ApiClient.instance.dio,
        _prefs = prefs!;

  Future<String?> getToken() => Future.value(_prefs.getString(AppConstants.tokenKey));

  Future<void> _saveToken(String token) async {
    await _prefs.setString(AppConstants.tokenKey, token);
  }

  Future<User> login(String email, String password) async {
    try {
      final response = await _dio.post('/api/v1/auth/login', data: {
        'email': email,
        'password': password,
      });

      final result = response.data['data'] as Map<String, dynamic>;
      final token = result['access_token'] as String;
      await _saveToken(token);

      return User.fromJson(result['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<User> register(String name, String email, String password,
      String passwordConfirmation) async {
    try {
      final response = await _dio.post('/api/v1/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });

      final result = response.data['data'] as Map<String, dynamic>;
      final token = result['access_token'] as String;
      await _saveToken(token);

      return User.fromJson(result['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<User> getUser() async {
    try {
      final response = await _dio.get('/api/v1/me');
      return User.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<User> updateProfile({String? name}) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;

      final response = await _dio.patch('/api/v1/me', data: data);
      return User.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/api/v1/auth/logout');
    } on DioException {
      // tetap hapus token meski request gagal
    } finally {
      await _prefs.remove(AppConstants.tokenKey);
    }
  }

  Exception _handleError(DioException e) {
    if (e.error is AppException) return e.error as Exception;

    final statusCode = e.response?.statusCode;
    final message = e.response?.data?['message'] as String?;

    switch (statusCode) {
      case 401:
        return UnauthorizedException(message: message);
      case 422:
        return ValidationException(
          message: message,
          errors: e.response?.data?['errors'] as Map<String, dynamic>?,
        );
      case null:
        return NetworkException(message: e.message);
      default:
        return ServerException(message: message, statusCode: statusCode);
    }
  }
}
