class ApiConfig {
  static String get baseUrl {
    const envUrl = String.fromEnvironment('API_URL');
    if (envUrl.isNotEmpty) {
      var url = envUrl.trim();
      if (url.endsWith('/')) {
        url = url.substring(0, url.length - 1);
      }
      return url;
    }

    const envBaseUrl = String.fromEnvironment('API_BASE_URL');
    if (envBaseUrl.isNotEmpty) {
      var url = envBaseUrl.trim();
      if (url.endsWith('/')) {
        url = url.substring(0, url.length - 1);
      }
      return url;
    }

    try {
      final host = Uri.base.host;
      if (host == 'localhost' || host == '127.0.0.1' || host.isEmpty) {
        return 'http://localhost:8000/api/v1';
      }
      // On cloud web domains (like *.vercel.app), use relative path so Vercel rewrites can proxy requests
      return '/api/v1';
    } catch (_) {}

    return 'http://localhost:8000/api/v1';
  }
}
