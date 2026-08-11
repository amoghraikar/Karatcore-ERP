import '../../auth/models/user_role.dart';

abstract final class KycPermissions {
  static bool canViewKyc(UserRole role) => role == UserRole.owner;
  static bool canStartKyc(UserRole role) => role == UserRole.owner;
  static bool canReviewKyc(UserRole role) => role == UserRole.owner;
  static bool canApproveKyc(UserRole role) => role == UserRole.owner;
  static bool canRejectKyc(UserRole role) => role == UserRole.owner;
  static bool canRequestReverification(UserRole role) => role == UserRole.owner;
  static bool canViewSensitiveDocument(UserRole role) => role == UserRole.owner;
  static bool canViewAuditTrail(UserRole role) => role == UserRole.owner;
}
