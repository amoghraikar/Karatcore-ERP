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
    if (role == UserRole.owner) {
      return true;
    }
    return false;
  }
}
