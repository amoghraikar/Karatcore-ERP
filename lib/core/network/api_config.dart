class ApiConfig {
  static String get baseUrl {
    const envUrl = String.fromEnvironment('API_URL');
    if (envUrl.isNotEmpty) return envUrl;

    try {
      final host = Uri.base.host;
      if (host.isNotEmpty) {
        return 'http://$host:8000/api/v1';
      }
    } catch (_) {}

    return 'http://localhost:8000/api/v1';
  }
}
