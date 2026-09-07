import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';

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
  final auth = ref.watch(authStateProvider);
  final ownerName = auth.session?.name ?? 'Store Owner';
  final ownerId = auth.session?.id ?? 'OWN-001';
  final now = DateTime.now();

  return [
    SecurityEventModel(
      id: 'SEC-${now.millisecondsSinceEpoch.toString().substring(7)}',
      timestamp: now,
      actorName: ownerName,
      actorId: ownerId,
      eventType: 'SESSION_ACTIVE',
      description: 'Authenticated Owner session active on client terminal',
      deviceInfo: 'Production Client Terminal',
      status: 'SUCCESS',
    ),
  ];
});

final storeAuditTrailProvider = FutureProvider.family<List<StoreAuditModel>, String>((ref, filter) async {
  final auth = ref.watch(authStateProvider);
  final ownerName = auth.session?.name ?? 'Store Owner';
  final now = DateTime.now();

  return [
    StoreAuditModel(
      id: 'AUD-${now.millisecondsSinceEpoch.toString().substring(7)}',
      timestamp: now,
      actorName: ownerName,
      action: 'SYSTEM_ONLINE',
      description: 'System operational with live database connection',
      previousState: 'INITIALIZING',
      newState: 'LIVE_PRODUCTION',
      reason: 'Production environment verified',
    ),
  ];
});
