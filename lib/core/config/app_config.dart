/// Global Environment & Application Configuration for KaratCore ERP.
abstract final class AppConfig {
  static const String appName = 'KaratCore ERP';
  static const String appSubtitle = 'Enterprise Jewellery Management System';
  static const String appVersion = '1.0.0+1';
  static const String organization = 'KaratCore Technologies';

  /// Supported locales
  static const String defaultLocale = 'en_IN';

  /// Pagination defaults
  static const int defaultPageSize = 25;

  /// Currency defaults
  static const String currencySymbol = '₹';
  static const String currencyCode = 'INR';
}
