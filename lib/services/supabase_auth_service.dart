import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../models/user.dart';

/// Authentication and basic profile metadata powered by Supabase Auth.
///
/// The user's display name is stored in Supabase Auth user_metadata
/// (full_name). No extra database table is required for this implementation.
class SupabaseAuthService {
  supabase.SupabaseClient get _client => supabase.Supabase.instance.client;

  User _toAppUser(supabase.User user) {
    final metadata = user.userMetadata ?? <String, dynamic>{};
    return User(
      id: user.id,
      name: (metadata['full_name'] as String?)?.trim().isNotEmpty == true
          ? (metadata['full_name'] as String).trim()
          : (user.email?.split('@').first ?? 'Traveler'),
      email: user.email ?? '',
      role: (metadata['role'] as String?) ?? 'traveler',
      createdAt: user.createdAt,
    );
  }

  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'full_name': name.trim(),
        'role': 'traveler',
      },
    );

    final user = response.user;
    if (user == null) {
      throw Exception('Supabase account could not be created. Please try again.');
    }

    // Supabase may require email confirmation before creating a session.
    if (response.session == null) {
      throw Exception(
        'Account created successfully. Please verify your email, then log in.',
      );
    }

    return _toAppUser(user);
  }

  Future<User> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw Exception('Login failed. Please check your email and password.');
    }
    return _toAppUser(user);
  }

  Future<User> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('No active Supabase session. Please log in again.');
    }
    return _toAppUser(user);
  }

  Future<User> updateProfile({required String name}) async {
    final response = await _client.auth.updateUser(
      supabase.UserAttributes(
        data: {'full_name': name.trim()},
      ),
    );

    final user = response.user;
    if (user == null) {
      throw Exception('Could not update your Supabase profile.');
    }
    return _toAppUser(user);
  }

  Future<bool> isLoggedIn() async =>
      _client.auth.currentSession != null;

  Future<User?> getCachedUser() async {
    final user = _client.auth.currentUser;
    return user == null ? null : _toAppUser(user);
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }
}
