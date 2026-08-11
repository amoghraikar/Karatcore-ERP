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

class MockNotificationRepository implements INotificationRepository {
  MockNotificationRepository() {
    _initMockData();
  }

  late List<NotificationModel> _notifications;
  late NotificationPreferencesModel _preferences;
  late List<CommunicationLogModel> _communicationLogs;

  void _initMockData() {
    final now = DateTime.now();

    _preferences = const NotificationPreferencesModel();

    _notifications = [
      NotificationModel(
        id: 'NOTIF-101',
        title: 'Loan Overdue Alert: KC-LN-00115',
        message: 'Loan KC-LN-00115 for Customer Sunita Devi is overdue by 14 days. Outstanding payment of ₹1,85,000 required.',
        type: NotificationType.critical,
        category: NotificationCategory.dueDates,
        priority: NotificationPriority.urgent,
        status: NotificationState.unread,
        createdAt: now.subtract(const Duration(minutes: 15)),
        relatedEntityType: 'LOAN',
        relatedEntityId: 'LN-102',
        actionLabel: 'View Overdue Loan',
        actionRoute: '/loans/LN-102',
      ),
      NotificationModel(
        id: 'NOTIF-102',
        title: 'Payment Received: ₹25,000 Recorded',
        message: 'Payment of ₹25,000 recorded for Loan KC-LN-00124 (Rajesh Kumar). Receipt #REC-2024-884 generated.',
        type: NotificationType.success,
        category: NotificationCategory.payments,
        priority: NotificationPriority.normal,
        status: NotificationState.unread,
        createdAt: now.subtract(const Duration(hours: 1, minutes: 20)),
        relatedEntityType: 'LOAN',
        relatedEntityId: 'LN-101',
        actionLabel: 'View Payment Receipt',
        actionRoute: '/loans/LN-101',
      ),
      NotificationModel(
        id: 'NOTIF-103',
        title: 'KYC Document Submission: Verification Pending',
        message: 'New customer Ramesh Patel submitted Aadhaar & PAN card documents. Requires Store Owner review.',
        type: NotificationType.info,
        category: NotificationCategory.kyc,
        priority: NotificationPriority.high,
        status: NotificationState.unread,
        createdAt: now.subtract(const Duration(hours: 2, minutes: 45)),
        relatedEntityType: 'CUSTOMER',
        relatedEntityId: 'KC-CUS-00102',
        actionLabel: 'Review KYC',
        actionRoute: '/kyc/KC-CUS-00102/start',
      ),
      NotificationModel(
        id: 'NOTIF-104',
        title: 'Loan Due Soon: KC-LN-00124',
        message: 'Loan KC-LN-00124 installment of ₹4,90,000 is due in 3 days. Automated SMS reminder sent to customer.',
        type: NotificationType.warning,
        category: NotificationCategory.dueDates,
        priority: NotificationPriority.high,
        status: NotificationState.unread,
        createdAt: now.subtract(const Duration(hours: 4)),
        relatedEntityType: 'LOAN',
        relatedEntityId: 'LN-101',
        actionLabel: 'View Schedule',
        actionRoute: '/loans/LN-101',
      ),
      NotificationModel(
        id: 'NOTIF-105',
        title: 'Security Notice: New Web Terminal Authorized',
        message: 'Store Owner session authenticated on macOS Chrome (IP: 192.168.1.45). Zero security incidents detected.',
        type: NotificationType.security,
        category: NotificationCategory.security,
        priority: NotificationPriority.normal,
        status: NotificationState.read,
        createdAt: now.subtract(const Duration(hours: 8)),
        relatedEntityType: 'SECURITY',
        relatedEntityId: 'SEC-101',
        actionLabel: 'Security Monitor',
        actionRoute: '/security',
      ),
      NotificationModel(
        id: 'NOTIF-106',
        title: 'Collateral Ornament Vault Deposit',
        message: 'Ornament #ORN-8821 (22K Gold Bangle 48.5g) deposited in Safe Vault A-12 following loan creation.',
        type: NotificationType.info,
        category: NotificationCategory.inventory,
        priority: NotificationPriority.low,
        status: NotificationState.read,
        createdAt: now.subtract(const Duration(days: 1)),
        relatedEntityType: 'ORNAMENT',
        relatedEntityId: 'ORN-8821',
        actionLabel: 'Vault Stock',
        actionRoute: '/inventory',
      ),
      NotificationModel(
        id: 'NOTIF-107',
        title: 'Monthly Accounting Period Close Warning',
        message: 'Accounting period for August 2026 is scheduled for monthly ledger reconciliation & close.',
        type: NotificationType.warning,
        category: NotificationCategory.accounting,
        priority: NotificationPriority.high,
        status: NotificationState.read,
        createdAt: now.subtract(const Duration(days: 1, hours: 5)),
        relatedEntityType: 'ACCOUNTING',
        relatedEntityId: 'ACC-PERIOD-08',
        actionLabel: 'General Ledger',
        actionRoute: '/accounting',
      ),
      NotificationModel(
        id: 'NOTIF-108',
        title: 'KYC Verified: Sunita Devi',
        message: 'Sunita Devi (CUST-002) KYC status set to VERIFIED Level 2 (Enhanced). Gold pledge cap increased.',
        type: NotificationType.success,
        category: NotificationCategory.kyc,
        priority: NotificationPriority.normal,
        status: NotificationState.read,
        createdAt: now.subtract(const Duration(days: 2)),
        relatedEntityType: 'CUSTOMER',
        relatedEntityId: 'CUST-002',
        actionLabel: 'Customer Profile',
        actionRoute: '/customers/CUST-002',
      ),
    ];

    _communicationLogs = [
      CommunicationLogModel(
        id: 'COMM-101',
        recipientName: 'Rajesh Kumar',
        recipientContact: '+91 98200 12345',
        templateId: 'LOAN_DUE_SOON',
        title: 'Loan Installment Due Reminder',
        bodyMessage: 'Dear Rajesh Kumar, your KaratCore loan payment for KC-LN-00124 of ₹4,90,000 is due on 14 Aug 2026.',
        channel: CommunicationChannel.sms,
        status: CommunicationStatus.delivered,
        createdAt: now.subtract(const Duration(hours: 4)),
        deliveredAt: now.subtract(const Duration(hours: 4, minutes: 1)),
        readAt: now.subtract(const Duration(hours: 3)),
      ),
      CommunicationLogModel(
        id: 'COMM-102',
        recipientName: 'Sunita Devi',
        recipientContact: '+91 98211 54321',
        templateId: 'LOAN_OVERDUE',
        title: 'Overdue Loan Notice',
        bodyMessage: 'URGENT: Dear Sunita Devi, your loan KC-LN-00115 was due on 28 Jul 2026. Outstanding interest is ₹1,85,000.',
        channel: CommunicationChannel.whatsapp,
        status: CommunicationStatus.read,
        createdAt: now.subtract(const Duration(days: 1)),
        deliveredAt: now.subtract(const Duration(days: 1)),
        readAt: now.subtract(const Duration(hours: 18)),
      ),
      CommunicationLogModel(
        id: 'COMM-103',
        recipientName: 'Ramesh Patel',
        recipientContact: '+91 98922 99887',
        templateId: 'KYC_VERIFIED',
        title: 'KYC Verification Approved',
        bodyMessage: 'Dear Ramesh Patel, your KYC verification is APPROVED. Your trust limit is set to Tier 1 Standard.',
        channel: CommunicationChannel.inApp,
        status: CommunicationStatus.sent,
        createdAt: now.subtract(const Duration(days: 2)),
        deliveredAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }

  @override
  Future<List<NotificationModel>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_notifications);
  }

  @override
  Future<NotificationModel?> getNotificationById(String id) async {
    try {
      return _notifications.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(
        status: NotificationState.read,
        readAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> markAsUnread(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(
        status: NotificationState.unread,
        readAt: null,
      );
    }
  }

  @override
  Future<void> markAllAsRead() async {
    final now = DateTime.now();
    _notifications = _notifications.map((n) {
      if (n.status == NotificationState.unread) {
        return n.copyWith(status: NotificationState.read, readAt: now);
      }
      return n;
    }).toList();
  }

  @override
  Future<void> archiveNotification(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(
        status: NotificationState.archived,
      );
    }
  }

  @override
  Future<void> dismissNotification(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(
        status: NotificationState.dismissed,
      );
    }
  }

  @override
  Future<NotificationPreferencesModel> getPreferences() async => _preferences;

  @override
  Future<NotificationPreferencesModel> updatePreferences(NotificationPreferencesModel preferences) async {
    _preferences = preferences;
    return _preferences;
  }

  @override
  Future<List<CommunicationLogModel>> getCommunicationLogs() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_communicationLogs);
  }

  @override
  Future<void> logCommunication(CommunicationLogModel log) async {
    _communicationLogs.insert(0, log);
  }
}
