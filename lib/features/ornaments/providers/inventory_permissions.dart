import '../../auth/models/user_role.dart';

abstract final class InventoryPermissions {
  static bool canViewInventory(UserRole role) => true; // All roles can view
  static bool canCreateOrnament(UserRole role) => true; // All roles can log items
  static bool canEditOrnament(UserRole role) => role != UserRole.employee; // Manager, Admin, Owner
  static bool canMoveOrnament(UserRole role) => true;
  static bool canAssignOwnership(UserRole role) => true;
  static bool canViewValuation(UserRole role) => true;
  static bool canEditValuation(UserRole role) => role != UserRole.employee;
  static bool canArchiveOrnament(UserRole role) => role == UserRole.owner || role == UserRole.admin;
  static bool canViewAudit(UserRole role) => true;
}
