import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/notification_models.dart';
import 'notification_repository.dart';

class ApiNotificationRepository implements INotificationRepository {
  ApiNotificationRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final dynamic data = await _api.get(ApiEndpoints.notifications);
      if (data is List) {
        return data.map((json) => _parseNotifFromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<NotificationModel?> getNotificationById(String id) async {
    try {
      final dynamic data = await _api.get('${ApiEndpoints.notifications}/$id');
      return _parseNotifFromJson(data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    await _api.post('${ApiEndpoints.notifications}/$id/read', body: {});
  }

  @override
  Future<void> markAsUnread(String id) async {
    await _api.post('${ApiEndpoints.notifications}/$id/unread', body: {});
  }

  @override
  Future<void> markAllAsRead() async {
    await _api.post('${ApiEndpoints.notifications}/read-all', body: {});
  }

  @override
  Future<void> archiveNotification(String id) async {
    await _api.post('${ApiEndpoints.notifications}/$id/archive', body: {});
  }

  @override
  Future<void> dismissNotification(String id) async {
    await _api.post('${ApiEndpoints.notifications}/$id/dismiss', body: {});
  }

  @override
  Future<NotificationPreferencesModel> getPreferences() async {
    try {
      final dynamic data = await _api.get('${ApiEndpoints.notifications}/preferences');
      return NotificationPreferencesModel(
        loanAlertsEnabled: data['loan_alerts_enabled'] as bool? ?? true,
        paymentAlertsEnabled: data['payment_alerts_enabled'] as bool? ?? true,
        kycAlertsEnabled: data['kyc_alerts_enabled'] as bool? ?? true,
        securityAlertsEnabled: data['security_alerts_enabled'] as bool? ?? true,
        systemAlertsEnabled: data['system_alerts_enabled'] as bool? ?? true,
        inAppChannelEnabled: data['in_app_channel_enabled'] as bool? ?? true,
        emailChannelEnabled: data['email_channel_enabled'] as bool? ?? false,
        smsChannelEnabled: data['sms_channel_enabled'] as bool? ?? false,
        whatsappChannelEnabled: data['whatsapp_channel_enabled'] as bool? ?? false,
        pushChannelEnabled: data['push_channel_enabled'] as bool? ?? false,
      );
    } catch (_) {
      return const NotificationPreferencesModel();
    }
  }

  @override
  Future<NotificationPreferencesModel> updatePreferences(NotificationPreferencesModel preferences) async {
    await _api.put(
      '${ApiEndpoints.notifications}/preferences',
      body: {
        'loan_alerts_enabled': preferences.loanAlertsEnabled,
        'payment_alerts_enabled': preferences.paymentAlertsEnabled,
        'kyc_alerts_enabled': preferences.kycAlertsEnabled,
        'security_alerts_enabled': preferences.securityAlertsEnabled,
        'system_alerts_enabled': preferences.systemAlertsEnabled,
        'in_app_channel_enabled': preferences.inAppChannelEnabled,
        'email_channel_enabled': preferences.emailChannelEnabled,
        'sms_channel_enabled': preferences.smsChannelEnabled,
        'whatsapp_channel_enabled': preferences.whatsappChannelEnabled,
        'push_channel_enabled': preferences.pushChannelEnabled,
      },
    );
    return preferences;
  }

  @override
  Future<List<CommunicationLogModel>> getCommunicationLogs() async {
    try {
      final dynamic data = await _api.get('${ApiEndpoints.notifications}/communication-logs');
      if (data is List) {
        return data.map((json) => _parseCommLogFromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> logCommunication(CommunicationLogModel log) async {
    await _api.post(
      '${ApiEndpoints.notifications}/communication-logs',
      body: {
        'recipient_name': log.recipientName,
        'recipient_contact': log.recipientContact,
        'template_id': log.templateId,
        'title': log.title,
        'body_message': log.bodyMessage,
        'channel': log.channel.name,
      },
    );
  }

  NotificationModel _parseNotifFromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: NotificationType.values.firstWhere((e) => e.name == json['type'], orElse: () => NotificationType.info),
      category: NotificationCategory.values.firstWhere((e) => e.name == json['category'], orElse: () => NotificationCategory.system),
      priority: NotificationPriority.values.firstWhere((e) => e.name == json['priority'], orElse: () => NotificationPriority.normal),
      status: NotificationState.values.firstWhere((e) => e.name == json['status'], orElse: () => NotificationState.unread),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      readAt: json['read_at'] != null ? DateTime.tryParse(json['read_at'] as String) : null,
      relatedEntityType: json['related_entity_type'] as String?,
      relatedEntityId: json['related_entity_id'] as String?,
      actionLabel: json['action_label'] as String?,
      actionRoute: json['action_route'] as String?,
    );
  }

  CommunicationLogModel _parseCommLogFromJson(Map<String, dynamic> json) {
    return CommunicationLogModel(
      id: json['id'] as String,
      recipientName: json['recipient_name'] as String? ?? '',
      recipientContact: json['recipient_contact'] as String? ?? '',
      templateId: json['template_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      bodyMessage: json['body_message'] as String? ?? '',
      channel: CommunicationChannel.values.firstWhere((e) => e.name == json['channel'], orElse: () => CommunicationChannel.sms),
      status: CommunicationStatus.values.firstWhere((e) => e.name == json['status'], orElse: () => CommunicationStatus.sent),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      deliveredAt: json['delivered_at'] != null ? DateTime.tryParse(json['delivered_at'] as String) : null,
      readAt: json['read_at'] != null ? DateTime.tryParse(json['read_at'] as String) : null,
    );
  }
}
