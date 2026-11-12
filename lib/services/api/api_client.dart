import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/api_response.dart';
import 'api_config.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient._internal();
  static final ApiClient instance = ApiClient._internal();

  static const String _tokenKey = 'travelmate_auth_token';
  static const String _userKey = 'travelmate_user_data';

  String? _cachedToken;

  /// Retrieves the stored JWT token
  Future<String?> getToken() async {
    if (_cachedToken != null) return _cachedToken;
    final prefs = await SharedPreferences.getInstance();
    _cachedToken = prefs.getString(_tokenKey);
    return _cachedToken;
  }

  /// Saves the JWT token
  Future<void> saveToken(String token) async {
    _cachedToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Saves cached user JSON
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(userData));
  }

  /// Gets cached user JSON
  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_userKey);
    if (str == null || str.isEmpty) return null;
    try {
      return jsonDecode(str) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Clears token and user data (for Logout)
  Future<void> clearAuth() async {
    _cachedToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  /// Returns true if a valid token exists
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Prepares default HTTP headers with Bearer token if available
  Future<Map<String, String>> _getHeaders({bool requiresAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// Standard GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    bool requiresAuth = true,
    T Function(dynamic rawData)? fromDataJson,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    return _execute(() async {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      return http.get(url, headers: headers).timeout(ApiConfig.timeout);
    }, fromDataJson);
  }

  /// Standard POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    dynamic body,
    bool requiresAuth = true,
    T Function(dynamic rawData)? fromDataJson,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    return _execute(() async {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final encodedBody = body != null ? jsonEncode(body) : null;
      return http
          .post(url, headers: headers, body: encodedBody)
          .timeout(ApiConfig.timeout);
    }, fromDataJson);
  }

  /// Standard PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    dynamic body,
    bool requiresAuth = true,
    T Function(dynamic rawData)? fromDataJson,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    return _execute(() async {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final encodedBody = body != null ? jsonEncode(body) : null;
      return http
          .put(url, headers: headers, body: encodedBody)
          .timeout(ApiConfig.timeout);
    }, fromDataJson);
  }

  /// Standard DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    bool requiresAuth = true,
    T Function(dynamic rawData)? fromDataJson,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    return _execute(() async {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      return http.delete(url, headers: headers).timeout(ApiConfig.timeout);
    }, fromDataJson);
  }

  /// Centralized request execution and error handling
  Future<ApiResponse<T>> _execute<T>(
    Future<http.Response> Function() requestFn,
    T Function(dynamic rawData)? fromDataJson,
  ) async {
    try {
      final response = await requestFn();
      return _parseResponse<T>(response, fromDataJson);
    } on SocketException catch (_) {
      throw ApiException(
        message:
            'Cannot connect to backend server at ${ApiConfig.baseUrl}. '
            'Please verify the server is running and both laptop and phone are on the same Wi-Fi.',
        isNetworkError: true,
      );
    } on TimeoutException catch (_) {
      throw ApiException(
        message: 'Connection timed out. Server took more than 10 seconds to respond.',
        isNetworkError: true,
      );
    } on http.ClientException catch (e) {
      throw ApiException(
        message: 'Network client error: ${e.message}',
        isNetworkError: true,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Unexpected error: $e');
    }
  }

  /// Parses JSON response and validates HTTP status codes
  ApiResponse<T> _parseResponse<T>(
    http.Response response,
    T Function(dynamic rawData)? fromDataJson,
  ) {
    Map<String, dynamic> jsonBody;
    try {
      jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse<T>(
          success: true,
          message: 'Operation succeeded',
          data: null,
        );
      }
      throw ApiException(
        message:
            'Server returned unexpected response (HTTP ${response.statusCode})',
        statusCode: response.statusCode,
      );
    }

    final success = jsonBody['success'] == true;
    final message = jsonBody['message'] as String? ?? 'Request processed';

    if (!success || response.statusCode >= 400) {
      if (response.statusCode == 401) {
        clearAuth();
      }
      throw ApiException(message: message, statusCode: response.statusCode);
    }

    return ApiResponse.fromJson(jsonBody, fromDataJson);
  }
}
