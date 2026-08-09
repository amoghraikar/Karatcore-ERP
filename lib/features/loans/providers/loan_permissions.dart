import '../../auth/models/user_role.dart';

abstract final class LoanPermissions {
  static bool canViewLoans(UserRole role) => true; // All roles can view
  static bool canCreateLoan(UserRole role) => true; // Employee, Manager, Admin, Owner
  static bool canEditLoan(UserRole role) => role != UserRole.employee; // Manager, Admin, Owner
  static bool canApproveLoan(UserRole role) => role == UserRole.manager || role == UserRole.admin || role == UserRole.owner;
  static bool canRejectLoan(UserRole role) => role == UserRole.manager || role == UserRole.admin || role == UserRole.owner;
  static bool canDisburseLoan(UserRole role) => role == UserRole.manager || role == UserRole.admin || role == UserRole.owner;
  static bool canRecordPayment(UserRole role) => true;
  static bool canSettleLoan(UserRole role) => true;
  static bool canRenewLoan(UserRole role) => role != UserRole.employee;
  static bool canReleaseCollateral(UserRole role) => role == UserRole.manager || role == UserRole.admin || role == UserRole.owner;
  static bool canViewFinancialDetails(UserRole role) => true;
  static bool canViewLoanAudit(UserRole role) => true;
}
