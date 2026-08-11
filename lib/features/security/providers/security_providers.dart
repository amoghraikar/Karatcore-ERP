import 'package:flutter_riverpod/flutter_riverpod.dart';

class SecurityEventModel {
  const SecurityEventModel({
    required this.id,
    required this.timestamp,
    required this.actorName,
    required this.actorId,
    required this.eventType,
    required this.description,
    required this.deviceInfo,
    required this.status,
  });

  final String id;
  final DateTime timestamp;
  final String actorName;
  final String actorId;
  final String eventType;
  final String description;
  final String deviceInfo;
  final String status;
}

class StoreAuditModel {
  const StoreAuditModel({
    required this.id,
    required this.timestamp,
    required this.actorName,
    required this.action,
    required this.description,
    required this.previousState,
    required this.newState,
    this.reason = '',
  });

  final String id;
  final DateTime timestamp;
  final String actorName;
  final String action;
  final String description;
  final String previousState;
  final String newState;
  final String reason;
}

final securityEventsProvider = FutureProvider<List<SecurityEventModel>>((ref) async {
  final now = DateTime.now();
  return [
    SecurityEventModel(
      id: 'SEC-101',
      timestamp: now.subtract(const Duration(minutes: 5)),
      actorName: 'Demo Owner',
      actorId: 'OWN-101',
      eventType: 'LOGIN',
      description: 'Successful Owner login via web terminal',
      deviceInfo: 'macOS Chrome 128.0',
      status: 'SUCCESS',
    ),
    SecurityEventModel(
      id: 'SEC-102',
      timestamp: now.subtract(const Duration(hours: 3)),
      actorName: 'Demo Owner',
      actorId: 'OWN-101',
      eventType: 'BIOMETRIC_AUTH',
      description: 'Biometric authorization confirmed for loan disbursement',
      deviceInfo: 'macOS TouchID',
      status: 'SUCCESS',
    ),
  ];
});

final storeAuditTrailProvider = FutureProvider.family<List<StoreAuditModel>, String>((ref, filter) async {
  final now = DateTime.now();
  return [
    StoreAuditModel(
      id: 'AUD-501',
      timestamp: now.subtract(const Duration(days: 30)),
      actorName: 'Demo Owner',
      action: 'STORE_INITIALIZED',
      description: 'Store initialized with Single Proprietor account',
      previousState: 'NONE',
      newState: 'SINGLE_OWNER',
      reason: 'Single Proprietor ERP Setup',
    ),
    StoreAuditModel(
      id: 'AUD-502',
      timestamp: now.subtract(const Duration(days: 2)),
      actorName: 'Demo Owner',
      action: 'LOAN_DISBURSED',
      description: 'Disbursed loan LN-2024-001 of ₹1,50,000 for customer CUST-101',
      previousState: 'APPROVED',
      newState: 'DISBURSED',
      reason: 'Pledge collateral verified',
    ),
    StoreAuditModel(
      id: 'AUD-503',
      timestamp: now.subtract(const Duration(hours: 12)),
      actorName: 'Demo Owner',
      action: 'SETTINGS_UPDATED',
      description: 'Updated store business financial rates and gold valuation formula',
      previousState: 'V1.0',
      newState: 'V1.1',
      reason: 'Market rate adjustment',
    ),
  ];
});
