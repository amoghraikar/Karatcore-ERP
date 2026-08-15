import '../../../core/network/api_client.dart';
import '../models/settings_model.dart';
import 'settings_repository.dart';

class ApiSettingsRepository implements ISettingsRepository {
  ApiSettingsRepository(this._api);

  final ApiClient _api;
  SystemSettingsModel _cache = SystemSettingsModel.defaultValues();

  @override
  Future<SystemSettingsModel> getSystemSettings() async {
    try {
      final dynamic data = await _api.get('/api/v1/settings');
      if (data is Map<String, dynamic>) {
        _cache = SystemSettingsModel.fromJson(data);
      }
    } catch (_) {
      // Use local in-memory defaults on network error or offline mode
    }
    return _cache;
  }

  @override
  Future<SystemSettingsModel> updateBusinessProfile(BusinessProfileSettings business) async {
    _cache = _cache.copyWith(
      business: business,
      lastUpdated: DateTime.now(),
    );
    try {
      await _api.post('/api/v1/settings/business', body: business.toJson());
    } catch (_) {}
    return _cache;
  }

  @override
  Future<SystemSettingsModel> updateSecuritySettings(SecuritySettings security) async {
    _cache = _cache.copyWith(
      security: security,
      lastUpdated: DateTime.now(),
    );
    try {
      await _api.post('/api/v1/settings/security', body: security.toJson());
    } catch (_) {}
    return _cache;
  }

  @override
  Future<SystemSettingsModel> updateFinancialSettings(FinancialSettings financial) async {
    _cache = _cache.copyWith(
      financial: financial,
      lastUpdated: DateTime.now(),
    );
    try {
      await _api.post('/api/v1/settings/financial', body: financial.toJson());
    } catch (_) {}
    return _cache;
  }

  @override
  Future<SystemSettingsModel> updateNotificationSettings(NotificationSettings notifications) async {
    _cache = _cache.copyWith(
      notifications: notifications,
      lastUpdated: DateTime.now(),
    );
    try {
      await _api.post('/api/v1/settings/notifications', body: notifications.toJson());
    } catch (_) {}
    return _cache;
  }

  @override
  Future<SystemSettingsModel> resetToDefaults() async {
    _cache = SystemSettingsModel.defaultValues();
    try {
      await _api.post('/api/v1/settings/reset');
    } catch (_) {}
    return _cache;
  }
}
