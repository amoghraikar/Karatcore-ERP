import 'package:flutter/foundation.dart';

@immutable
class BusinessProfileSettings {
  const BusinessProfileSettings({
    required this.storeName,
    required this.tagline,
    required this.bisRegistrationNo,
    required this.gstin,
    required this.ownerName,
    required this.contactEmail,
    required this.contactPhone,
    required this.address,
    required this.currencySymbol,
  });

  final String storeName;
  final String tagline;
  final String bisRegistrationNo;
  final String gstin;
  final String ownerName;
  final String contactEmail;
  final String contactPhone;
  final String address;
  final String currencySymbol;

  factory BusinessProfileSettings.defaultValues() {
    return const BusinessProfileSettings(
      storeName: 'Karatcore Jewellery & Gold Loans',
      tagline: 'Trusted Gold Loans & Certified Jewellery',
      bisRegistrationNo: 'BIS-HM-MH-400002-9812',
      gstin: '27AAACV9812A1Z4',
      ownerName: 'Store Owner',
      contactEmail: 'owner@karatcore.com',
      contactPhone: '+91 98200 12345',
      address: 'Zaveri Bazaar, Mumbai, MH 400002',
      currencySymbol: '₹',
    );
  }

  factory BusinessProfileSettings.fromJson(Map<String, dynamic> json) {
    return BusinessProfileSettings(
      storeName: json['store_name'] as String? ?? 'Karatcore Jewellery & Gold Loans',
      tagline: json['tagline'] as String? ?? '',
      bisRegistrationNo: json['bis_registration_no'] as String? ?? '',
      gstin: json['gstin'] as String? ?? '',
      ownerName: json['owner_name'] as String? ?? '',
      contactEmail: json['contact_email'] as String? ?? '',
      contactPhone: json['contact_phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      currencySymbol: json['currency_symbol'] as String? ?? '₹',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'store_name': storeName,
      'tagline': tagline,
      'bis_registration_no': bisRegistrationNo,
      'gstin': gstin,
      'owner_name': ownerName,
      'contact_email': contactEmail,
      'contact_phone': contactPhone,
      'address': address,
      'currency_symbol': currencySymbol,
    };
  }

  BusinessProfileSettings copyWith({
    String? storeName,
    String? tagline,
    String? bisRegistrationNo,
    String? gstin,
    String? ownerName,
    String? contactEmail,
    String? contactPhone,
    String? address,
    String? currencySymbol,
  }) {
    return BusinessProfileSettings(
      storeName: storeName ?? this.storeName,
      tagline: tagline ?? this.tagline,
      bisRegistrationNo: bisRegistrationNo ?? this.bisRegistrationNo,
      gstin: gstin ?? this.gstin,
      ownerName: ownerName ?? this.ownerName,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      address: address ?? this.address,
      currencySymbol: currencySymbol ?? this.currencySymbol,
    );
  }
}

@immutable
class SecuritySettings {
  const SecuritySettings({
    required this.requireBiometricLock,
    required this.requireOwnerPinForActions,
    required this.sessionTimeoutMinutes,
    required this.twoFactorAuthEnabled,
    required this.auditLogRetentionDays,
  });

  final bool requireBiometricLock;
  final bool requireOwnerPinForActions;
  final int sessionTimeoutMinutes;
  final bool twoFactorAuthEnabled;
  final int auditLogRetentionDays;

  factory SecuritySettings.defaultValues() {
    return const SecuritySettings(
      requireBiometricLock: true,
      requireOwnerPinForActions: true,
      sessionTimeoutMinutes: 15,
      twoFactorAuthEnabled: false,
      auditLogRetentionDays: 365,
    );
  }

  factory SecuritySettings.fromJson(Map<String, dynamic> json) {
    return SecuritySettings(
      requireBiometricLock: json['require_biometric_lock'] as bool? ?? true,
      requireOwnerPinForActions: json['require_owner_pin_for_actions'] as bool? ?? true,
      sessionTimeoutMinutes: json['session_timeout_minutes'] as int? ?? 15,
      twoFactorAuthEnabled: json['two_factor_auth_enabled'] as bool? ?? false,
      auditLogRetentionDays: json['audit_log_retention_days'] as int? ?? 365,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'require_biometric_lock': requireBiometricLock,
      'require_owner_pin_for_actions': requireOwnerPinForActions,
      'session_timeout_minutes': sessionTimeoutMinutes,
      'two_factor_auth_enabled': twoFactorAuthEnabled,
      'audit_log_retention_days': auditLogRetentionDays,
    };
  }

  SecuritySettings copyWith({
    bool? requireBiometricLock,
    bool? requireOwnerPinForActions,
    int? sessionTimeoutMinutes,
    bool? twoFactorAuthEnabled,
    int? auditLogRetentionDays,
  }) {
    return SecuritySettings(
      requireBiometricLock: requireBiometricLock ?? this.requireBiometricLock,
      requireOwnerPinForActions: requireOwnerPinForActions ?? this.requireOwnerPinForActions,
      sessionTimeoutMinutes: sessionTimeoutMinutes ?? this.sessionTimeoutMinutes,
      twoFactorAuthEnabled: twoFactorAuthEnabled ?? this.twoFactorAuthEnabled,
      auditLogRetentionDays: auditLogRetentionDays ?? this.auditLogRetentionDays,
    );
  }
}

@immutable
class FinancialSettings {
  const FinancialSettings({
    required this.gold24kRatePerGram,
    required this.gold22kRatePerGram,
    required this.gold18kRatePerGram,
    required this.silverRatePerGram,
    required this.maxLtvPercentage,
    required this.defaultMonthlyInterestRate,
    required this.penaltyInterestRate,
    required this.minTenureDays,
    required this.maxTenureMonths,
  });

  final double gold24kRatePerGram;
  final double gold22kRatePerGram;
  final double gold18kRatePerGram;
  final double silverRatePerGram;
  final double maxLtvPercentage;
  final double defaultMonthlyInterestRate;
  final double penaltyInterestRate;
  final int minTenureDays;
  final int maxTenureMonths;

  factory FinancialSettings.defaultValues() {
    return const FinancialSettings(
      gold24kRatePerGram: 7450.0,
      gold22kRatePerGram: 6830.0,
      gold18kRatePerGram: 5580.0,
      silverRatePerGram: 88.0,
      maxLtvPercentage: 75.0,
      defaultMonthlyInterestRate: 1.5,
      penaltyInterestRate: 2.0,
      minTenureDays: 7,
      maxTenureMonths: 36,
    );
  }

  factory FinancialSettings.fromJson(Map<String, dynamic> json) {
    return FinancialSettings(
      gold24kRatePerGram: (json['gold_24k_rate_per_gram'] as num?)?.toDouble() ?? 7450.0,
      gold22kRatePerGram: (json['gold_22k_rate_per_gram'] as num?)?.toDouble() ?? 6830.0,
      gold18kRatePerGram: (json['gold_18k_rate_per_gram'] as num?)?.toDouble() ?? 5580.0,
      silverRatePerGram: (json['silver_rate_per_gram'] as num?)?.toDouble() ?? 88.0,
      maxLtvPercentage: (json['max_ltv_percentage'] as num?)?.toDouble() ?? 75.0,
      defaultMonthlyInterestRate: (json['default_monthly_interest_rate'] as num?)?.toDouble() ?? 1.5,
      penaltyInterestRate: (json['penalty_interest_rate'] as num?)?.toDouble() ?? 2.0,
      minTenureDays: json['min_tenure_days'] as int? ?? 7,
      maxTenureMonths: json['max_tenure_months'] as int? ?? 36,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gold_24k_rate_per_gram': gold24kRatePerGram,
      'gold_22k_rate_per_gram': gold22kRatePerGram,
      'gold_18k_rate_per_gram': gold18kRatePerGram,
      'silver_rate_per_gram': silverRatePerGram,
      'max_ltv_percentage': maxLtvPercentage,
      'default_monthly_interest_rate': defaultMonthlyInterestRate,
      'penalty_interest_rate': penaltyInterestRate,
      'min_tenure_days': minTenureDays,
      'max_tenure_months': maxTenureMonths,
    };
  }

  FinancialSettings copyWith({
    double? gold24kRatePerGram,
    double? gold22kRatePerGram,
    double? gold18kRatePerGram,
    double? silverRatePerGram,
    double? maxLtvPercentage,
    double? defaultMonthlyInterestRate,
    double? penaltyInterestRate,
    int? minTenureDays,
    int? maxTenureMonths,
  }) {
    return FinancialSettings(
      gold24kRatePerGram: gold24kRatePerGram ?? this.gold24kRatePerGram,
      gold22kRatePerGram: gold22kRatePerGram ?? this.gold22kRatePerGram,
      gold18kRatePerGram: gold18kRatePerGram ?? this.gold18kRatePerGram,
      silverRatePerGram: silverRatePerGram ?? this.silverRatePerGram,
      maxLtvPercentage: maxLtvPercentage ?? this.maxLtvPercentage,
      defaultMonthlyInterestRate: defaultMonthlyInterestRate ?? this.defaultMonthlyInterestRate,
      penaltyInterestRate: penaltyInterestRate ?? this.penaltyInterestRate,
      minTenureDays: minTenureDays ?? this.minTenureDays,
      maxTenureMonths: maxTenureMonths ?? this.maxTenureMonths,
    );
  }
}

@immutable
class NotificationSettings {
  const NotificationSettings({
    required this.enableSmsAlerts,
    required this.enableWhatsappReminders,
    required this.enableEmailNotifications,
    required this.dueReminderDaysBefore,
    required this.overdueRepeatIntervalDays,
  });

  final bool enableSmsAlerts;
  final bool enableWhatsappReminders;
  final bool enableEmailNotifications;
  final int dueReminderDaysBefore;
  final int overdueRepeatIntervalDays;

  factory NotificationSettings.defaultValues() {
    return const NotificationSettings(
      enableSmsAlerts: true,
      enableWhatsappReminders: true,
      enableEmailNotifications: false,
      dueReminderDaysBefore: 3,
      overdueRepeatIntervalDays: 7,
    );
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      enableSmsAlerts: json['enable_sms_alerts'] as bool? ?? true,
      enableWhatsappReminders: json['enable_whatsapp_reminders'] as bool? ?? true,
      enableEmailNotifications: json['enable_email_notifications'] as bool? ?? false,
      dueReminderDaysBefore: json['due_reminder_days_before'] as int? ?? 3,
      overdueRepeatIntervalDays: json['overdue_repeat_interval_days'] as int? ?? 7,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enable_sms_alerts': enableSmsAlerts,
      'enable_whatsapp_reminders': enableWhatsappReminders,
      'enable_email_notifications': enableEmailNotifications,
      'due_reminder_days_before': dueReminderDaysBefore,
      'overdue_repeat_interval_days': overdueRepeatIntervalDays,
    };
  }

  NotificationSettings copyWith({
    bool? enableSmsAlerts,
    bool? enableWhatsappReminders,
    bool? enableEmailNotifications,
    int? dueReminderDaysBefore,
    int? overdueRepeatIntervalDays,
  }) {
    return NotificationSettings(
      enableSmsAlerts: enableSmsAlerts ?? this.enableSmsAlerts,
      enableWhatsappReminders: enableWhatsappReminders ?? this.enableWhatsappReminders,
      enableEmailNotifications: enableEmailNotifications ?? this.enableEmailNotifications,
      dueReminderDaysBefore: dueReminderDaysBefore ?? this.dueReminderDaysBefore,
      overdueRepeatIntervalDays: overdueRepeatIntervalDays ?? this.overdueRepeatIntervalDays,
    );
  }
}

@immutable
class SystemSettingsModel {
  const SystemSettingsModel({
    required this.business,
    required this.security,
    required this.financial,
    required this.notifications,
    required this.lastUpdated,
    required this.updatedBy,
  });

  final BusinessProfileSettings business;
  final SecuritySettings security;
  final FinancialSettings financial;
  final NotificationSettings notifications;
  final DateTime lastUpdated;
  final String updatedBy;

  factory SystemSettingsModel.defaultValues() {
    return SystemSettingsModel(
      business: BusinessProfileSettings.defaultValues(),
      security: SecuritySettings.defaultValues(),
      financial: FinancialSettings.defaultValues(),
      notifications: NotificationSettings.defaultValues(),
      lastUpdated: DateTime.now(),
      updatedBy: 'Chief Administrator',
    );
  }

  factory SystemSettingsModel.fromJson(Map<String, dynamic> json) {
    return SystemSettingsModel(
      business: BusinessProfileSettings.fromJson(json['business'] as Map<String, dynamic>? ?? {}),
      security: SecuritySettings.fromJson(json['security'] as Map<String, dynamic>? ?? {}),
      financial: FinancialSettings.fromJson(json['financial'] as Map<String, dynamic>? ?? {}),
      notifications: NotificationSettings.fromJson(json['notifications'] as Map<String, dynamic>? ?? {}),
      lastUpdated: json['last_updated'] != null ? DateTime.parse(json['last_updated'] as String) : DateTime.now(),
      updatedBy: json['updated_by'] as String? ?? 'Admin',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'business': business.toJson(),
      'security': security.toJson(),
      'financial': financial.toJson(),
      'notifications': notifications.toJson(),
      'last_updated': lastUpdated.toIso8601String(),
      'updated_by': updatedBy,
    };
  }

  SystemSettingsModel copyWith({
    BusinessProfileSettings? business,
    SecuritySettings? security,
    FinancialSettings? financial,
    NotificationSettings? notifications,
    DateTime? lastUpdated,
    String? updatedBy,
  }) {
    return SystemSettingsModel(
      business: business ?? this.business,
      security: security ?? this.security,
      financial: financial ?? this.financial,
      notifications: notifications ?? this.notifications,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
}
