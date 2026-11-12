import '../models/user.dart';
import 'api/api_client.dart';

class LegacyAuthService {
  final ApiClient _api = ApiClient.instance;

  /// Register a new account
  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/auth/register',
      requiresAuth: false,
      body: {'name': name.trim(), 'email': email.trim(), 'password': password},
      fromDataJson: (data) => data as Map<String, dynamic>,
    );

    final data = response.data;
    if (data == null) {
      throw Exception('Empty data received from registration.');
    }

    final token = data['token'] as String;
    final userData = data['user'] as Map<String, dynamic>;

    await _api.saveToken(token);
    await _api.saveUserData(userData);

    return User.fromJson(userData);
  }

  /// Login with email and password
  Future<User> login({required String email, required String password}) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/auth/login',
      requiresAuth: false,
      body: {'email': email.trim(), 'password': password},
      fromDataJson: (data) => data as Map<String, dynamic>,
    );

    final data = response.data;
    if (data == null) {
      throw Exception('Empty data received from login.');
    }

    final token = data['token'] as String;
    final userData = data['user'] as Map<String, dynamic>;

    await _api.saveToken(token);
    await _api.saveUserData(userData);

    return User.fromJson(userData);
  }

  /// Fetch authenticated user profile from backend
  Future<User> getCurrentUser() async {
    final response = await _api.get<User>(
      '/auth/me',
      requiresAuth: true,
      fromDataJson: (data) => User.fromJson(data as Map<String, dynamic>),
    );

    if (response.data != null) {
      await _api.saveUserData(response.data!.toJson());
      return response.data!;
    }

    throw Exception('Could not fetch user profile.');
  }

  /// Update user profile
  Future<User> updateProfile({required String name}) async {
    final response = await _api.put<User>(
      '/users/me',
      requiresAuth: true,
      body: {'name': name.trim()},
      fromDataJson: (data) => User.fromJson(data as Map<String, dynamic>),
    );

    if (response.data != null) {
      await _api.saveUserData(response.data!.toJson());
      return response.data!;
    }

    throw Exception('Could not update profile.');
  }

  /// Check if user has an active session
  Future<bool> isLoggedIn() async {
    return _api.hasToken();
  }

  /// Get locally cached user data
  Future<User?> getCachedUser() async {
    final data = await _api.getUserData();
    if (data != null) {
      return User.fromJson(data);
    }
    return null;
  }

  /// Log out and clear session
  Future<void> logout() async {
    await _api.clearAuth();
  }
}
