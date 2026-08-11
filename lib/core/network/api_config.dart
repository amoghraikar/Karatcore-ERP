enum DataSource {
  mock,
  api,
}

class ApiConfig {
  static DataSource currentSource = DataSource.mock;

  static String baseUrl = 'http://localhost:8000/api/v1';

  static bool get isApiMode => currentSource == DataSource.api;
  static bool get isMockMode => currentSource == DataSource.mock;
}
