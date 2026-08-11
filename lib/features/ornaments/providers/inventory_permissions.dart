import '../../auth/models/user_role.dart';

abstract final class InventoryPermissions {
  static bool canViewInventory(UserRole role) => role == UserRole.owner;
  static bool canCreateOrnament(UserRole role) => role == UserRole.owner;
  static bool canEditOrnament(UserRole role) => role == UserRole.owner;
  static bool canMoveOrnament(UserRole role) => role == UserRole.owner;
  static bool canAssignOwnership(UserRole role) => role == UserRole.owner;
  static bool canViewValuation(UserRole role) => role == UserRole.owner;
  static bool canEditValuation(UserRole role) => role == UserRole.owner;
  static bool canArchiveOrnament(UserRole role) => role == UserRole.owner;
  static bool canViewAudit(UserRole role) => role == UserRole.owner;
}
