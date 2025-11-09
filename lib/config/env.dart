class Env {
  // Use: flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );
}
