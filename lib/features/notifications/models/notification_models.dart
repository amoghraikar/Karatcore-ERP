import 'package:flutter/material.dart';

enum NotificationType {
  info('Info', Icons.info_outline_rounded, Color(0xFF2563EB)),
  success('Success', Icons.check_circle_outline_rounded, Color(0xFF059669)),
  warning('Warning', Icons.warning_amber_rounded, Color(0xFFD97706)),
  critical('Critical', Icons.error_outline_rounded, Color(0xFFDC2626)),
  security('Security', Icons.shield_outlined, Color(0xFF7C3AED));

  const NotificationType(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color color;
}

enum NotificationCategory {
  kyc('KYC Verification', Icons.verified_user_outlined),
  loans('Pledges & Loans', Icons.account_balance_outlined),
  payments('Payments & Receipts', Icons.payments_outlined),
  dueDates('Due Dates & Overdue', Icons.event_available_outlined),
  receipts('Receipts & Invoices', Icons.receipt_long_outlined),
  documents('Document Archival', Icons.folder_open_outlined),
  inventory('Inventory & Vault', Icons.diamond_outlined),
  accounting('Bookkeeping & Ledger', Icons.menu_book_outlined),
  security('Security & Access', Icons.security_rounded),
  system('System & Engine', Icons.settings_suggest_outlined);

  const NotificationCategory(this.label, this.icon);
  final String label;
  final IconData icon;
}

enum NotificationPriority {
  low('Low', Color(0xFF6B7280)),
  normal('Normal', Color(0xFF2563EB)),
  high('High', Color(0xFFD97706)),
  urgent('Urgent', Color(0xFFDC2626));

  const NotificationPriority(this.label, this.color);
  final String label;
  final Color color;
}

enum NotificationState {
  unread('Unread'),
  read('Read'),
  archived('Archived'),
  dismissed('Dismissed');

  const NotificationState(this.label);
  final String label;
}

enum CommunicationChannel {
  inApp('In-App Notification', Icons.notifications_active_outlined),
  email('Email (Placeholder)', Icons.email_outlined),
  sms('SMS Alert (Placeholder)', Icons.sms_outlined),
  whatsapp('WhatsApp (Placeholder)', Icons.chat_bubble_outline_rounded),
  push('Push Notification (Placeholder)', Icons.phonelink_ring_outlined);

  const CommunicationChannel(this.label, this.icon);
  final String label;
  final IconData icon;
}

enum CommunicationStatus {
  queued('Queued', Color(0xFF6B7280)),
  sent('Sent', Color(0xFF2563EB)),
  delivered('Delivered (Simulated)', Color(0xFF059669)),
  read('Read (Simulated)', Color(0xFF7C3AED)),
  failed('Delivery Failed', Color(0xFFDC2626));

  const CommunicationStatus(this.label, this.color);
  final String label;
  final Color color;
}

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.category,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.readAt,
    this.relatedEntityType,
    this.relatedEntityId,
    this.actionLabel,
    this.actionRoute,
    this.metadata,
  });

  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final NotificationCategory category;
  final NotificationPriority priority;
  final NotificationState status;
  final DateTime createdAt;
  final DateTime? readAt;
  final String? relatedEntityType;
  final String? relatedEntityId;
  final String? actionLabel;
  final String? actionRoute;
  final Map<String, dynamic>? metadata;

  bool get isUnread => status == NotificationState.unread;
  bool get isImportant => priority == NotificationPriority.high || priority == NotificationPriority.urgent;

  NotificationModel copyWith({
    NotificationState? status,
    DateTime? readAt,
  }) {
    return NotificationModel(
      id: id,
      title: title,
      message: message,
      type: type,
      category: category,
      priority: priority,
      status: status ?? this.status,
      createdAt: createdAt,
      readAt: readAt ?? this.readAt,
      relatedEntityType: relatedEntityType,
      relatedEntityId: relatedEntityId,
      actionLabel: actionLabel,
      actionRoute: actionRoute,
      metadata: metadata,
    );
  }
}

class MessageTemplateModel {
  const MessageTemplateModel({
    required this.templateId,
    required this.title,
    required this.messagePattern,
    required this.category,
    required this.channel,
    required this.variables,
  });

  final String templateId;
  final String title;
  final String messagePattern;
  final NotificationCategory category;
  final CommunicationChannel channel;
  final List<String> variables;

  String render(Map<String, String> values) {
    String output = messagePattern;
    values.forEach((key, val) {
      output = output.replaceAll('{$key}', val);
    });
    return output;
  }
}

class CommunicationLogModel {
  const CommunicationLogModel({
    required this.id,
    required this.recipientName,
    required this.recipientContact,
    required this.templateId,
    required this.title,
    required this.bodyMessage,
    required this.channel,
    required this.status,
    required this.createdAt,
    this.deliveredAt,
    this.readAt,
  });

  final String id;
  final String recipientName;
  final String recipientContact;
  final String templateId;
  final String title;
  final String bodyMessage;
  final CommunicationChannel channel;
  final CommunicationStatus status;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final DateTime? readAt;
}

class QuietHoursConfig {
  const QuietHoursConfig({
    this.isEnabled = false,
    this.startTime = '22:00',
    this.endTime = '08:00',
    this.allowCriticalExceptions = true,
  });

  final bool isEnabled;
  final String startTime;
  final String endTime;
  final bool allowCriticalExceptions;

  QuietHoursConfig copyWith({
    bool? isEnabled,
    String? startTime,
    String? endTime,
    bool? allowCriticalExceptions,
  }) {
    return QuietHoursConfig(
      isEnabled: isEnabled ?? this.isEnabled,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      allowCriticalExceptions: allowCriticalExceptions ?? this.allowCriticalExceptions,
    );
  }
}

class NotificationPreferencesModel {
  const NotificationPreferencesModel({
    this.loanAlertsEnabled = true,
    this.paymentAlertsEnabled = true,
    this.kycAlertsEnabled = true,
    this.securityAlertsEnabled = true,
    this.systemAlertsEnabled = true,
    this.inAppChannelEnabled = true,
    this.emailChannelEnabled = false,
    this.smsChannelEnabled = false,
    this.whatsappChannelEnabled = false,
    this.pushChannelEnabled = false,
    this.quietHours = const QuietHoursConfig(),
  });

  final bool loanAlertsEnabled;
  final bool paymentAlertsEnabled;
  final bool kycAlertsEnabled;
  final bool securityAlertsEnabled;
  final bool systemAlertsEnabled;
  final bool inAppChannelEnabled;
  final bool emailChannelEnabled;
  final bool smsChannelEnabled;
  final bool whatsappChannelEnabled;
  final bool pushChannelEnabled;
  final QuietHoursConfig quietHours;

  NotificationPreferencesModel copyWith({
    bool? loanAlertsEnabled,
    bool? paymentAlertsEnabled,
    bool? kycAlertsEnabled,
    bool? securityAlertsEnabled,
    bool? systemAlertsEnabled,
    bool? inAppChannelEnabled,
    bool? emailChannelEnabled,
    bool? smsChannelEnabled,
    bool? whatsappChannelEnabled,
    bool? pushChannelEnabled,
    QuietHoursConfig? quietHours,
  }) {
    return NotificationPreferencesModel(
      loanAlertsEnabled: loanAlertsEnabled ?? this.loanAlertsEnabled,
      paymentAlertsEnabled: paymentAlertsEnabled ?? this.paymentAlertsEnabled,
      kycAlertsEnabled: kycAlertsEnabled ?? this.kycAlertsEnabled,
      securityAlertsEnabled: securityAlertsEnabled ?? this.securityAlertsEnabled,
      systemAlertsEnabled: systemAlertsEnabled ?? this.systemAlertsEnabled,
      inAppChannelEnabled: inAppChannelEnabled ?? this.inAppChannelEnabled,
      emailChannelEnabled: emailChannelEnabled ?? this.emailChannelEnabled,
      smsChannelEnabled: smsChannelEnabled ?? this.smsChannelEnabled,
      whatsappChannelEnabled: whatsappChannelEnabled ?? this.whatsappChannelEnabled,
      pushChannelEnabled: pushChannelEnabled ?? this.pushChannelEnabled,
      quietHours: quietHours ?? this.quietHours,
    );
  }
}

class DueDateItemModel {
  const DueDateItemModel({
    required this.loanId,
    required this.customerName,
    required this.principalAmount,
    required this.interestDue,
    required this.dueDate,
    required this.daysRemaining,
    required this.isOverdue,
  });

  final String loanId;
  final String customerName;
  final double principalAmount;
  final double interestDue;
  final DateTime dueDate;
  final int daysRemaining;
  final bool isOverdue;
}
