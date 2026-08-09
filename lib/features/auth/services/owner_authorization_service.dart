import 'package:flutter/material.dart';
import '../../staff/models/rbac_models.dart';

enum SensitiveActionType {
  loanDisbursement,
  loanSettlement,
  collateralRelease,
  accountingPeriodClose,
  settingsModification,
  auditExport,
  customerArchive,
}

abstract class IOwnerAuthorizationService {
  bool isOwner(StaffModel? session);
  bool canAccessOwnerArea(StaffModel? session, String areaPath);
  bool canPerformSensitiveAction(StaffModel? session, SensitiveActionType action);
  Future<bool> requireOwnerConfirmation(
    BuildContext context, {
    required String actionLabel,
    required String description,
  });
}

class OwnerAuthorizationService implements IOwnerAuthorizationService {
  const OwnerAuthorizationService();

  @override
  bool isOwner(StaffModel? session) {
    if (session == null) return false;
    return session.roleCode.toUpperCase() == 'OWNER' || session.isOwner;
  }

  @override
  bool canAccessOwnerArea(StaffModel? session, String areaPath) {
    // Owner has full access to all areas of KaratCore ERP
    return true;
  }

  @override
  bool canPerformSensitiveAction(StaffModel? session, SensitiveActionType action) {
    // Owner is authorized for all sensitive ERP operations
    return true;
  }

  @override
  Future<bool> requireOwnerConfirmation(
    BuildContext context, {
    required String actionLabel,
    required String description,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.security_rounded, color: Color(0xFFD97706)),
            const SizedBox(width: 10),
            Text(actionLabel, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFF59E0B)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock_rounded, size: 18, color: Color(0xFFB45309)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Store Owner authorization required for this action. Confirm to record audit log entry.',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF92400E)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED), foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.check_rounded, size: 18),
            label: const Text('Authorize & Proceed'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }
}
