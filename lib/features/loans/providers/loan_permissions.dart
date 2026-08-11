import '../../auth/models/user_role.dart';

abstract final class LoanPermissions {
  static bool canViewLoans(UserRole role) => role == UserRole.owner;
  static bool canCreateLoan(UserRole role) => role == UserRole.owner;
  static bool canEditLoan(UserRole role) => role == UserRole.owner;
  static bool canApproveLoan(UserRole role) => role == UserRole.owner;
  static bool canRejectLoan(UserRole role) => role == UserRole.owner;
  static bool canDisburseLoan(UserRole role) => role == UserRole.owner;
  static bool canRecordPayment(UserRole role) => role == UserRole.owner;
  static bool canSettleLoan(UserRole role) => role == UserRole.owner;
  static bool canRenewLoan(UserRole role) => role == UserRole.owner;
  static bool canReleaseCollateral(UserRole role) => role == UserRole.owner;
  static bool canViewFinancialDetails(UserRole role) => role == UserRole.owner;
  static bool canViewLoanAudit(UserRole role) => role == UserRole.owner;
}
