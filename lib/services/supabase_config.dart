/// Supabase configuration.
///
/// Credentials are supplied at build/run time using --dart-define.
/// Never put a Supabase service_role/secret key in a Flutter application.
class SupabaseConfig {
  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isConfigured =>
      url.startsWith('https://') &&
      url.contains('.supabase.co') &&
      anonKey.isNotEmpty;

  /// Supabase Auth is the default when valid credentials are supplied.
  /// Set USE_SUPABASE_AUTH=false to use the original REST API auth instead.
  static const bool useSupabaseAuth =
      bool.fromEnvironment('USE_SUPABASE_AUTH', defaultValue: true);

  static bool get shouldUseSupabase =>
      useSupabaseAuth && isConfigured;
}
