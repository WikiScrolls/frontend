class Env {
  // Override at runtime with --dart-define=API_BASE_URL=... for local dev/testing.
  // Production hosted backend URL defaults here so builds work without extra flags.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://backend-production-cc13.up.railway.app',
  );
}
