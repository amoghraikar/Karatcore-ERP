class EnvConfig {
  static const String appEnv = String.fromEnvironment('APP_ENV', defaultValue: 'development');
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8000/api/v1');

  static bool get isProduction => appEnv == 'production';
  static bool get isStaging => appEnv == 'staging';
  static bool get isDevelopment => appEnv == 'development';

  static bool get enableMockFallback => false;
  static bool get enableDebugLogs => !isProduction;
}
