import '../../auth/models/user_role.dart';

class AccountingPermissions {
  const AccountingPermissions._();

  static const String viewAccounts = 'VIEW_ACCOUNTS';
  static const String createAccount = 'CREATE_ACCOUNT';
  static const String editAccount = 'EDIT_ACCOUNT';
  static const String viewLedger = 'VIEW_LEDGER';
  static const String createJournal = 'CREATE_JOURNAL';
  static const String editJournal = 'EDIT_JOURNAL';
  static const String postTransaction = 'POST_TRANSACTION';
  static const String reverseTransaction = 'REVERSE_TRANSACTION';
  static const String createExpense = 'CREATE_EXPENSE';
  static const String createIncome = 'CREATE_INCOME';
  static const String viewFinancialReports = 'VIEW_FINANCIAL_REPORTS';
  static const String closeAccountingPeriod = 'CLOSE_ACCOUNTING_PERIOD';
  static const String viewAccountingAudit = 'VIEW_ACCOUNTING_AUDIT';

  static bool canPerform(UserRole role, String permission) {
    if (role == UserRole.owner) {
      return true;
    }
    return false;
  }
}
