import 'package:flutter/material.dart';

abstract final class AppPermission {
  // Customer Permissions
  static const viewCustomers = 'VIEW_CUSTOMERS';
  static const createCustomer = 'CREATE_CUSTOMER';
  static const editCustomer = 'EDIT_CUSTOMER';
  static const archiveCustomer = 'ARCHIVE_CUSTOMER';
  static const viewCustomerFinancials = 'VIEW_CUSTOMER_FINANCIALS';

  // KYC Permissions
  static const viewKyc = 'VIEW_KYC';
  static const createKyc = 'CREATE_KYC';
  static const editKyc = 'EDIT_KYC';
  static const verifyKyc = 'VERIFY_KYC';
  static const rejectKyc = 'REJECT_KYC';
  static const requestReverification = 'REQUEST_REVERIFICATION';
  static const viewKycAudit = 'VIEW_KYC_AUDIT';

  // Inventory & Ornament Permissions
  static const viewInventory = 'VIEW_INVENTORY';
  static const createOrnament = 'CREATE_ORNAMENT';
  static const editOrnament = 'EDIT_ORNAMENT';
  static const moveInventory = 'MOVE_INVENTORY';
  static const adjustInventory = 'ADJUST_INVENTORY';
  static const viewInventoryFinancials = 'VIEW_INVENTORY_FINANCIALS';
  static const viewInventoryAudit = 'VIEW_INVENTORY_AUDIT';

  // Valuation Permissions
  static const viewValuation = 'VIEW_VALUATION';
  static const createValuation = 'CREATE_VALUATION';
  static const editValuation = 'EDIT_VALUATION';
  static const approveValuation = 'APPROVE_VALUATION';

  // Loan Permissions
  static const viewLoans = 'VIEW_LOANS';
  static const createLoan = 'CREATE_LOAN';
  static const editLoan = 'EDIT_LOAN';
  static const approveLoan = 'APPROVE_LOAN';
  static const rejectLoan = 'REJECT_LOAN';
  static const disburseLoan = 'DISBURSE_LOAN';
  static const renewLoan = 'RENEW_LOAN';
  static const closeLoan = 'CLOSE_LOAN';
  static const viewLoanFinancials = 'VIEW_LOAN_FINANCIALS';
  static const viewLoanAudit = 'VIEW_LOAN_AUDIT';

  // Payment Permissions
  static const viewPayments = 'VIEW_PAYMENTS';
  static const recordPayment = 'RECORD_PAYMENT';
  static const editPayment = 'EDIT_PAYMENT';
  static const reversePayment = 'REVERSE_PAYMENT';
  static const viewReceipts = 'VIEW_RECEIPTS';

  // Accounting Permissions
  static const viewAccounting = 'VIEW_ACCOUNTING';
  static const createAccount = 'CREATE_ACCOUNT';
  static const editAccount = 'EDIT_ACCOUNT';
  static const createJournal = 'CREATE_JOURNAL';
  static const editJournal = 'EDIT_JOURNAL';
  static const postTransaction = 'POST_TRANSACTION';
  static const reverseTransaction = 'REVERSE_TRANSACTION';
  static const createExpense = 'CREATE_EXPENSE';
  static const createIncome = 'CREATE_INCOME';
  static const viewLedger = 'VIEW_LEDGER';
  static const closeAccountingPeriod = 'CLOSE_ACCOUNTING_PERIOD';
  static const viewFinancialReports = 'VIEW_FINANCIAL_REPORTS';

  // Report Permissions
  static const viewReports = 'VIEW_REPORTS';
  static const viewCustomerReports = 'VIEW_CUSTOMER_REPORTS';
  static const viewKycReports = 'VIEW_KYC_REPORTS';
  static const viewInventoryReports = 'VIEW_INVENTORY_REPORTS';
  static const viewLoanReports = 'VIEW_LOAN_REPORTS';
  static const viewRiskReports = 'VIEW_RISK_REPORTS';
  static const viewAuditReports = 'VIEW_AUDIT_REPORTS';
  static const exportReports = 'EXPORT_REPORTS';

  // Staff Permissions
  static const viewStaff = 'VIEW_STAFF';
  static const createStaff = 'CREATE_STAFF';
  static const editStaff = 'EDIT_STAFF';
  static const deactivateStaff = 'DEACTIVATE_STAFF';
  static const manageRoles = 'MANAGE_ROLES';
  static const managePermissions = 'MANAGE_PERMISSIONS';
  static const viewStaffActivity = 'VIEW_STAFF_ACTIVITY';

  // Audit Permissions
  static const viewAudit = 'VIEW_AUDIT';
  static const viewSecurityAudit = 'VIEW_SECURITY_AUDIT';
  static const viewStaffAudit = 'VIEW_STAFF_AUDIT';
  static const viewAccountingAudit = 'VIEW_ACCOUNTING_AUDIT';

  // Settings Permissions
  static const viewSettings = 'VIEW_SETTINGS';
  static const editSettings = 'EDIT_SETTINGS';
  static const manageBranches = 'MANAGE_BRANCHES';
  static const manageDepartments = 'MANAGE_DEPARTMENTS';

  static List<String> get all => [
        viewCustomers, createCustomer, editCustomer, archiveCustomer, viewCustomerFinancials,
        viewKyc, createKyc, editKyc, verifyKyc, rejectKyc, requestReverification, viewKycAudit,
        viewInventory, createOrnament, editOrnament, moveInventory, adjustInventory, viewInventoryFinancials, viewInventoryAudit,
        viewValuation, createValuation, editValuation, approveValuation,
        viewLoans, createLoan, editLoan, approveLoan, rejectLoan, disburseLoan, renewLoan, closeLoan, viewLoanFinancials, viewLoanAudit,
        viewPayments, recordPayment, editPayment, reversePayment, viewReceipts,
        viewAccounting, createAccount, editAccount, createJournal, editJournal, postTransaction, reverseTransaction, createExpense, createIncome, viewLedger, closeAccountingPeriod, viewFinancialReports,
        viewReports, viewCustomerReports, viewKycReports, viewInventoryReports, viewLoanReports, viewRiskReports, viewAuditReports, exportReports,
        viewStaff, createStaff, editStaff, deactivateStaff, manageRoles, managePermissions, viewStaffActivity,
        viewAudit, viewSecurityAudit, viewStaffAudit, viewAccountingAudit,
        viewSettings, editSettings, manageBranches, manageDepartments,
      ];
}

enum StaffStatus {
  active('Active', Color(0xFF059669)),
  inactive('Inactive', Color(0xFF6B7280)),
  suspended('Suspended', Color(0xFFDC2626)),
  invited('Invited', Color(0xFF2563EB)),
  pendingActivation('Pending Activation', Color(0xFFD97706)),
  locked('Locked', Color(0xFF7C3AED));

  const StaffStatus(this.label, this.color);
  final String label;
  final Color color;
}

class AppRoleModel {
  const AppRoleModel({
    required this.code,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.defaultPermissions,
    this.isSystemRole = true,
  });

  final String code;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> defaultPermissions;
  final bool isSystemRole;
}

class StaffModel {
  const StaffModel({
    required this.id,
    required this.employeeId,
    required this.fullName,
    required this.email,
    required this.mobile,
    required this.avatarUrl,
    required this.roleCode,
    required this.department,
    required this.branchId,
    required this.branchName,
    required this.status,
    required this.joiningDate,
    required this.lastActive,
    this.customPermissions = const [],
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String employeeId;
  final String fullName;
  final String email;
  final String mobile;
  final String avatarUrl;
  final String roleCode;
  final String department;
  final String branchId;
  final String branchName;
  final StaffStatus status;
  final DateTime joiningDate;
  final DateTime lastActive;
  final List<String> customPermissions;
  final DateTime createdAt;
  final DateTime? updatedAt;

  bool get isOwner => roleCode.toUpperCase() == 'OWNER';

  StaffModel copyWith({
    String? fullName,
    String? email,
    String? mobile,
    String? roleCode,
    String? department,
    String? branchId,
    String? branchName,
    StaffStatus? status,
    List<String>? customPermissions,
    DateTime? updatedAt,
  }) {
    return StaffModel(
      id: id,
      employeeId: employeeId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      avatarUrl: avatarUrl,
      roleCode: roleCode ?? this.roleCode,
      department: department ?? this.department,
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      status: status ?? this.status,
      joiningDate: joiningDate,
      lastActive: lastActive,
      customPermissions: customPermissions ?? this.customPermissions,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class BranchModel {
  const BranchModel({
    required this.id,
    required this.code,
    required this.name,
    required this.address,
    required this.managerName,
    required this.staffCount,
    required this.isActive,
    required this.createdAt,
  });

  final String id;
  final String code;
  final String name;
  final String address;
  final String managerName;
  final int staffCount;
  final bool isActive;
  final DateTime createdAt;
}

class DepartmentModel {
  const DepartmentModel({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.headName,
    required this.staffCount,
  });

  final String id;
  final String name;
  final String code;
  final String description;
  final String headName;
  final int staffCount;
}

class StaffSessionModel {
  const StaffSessionModel({
    required this.id,
    required this.staffId,
    required this.deviceName,
    required this.platform,
    required this.ipAddress,
    required this.lastActive,
    required this.loginTime,
    required this.isCurrentSession,
  });

  final String id;
  final String staffId;
  final String deviceName;
  final String platform;
  final String ipAddress;
  final DateTime lastActive;
  final DateTime loginTime;
  final bool isCurrentSession;
}

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

class StaffAuditModel {
  const StaffAuditModel({
    required this.id,
    required this.timestamp,
    required this.actorName,
    required this.targetStaffId,
    required this.action,
    required this.description,
    required this.previousState,
    required this.newState,
    this.reason = '',
  });

  final String id;
  final DateTime timestamp;
  final String actorName;
  final String targetStaffId;
  final String action;
  final String description;
  final String previousState;
  final String newState;
  final String reason;
}
