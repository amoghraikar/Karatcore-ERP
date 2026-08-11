import '../models/notification_models.dart';

abstract class ICommunicationService {
  List<MessageTemplateModel> getTemplates();
  MessageTemplateModel? getTemplateById(String templateId);
  String renderTemplate(String templateId, Map<String, String> variables);
  CommunicationLogModel createSimulatedCommunication({
    required String recipientName,
    required String recipientContact,
    required String templateId,
    required Map<String, String> variables,
    required CommunicationChannel channel,
  });
}

class CommunicationService implements ICommunicationService {
  CommunicationService() {
    _initTemplates();
  }

  late final List<MessageTemplateModel> _templates;

  void _initTemplates() {
    _templates = [
      const MessageTemplateModel(
        templateId: 'LOAN_DUE_SOON',
        title: 'Loan Installment Due Reminder',
        messagePattern: 'Dear {customerName}, your KaratCore loan payment for {loanId} of ₹{amount} is due on {dueDate}. Please make payment to avoid overdue charges.',
        category: NotificationCategory.dueDates,
        channel: CommunicationChannel.sms,
        variables: ['customerName', 'loanId', 'amount', 'dueDate'],
      ),
      const MessageTemplateModel(
        templateId: 'LOAN_OVERDUE',
        title: 'Overdue Loan Notice',
        messagePattern: 'URGENT: Dear {customerName}, your loan {loanId} was due on {dueDate}. Outstanding interest is ₹{amount}. Please contact KaratCore immediately.',
        category: NotificationCategory.dueDates,
        channel: CommunicationChannel.whatsapp,
        variables: ['customerName', 'loanId', 'amount', 'dueDate'],
      ),
      const MessageTemplateModel(
        templateId: 'PAYMENT_RECEIVED',
        title: 'Payment Acknowledgment',
        messagePattern: 'Dear {customerName}, payment of ₹{amount} for loan {loanId} was successfully recorded. Receipt #{receiptNumber}. Thank you.',
        category: NotificationCategory.payments,
        channel: CommunicationChannel.sms,
        variables: ['customerName', 'loanId', 'amount', 'receiptNumber'],
      ),
      const MessageTemplateModel(
        templateId: 'PAYMENT_RECEIPT',
        title: 'Digital Pledge Receipt Available',
        messagePattern: 'Hello {customerName}, your digital receipt #{receiptNumber} for pledge loan {loanId} is ready. Track status at KaratCore.',
        category: NotificationCategory.receipts,
        channel: CommunicationChannel.whatsapp,
        variables: ['customerName', 'receiptNumber', 'loanId'],
      ),
      const MessageTemplateModel(
        templateId: 'KYC_VERIFIED',
        title: 'KYC Verification Approved',
        messagePattern: 'Dear {customerName}, your KYC verification is APPROVED. Your trust limit is set to {trustLevel}.',
        category: NotificationCategory.kyc,
        channel: CommunicationChannel.inApp,
        variables: ['customerName', 'trustLevel'],
      ),
      const MessageTemplateModel(
        templateId: 'KYC_REJECTED',
        title: 'KYC Document Verification Status',
        messagePattern: 'Dear {customerName}, your KYC verification requires update. Reason: {reason}. Please re-submit documents.',
        category: NotificationCategory.kyc,
        channel: CommunicationChannel.sms,
        variables: ['customerName', 'reason'],
      ),
      const MessageTemplateModel(
        templateId: 'LOAN_CLOSED',
        title: 'Pledge Loan Settlement & Closure',
        messagePattern: 'Dear {customerName}, loan {loanId} is fully settled and CLOSED. You may now claim your collateral ornaments.',
        category: NotificationCategory.loans,
        channel: CommunicationChannel.sms,
        variables: ['customerName', 'loanId'],
      ),
      const MessageTemplateModel(
        templateId: 'COLLATERAL_RELEASE_READY',
        title: 'Vault Gold Release Authorization',
        messagePattern: 'Dear {customerName}, gold ornament collateral for loan {loanId} is verified and ready for collection at vault counter.',
        category: NotificationCategory.inventory,
        channel: CommunicationChannel.whatsapp,
        variables: ['customerName', 'loanId'],
      ),
      const MessageTemplateModel(
        templateId: 'SECURITY_EVENT',
        title: 'Security Alert',
        messagePattern: 'Security Event Alert: {description} recorded at {timestamp} on device {deviceInfo}.',
        category: NotificationCategory.security,
        channel: CommunicationChannel.inApp,
        variables: ['description', 'timestamp', 'deviceInfo'],
      ),
    ];
  }

  @override
  List<MessageTemplateModel> getTemplates() => List.unmodifiable(_templates);

  @override
  MessageTemplateModel? getTemplateById(String templateId) {
    try {
      return _templates.firstWhere((t) => t.templateId == templateId);
    } catch (_) {
      return null;
    }
  }

  @override
  String renderTemplate(String templateId, Map<String, String> variables) {
    final template = getTemplateById(templateId);
    if (template == null) return 'Template $templateId not found.';
    return template.render(variables);
  }

  @override
  CommunicationLogModel createSimulatedCommunication({
    required String recipientName,
    required String recipientContact,
    required String templateId,
    required Map<String, String> variables,
    required CommunicationChannel channel,
  }) {
    final now = DateTime.now();
    final template = getTemplateById(templateId);
    final bodyMessage = template != null
        ? template.render(variables)
        : 'Message for $recipientName';

    final title = template?.title ?? 'Notification Alert';

    return CommunicationLogModel(
      id: 'COMM-${now.millisecondsSinceEpoch}',
      recipientName: recipientName,
      recipientContact: recipientContact,
      templateId: templateId,
      title: title,
      bodyMessage: bodyMessage,
      channel: channel,
      status: CommunicationStatus.delivered,
      createdAt: now,
      deliveredAt: now.add(const Duration(seconds: 2)),
      readAt: now.add(const Duration(minutes: 1)),
    );
  }
}
