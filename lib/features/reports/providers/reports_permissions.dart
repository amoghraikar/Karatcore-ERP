import '../../auth/models/user_role.dart';

class ReportPermissions {
  const ReportPermissions._();

  static const String viewReports = 'VIEW_REPORTS';
  static const String viewFinancialReports = 'VIEW_FINANCIAL_REPORTS';
  static const String viewCustomerReports = 'VIEW_CUSTOMER_REPORTS';
  static const String viewKycReports = 'VIEW_KYC_REPORTS';
  static const String viewInventoryReports = 'VIEW_INVENTORY_REPORTS';
  static const String viewLoanReports = 'VIEW_LOAN_REPORTS';
  static const String viewRiskReports = 'VIEW_RISK_REPORTS';
  static const String viewAuditReports = 'VIEW_AUDIT_REPORTS';
  static const String exportReports = 'EXPORT_REPORTS';

  static bool canPerform(UserRole role, String permission) {
    if (role == UserRole.owner || role == UserRole.admin) {
      return true;
    }
    if (role == UserRole.manager) {
      return permission != viewRiskReports && permission != viewAuditReports;
    }
    if (role == UserRole.employee) {
      return permission == viewReports || permission == viewCustomerReports || permission == viewInventoryReports;
    }
    return false;
  }
}
