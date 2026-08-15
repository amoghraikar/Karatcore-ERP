import '../models/settings_model.dart';

abstract class ISettingsRepository {
  Future<SystemSettingsModel> getSystemSettings();
  Future<SystemSettingsModel> updateBusinessProfile(BusinessProfileSettings business);
  Future<SystemSettingsModel> updateSecuritySettings(SecuritySettings security);
  Future<SystemSettingsModel> updateFinancialSettings(FinancialSettings financial);
  Future<SystemSettingsModel> updateNotificationSettings(NotificationSettings notifications);
  Future<SystemSettingsModel> resetToDefaults();
}
