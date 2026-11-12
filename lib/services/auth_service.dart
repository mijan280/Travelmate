import '../models/user.dart';
import 'legacy_auth_service.dart';
import 'supabase_auth_service.dart';
import 'supabase_config.dart';

/// Keeps the app's existing AuthService API unchanged.
///
/// Supabase Auth is used when configured. Otherwise the original REST API
/// authentication remains available through LegacyAuthService.
class AuthService {
  final LegacyAuthService _legacy = LegacyAuthService();
  final SupabaseAuthService _supabase = SupabaseAuthService();

  bool get _useSupabase => SupabaseConfig.shouldUseSupabase;

  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) =>
      _useSupabase
          ? _supabase.register(name: name, email: email, password: password)
          : _legacy.register(name: name, email: email, password: password);

  Future<User> login({
    required String email,
    required String password,
  }) =>
      _useSupabase
          ? _supabase.login(email: email, password: password)
          : _legacy.login(email: email, password: password);

  Future<User> getCurrentUser() =>
      _useSupabase ? _supabase.getCurrentUser() : _legacy.getCurrentUser();

  Future<User> updateProfile({required String name}) =>
      _useSupabase
          ? _supabase.updateProfile(name: name)
          : _legacy.updateProfile(name: name);

  Future<bool> isLoggedIn() =>
      _useSupabase ? _supabase.isLoggedIn() : _legacy.isLoggedIn();

  Future<User?> getCachedUser() =>
      _useSupabase ? _supabase.getCachedUser() : _legacy.getCachedUser();

  Future<void> logout() =>
      _useSupabase ? _supabase.logout() : _legacy.logout();
}
