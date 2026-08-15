import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/settings_model.dart';
import '../repository/api_settings_repository.dart';
import '../repository/settings_repository.dart';
import '../services/settings_service.dart';

final settingsRepositoryProvider = Provider<ISettingsRepository>((ref) {
  return ApiSettingsRepository(ref.watch(apiClientProvider));
});

final settingsServiceProvider = Provider<ISettingsService>((ref) {
  return SettingsService();
});

class SystemSettingsNotifier extends AsyncNotifier<SystemSettingsModel> {
  @override
  Future<SystemSettingsModel> build() async {
    final repo = ref.read(settingsRepositoryProvider);
    return await repo.getSystemSettings();
  }

  Future<void> updateBusinessProfile(BusinessProfileSettings business) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(settingsRepositoryProvider);
      return await repo.updateBusinessProfile(business);
    });
  }

  Future<void> updateSecuritySettings(SecuritySettings security) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(settingsRepositoryProvider);
      return await repo.updateSecuritySettings(security);
    });
  }

  Future<void> updateFinancialSettings(FinancialSettings financial) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(settingsRepositoryProvider);
      return await repo.updateFinancialSettings(financial);
    });
  }

  Future<void> updateNotificationSettings(NotificationSettings notifications) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(settingsRepositoryProvider);
      return await repo.updateNotificationSettings(notifications);
    });
  }

  Future<void> resetToDefaults() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(settingsRepositoryProvider);
      return await repo.resetToDefaults();
    });
  }
}

final systemSettingsProvider = AsyncNotifierProvider<SystemSettingsNotifier, SystemSettingsModel>(() {
  return SystemSettingsNotifier();
});

final businessProfileProvider = Provider<BusinessProfileSettings>((ref) {
  final settingsAsync = ref.watch(systemSettingsProvider);
  final authSession = ref.watch(authStateProvider).session;
  final biz = settingsAsync.value?.business ?? BusinessProfileSettings.defaultValues();

  if (authSession != null) {
    final sessionStoreName = authSession.storeName;
    return biz.copyWith(
      storeName: (sessionStoreName != null && sessionStoreName.trim().isNotEmpty) ? sessionStoreName : biz.storeName,
      ownerName: authSession.name.isNotEmpty ? authSession.name : biz.ownerName,
      contactEmail: authSession.email.isNotEmpty ? authSession.email : biz.contactEmail,
      contactPhone: authSession.phone.isNotEmpty ? authSession.phone : biz.contactPhone,
    );
  }
  return biz;
});

final securitySettingsProvider = Provider<SecuritySettings>((ref) {
  final settingsAsync = ref.watch(systemSettingsProvider);
  return settingsAsync.value?.security ?? SecuritySettings.defaultValues();
});

final financialSettingsProvider = Provider<FinancialSettings>((ref) {
  final settingsAsync = ref.watch(systemSettingsProvider);
  return settingsAsync.value?.financial ?? FinancialSettings.defaultValues();
});

final notificationSettingsProvider = Provider<NotificationSettings>((ref) {
  final settingsAsync = ref.watch(systemSettingsProvider);
  return settingsAsync.value?.notifications ?? NotificationSettings.defaultValues();
});
