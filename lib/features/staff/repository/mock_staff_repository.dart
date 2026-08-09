import 'package:flutter/material.dart';
import '../models/rbac_models.dart';
import 'staff_repository.dart';

class MockStaffRepository implements IStaffRepository {
  MockStaffRepository() {
    _initMockData();
  }

  late List<AppRoleModel> _roles;
  late List<StaffModel> _staffList;
  late List<BranchModel> _branches;
  late List<DepartmentModel> _departments;
  late List<StaffSessionModel> _sessions;
  late List<SecurityEventModel> _securityEvents;
  late List<StaffAuditModel> _auditTrail;

  void _initMockData() {
    final now = DateTime.now();

    _roles = [
      AppRoleModel(
        code: 'OWNER',
        name: 'Owner (Proprietor)',
        description: 'Full un-restricted store owner & business proprietor authority.',
        icon: Icons.verified_user_rounded,
        color: const Color(0xFF7C3AED),
        defaultPermissions: AppPermission.all,
        isSystemRole: true,
      ),
    ];

    _branches = [
      BranchModel(id: 'BR-001', code: 'HQ-MUM', name: 'Zaveri Bazaar Main Branch', address: '128 Zaveri Bazaar, Kalbadevi, Mumbai 400002', managerName: 'Vikramaditya Verma (Owner)', staffCount: 1, isActive: true, createdAt: now.subtract(const Duration(days: 365))),
      BranchModel(id: 'BR-002', code: 'BR-DEL', name: 'Karol Bagh Vault Branch', address: '45 Bank Street, Karol Bagh, New Delhi 110005', managerName: 'Unassigned', staffCount: 0, isActive: true, createdAt: now.subtract(const Duration(days: 180))),
      BranchModel(id: 'BR-003', code: 'BR-BLR', name: 'Commercial Street Branch', address: '92 Commercial Street, Bengaluru 560001', managerName: 'Unassigned', staffCount: 0, isActive: true, createdAt: now.subtract(const Duration(days: 90))),
    ];

    _departments = [
      const DepartmentModel(id: 'DEP-01', name: 'Executive Management', code: 'MGMT', description: 'Business strategy & proprietor oversight', headName: 'Vikramaditya Verma (Owner)', staffCount: 1),
      const DepartmentModel(id: 'DEP-02', name: 'Accounts & Finance', code: 'FIN', description: 'Financial bookkeeping, ledgers & taxation', headName: 'Vikramaditya Verma (Owner)', staffCount: 0),
      const DepartmentModel(id: 'DEP-03', name: 'Gold Loan Operations', code: 'LOAN', description: 'Loan appraisal, pledge intake & collection', headName: 'Vikramaditya Verma (Owner)', staffCount: 0),
      const DepartmentModel(id: 'DEP-04', name: 'KYC & Compliance', code: 'KYC', description: 'Customer verification & anti-fraud review', headName: 'Vikramaditya Verma (Owner)', staffCount: 0),
      const DepartmentModel(id: 'DEP-05', name: 'Jewellery & Vault Inventory', code: 'INV', description: 'Ornament cataloging & safe vault auditing', headName: 'Vikramaditya Verma (Owner)', staffCount: 0),
      const DepartmentModel(id: 'DEP-06', name: 'Cash Counter & POS', code: 'CASH', description: 'Direct customer cash intake & receipting', headName: 'Vikramaditya Verma (Owner)', staffCount: 0),
    ];

    _staffList = [
      StaffModel(
        id: 'STF-001',
        employeeId: 'EMP-1001',
        fullName: 'Demo Owner',
        email: 'owner@karatcore.com',
        mobile: '+91 98200 11223',
        avatarUrl: '',
        roleCode: 'OWNER',
        department: 'Executive Management',
        branchId: 'BR-001',
        branchName: 'Zaveri Bazaar Main Branch',
        status: StaffStatus.active,
        joiningDate: DateTime(2022, 1, 1),
        lastActive: now.subtract(const Duration(minutes: 5)),
        createdAt: DateTime(2022, 1, 1),
      ),
    ];

    _sessions = [
      StaffSessionModel(id: 'SES-01', staffId: 'STF-001', deviceName: 'MacBook Pro 16" (M3 Max)', platform: 'macOS 15.1', ipAddress: '192.168.1.45', lastActive: now, loginTime: now.subtract(const Duration(hours: 4)), isCurrentSession: true),
    ];

    _securityEvents = [
      SecurityEventModel(id: 'SEC-101', timestamp: now.subtract(const Duration(minutes: 5)), actorName: 'Vikramaditya Verma (Owner)', actorId: 'STF-001', eventType: 'LOGIN', description: 'Successful login via web terminal', deviceInfo: 'macOS Chrome 128.0', status: 'SUCCESS'),
    ];

    _auditTrail = [
      StaffAuditModel(id: 'AUD-501', timestamp: now.subtract(const Duration(days: 30)), actorName: 'Vikramaditya Verma (Owner)', targetStaffId: 'STF-001', action: 'STORE_INITIALIZED', description: 'Store initialized with 1 Owner account', previousState: 'NONE', newState: 'OWNER', reason: 'Single Proprietor setup'),
    ];
  }

  @override
  Future<List<StaffModel>> getStaffList() async => _staffList;

  @override
  Future<StaffModel?> getStaffById(String id) async {
    try {
      return _staffList.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<StaffModel> createStaff(StaffModel staff) async {
    _staffList.insert(0, staff);
    _auditTrail.insert(
      0,
      StaffAuditModel(
        id: 'AUD-${DateTime.now().millisecondsSinceEpoch}',
        timestamp: DateTime.now(),
        actorName: 'Current User',
        targetStaffId: staff.id,
        action: 'STAFF_CREATED',
        description: 'Created staff member ${staff.fullName} (${staff.employeeId})',
        previousState: 'NONE',
        newState: staff.roleCode,
      ),
    );
    return staff;
  }

  @override
  Future<StaffModel> updateStaff(StaffModel staff) async {
    final index = _staffList.indexWhere((s) => s.id == staff.id);
    if (index != -1) {
      _staffList[index] = staff;
    }
    return staff;
  }

  @override
  Future<void> deactivateStaff(String id, String reason) async {
    final index = _staffList.indexWhere((s) => s.id == id);
    if (index != -1) {
      _staffList[index] = _staffList[index].copyWith(status: StaffStatus.inactive);
      _auditTrail.insert(
        0,
        StaffAuditModel(
          id: 'AUD-${DateTime.now().millisecondsSinceEpoch}',
          timestamp: DateTime.now(),
          actorName: 'Current User',
          targetStaffId: id,
          action: 'STAFF_DEACTIVATED',
          description: 'Deactivated staff member status set to INACTIVE',
          previousState: 'ACTIVE',
          newState: 'INACTIVE',
          reason: reason,
        ),
      );
    }
  }

  @override
  Future<List<AppRoleModel>> getRoles() async => _roles;

  @override
  Future<AppRoleModel> createRole(AppRoleModel role) async {
    _roles.add(role);
    return role;
  }

  @override
  Future<List<BranchModel>> getBranches() async => _branches;

  @override
  Future<BranchModel> createBranch(BranchModel branch) async {
    _branches.add(branch);
    return branch;
  }

  @override
  Future<List<DepartmentModel>> getDepartments() async => _departments;

  @override
  Future<DepartmentModel> createDepartment(DepartmentModel department) async {
    _departments.add(department);
    return department;
  }

  @override
  Future<List<StaffSessionModel>> getSessionsForStaff(String staffId) async {
    return _sessions.where((s) => s.staffId == staffId || staffId == 'STF-001').toList();
  }

  @override
  Future<void> revokeSession(String sessionId) async {
    _sessions.removeWhere((s) => s.id == sessionId);
  }

  @override
  Future<List<SecurityEventModel>> getSecurityEvents() async => _securityEvents;

  @override
  Future<List<StaffAuditModel>> getAuditTrail(String staffId) async {
    return _auditTrail.where((a) => a.targetStaffId == staffId || staffId == 'ALL').toList();
  }

  @override
  Future<void> logAuditEvent(StaffAuditModel audit) async {
    _auditTrail.insert(0, audit);
  }
}
