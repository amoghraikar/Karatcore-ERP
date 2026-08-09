import '../../auth/models/user_role.dart';

abstract final class KycPermissions {
  static bool canViewKyc(UserRole role) => true; // All roles can view
  static bool canStartKyc(UserRole role) => true; // All roles can initiate
  static bool canReviewKyc(UserRole role) => role != UserRole.employee; // Manager, Admin, Owner
  static bool canApproveKyc(UserRole role) => role != UserRole.employee;
  static bool canRejectKyc(UserRole role) => role != UserRole.employee;
  static bool canRequestReverification(UserRole role) => role != UserRole.employee;
  static bool canViewSensitiveDocument(UserRole role) => role != UserRole.employee;
  static bool canViewAuditTrail(UserRole role) => true;
}
