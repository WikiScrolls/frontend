class Env {
  // Override at runtime with --dart-define=API_BASE_URL=... for local dev/testing.
  // Production hosted backend URL defaults here so builds work without extra flags.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://backend-production-cc13.up.railway.app',
  );

  // For Flutter Web dev, you can route API calls through a local CORS proxy to avoid browser CORS issues.
  // Enable by building/running with: --dart-define=USE_CORS_PROXY=true
  // TEMPORARY: Set to true for web development
  static const bool useCorsProxy = bool.fromEnvironment('USE_CORS_PROXY', defaultValue: true);

  // The proxy base URL. Our simple proxy in scripts/cors-proxy.js defaults to http://localhost:8787
  static const String corsProxy = String.fromEnvironment('CORS_PROXY', defaultValue: 'http://localhost:8787');
}
