import '../models/rbac_models.dart';

abstract class IStaffRepository {
  Future<List<StaffModel>> getStaffList();
  Future<StaffModel?> getStaffById(String id);
  Future<StaffModel> createStaff(StaffModel staff);
  Future<StaffModel> updateStaff(StaffModel staff);
  Future<void> deactivateStaff(String id, String reason);
  Future<List<AppRoleModel>> getRoles();
  Future<AppRoleModel> createRole(AppRoleModel role);
  Future<List<BranchModel>> getBranches();
  Future<BranchModel> createBranch(BranchModel branch);
  Future<List<DepartmentModel>> getDepartments();
  Future<DepartmentModel> createDepartment(DepartmentModel department);
  Future<List<StaffSessionModel>> getSessionsForStaff(String staffId);
  Future<void> revokeSession(String sessionId);
  Future<List<SecurityEventModel>> getSecurityEvents();
  Future<List<StaffAuditModel>> getAuditTrail(String staffId);
  Future<void> logAuditEvent(StaffAuditModel audit);
}
