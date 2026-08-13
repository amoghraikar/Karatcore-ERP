import '../models/notification_models.dart';

abstract class INotificationRepository {
  Future<List<NotificationModel>> getNotifications();
  Future<NotificationModel?> getNotificationById(String id);
  Future<void> markAsRead(String id);
  Future<void> markAsUnread(String id);
  Future<void> markAllAsRead();
  Future<void> archiveNotification(String id);
  Future<void> dismissNotification(String id);

  Future<NotificationPreferencesModel> getPreferences();
  Future<NotificationPreferencesModel> updatePreferences(NotificationPreferencesModel preferences);

  Future<List<CommunicationLogModel>> getCommunicationLogs();
  Future<void> logCommunication(CommunicationLogModel log);
}
