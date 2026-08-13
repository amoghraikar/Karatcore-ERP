import 'package:flutter/material.dart';

class NavItem {
  const NavItem({
    required this.label,
    required this.path,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final String path;
  final IconData icon;
  final IconData selectedIcon;
}

class NavSection {
  const NavSection({this.sectionHeader, required this.items});
  final String? sectionHeader;
  final List<NavItem> items;
}

abstract final class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const verify = '/verify';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';
  static const selectBranch = '/select-branch';
  static const locked = '/locked';
  static const accessDenied = '/access-denied';

  static const dashboard = '/dashboard';
  static const customers = '/customers';
  static const customerCreate = '/customers/create';
  static const customerDetails = '/customers/:id';
  static const kyc = '/kyc';
  static const kycDetails = '/kyc/:customerId';
  static const kycStart = '/kyc/:customerId/start';
  static const kycReview = '/kyc/:customerId/review';
  static const kycHistory = '/kyc/:customerId/history';
  static const ornaments = '/inventory';
  static const ornamentCreate = '/inventory/create';
  static const ornamentDetails = '/inventory/:id';
  static const ornamentEdit = '/inventory/:id/edit';
  static const ornamentHistory = '/inventory/:id/history';
  static const inventoryMovements = '/inventory/movements';
  static const inventoryCategories = '/inventory/categories';
  static const inventoryLocations = '/inventory/locations';
  static const loans = '/loans';
  static const loanCreate = '/loans/create';
  static const loanDetails = '/loans/:id';
  static const loanEdit = '/loans/:id/edit';
  static const loanPayments = '/loans/:id/payments';
  static const loanSchedule = '/loans/:id/schedule';
  static const loanCollateral = '/loans/:id/collateral';
  static const loanHistory = '/loans/:id/history';
  static const loanAudit = '/loans/:id/audit';
  static const loanSettlement = '/loans/:id/settlement';
  static const loanRelease = '/loans/:id/release';
  static const loanRenew = '/loans/:id/renew';
  static const accounting = '/accounting';
  static const accountingAccounts = '/accounting/accounts';
  static const accountingAccountDetails = '/accounting/accounts/:id';
  static const accountingJournal = '/accounting/journal';
  static const accountingJournalCreate = '/accounting/journal/create';
  static const accountingTransactions = '/accounting/transactions';
  static const accountingTransactionDetails = '/accounting/transactions/:id';
  static const accountingCashBook = '/accounting/cash-book';
  static const accountingBankBook = '/accounting/bank-book';
  static const accountingIncome = '/accounting/income';
  static const accountingExpenses = '/accounting/expenses';
  static const accountingReceivables = '/accounting/receivables';
  static const accountingPayables = '/accounting/payables';
  static const accountingLedger = '/accounting/ledger';
  static const accountingTrialBalance = '/accounting/trial-balance';
  static const accountingProfitLoss = '/accounting/profit-loss';
  static const accountingBalanceSheet = '/accounting/balance-sheet';
  static const accountingCashFlow = '/accounting/cash-flow';
  static const accountingPeriods = '/accounting/periods';
  static const expenses = '/expenses';
  static const income = '/income';
  static const reports = '/reports';
  static const reportsExecutive = '/reports/executive';
  static const reportsCustomers = '/reports/customers';
  static const reportsKyc = '/reports/kyc';
  static const reportsInventory = '/reports/inventory';
  static const reportsLoans = '/reports/loans';
  static const reportsPayments = '/reports/payments';
  static const reportsAccounting = '/reports/accounting';
  static const reportsProfitability = '/reports/profitability';
  static const reportsRisk = '/reports/risk';
  static const reportsOperations = '/reports/operations';
  static const reportsAudit = '/reports/audit';
  static const reportsDetail = '/reports/:reportId';
  static const notifications = '/notifications';
  static const communication = '/communication';
  static const securityActivity = '/security/activity';
  static const settings = '/settings';
  static const settingsSecurity = '/settings/security';
  static const settingsBusiness = '/settings/business';
  static const settingsFinancial = '/settings/financial';
  static const settingsNotifications = '/settings/notifications';
  static const audit = '/audit';
  static const security = '/security';
  static const profile = '/profile';
  static const help = '/help';
  static const showcase = '/showcase';

  // Customer Portal Routes
  static const customerHome = '/customer';
  static const customerLoans = '/customer/loans';
  static const customerLoanDetail = '/customer/loans/:id';
  static const customerJewellery = '/customer/jewellery';
  static const customerJewelleryDetail = '/customer/jewellery/:id';
  static const customerPayments = '/customer/payments';
  static const customerDocuments = '/customer/documents';
  static const customerKyc = '/customer/kyc';
  static const customerNotifications = '/customer/notifications';
  static const customerProfile = '/customer/profile';

  static const List<NavSection> navigationSections = [
    NavSection(
      sectionHeader: 'Core Operations',
      items: [
        NavItem(label: 'Dashboard', path: dashboard, icon: Icons.dashboard_outlined, selectedIcon: Icons.dashboard_rounded),
        NavItem(label: 'Customers', path: customers, icon: Icons.people_outline_rounded, selectedIcon: Icons.people_rounded),
        NavItem(label: 'KYC Verification', path: kyc, icon: Icons.verified_user_outlined, selectedIcon: Icons.verified_user_rounded),
      ],
    ),
    NavSection(
      sectionHeader: 'Jewellery & Assets',
      items: [
        NavItem(label: 'Inventory & Stock', path: ornaments, icon: Icons.diamond_outlined, selectedIcon: Icons.diamond_rounded),
        NavItem(label: 'Pledges & Loans', path: loans, icon: Icons.account_balance_outlined, selectedIcon: Icons.account_balance_rounded),
      ],
    ),
    NavSection(
      sectionHeader: 'Finance & Analytics',
      items: [
        NavItem(label: 'Accounting Ledger', path: accounting, icon: Icons.menu_book_outlined, selectedIcon: Icons.menu_book_rounded),
        NavItem(label: 'Reports & Analytics', path: reports, icon: Icons.bar_chart_rounded, selectedIcon: Icons.bar_chart_rounded),
      ],
    ),
    NavSection(
      sectionHeader: 'Security & Audit',
      items: [
        NavItem(label: 'Audit Log', path: audit, icon: Icons.history_rounded, selectedIcon: Icons.history_rounded),
        NavItem(label: 'Security Activity', path: security, icon: Icons.security_rounded, selectedIcon: Icons.security_rounded),
        NavItem(label: 'Notifications', path: notifications, icon: Icons.notifications_outlined, selectedIcon: Icons.notifications_rounded),
      ],
    ),
    NavSection(
      sectionHeader: 'Store Administration',
      items: [
        NavItem(label: 'Owner Profile', path: profile, icon: Icons.person_outline_rounded, selectedIcon: Icons.person_rounded),
        NavItem(label: 'Store Settings', path: settings, icon: Icons.settings_outlined, selectedIcon: Icons.settings_rounded),
        NavItem(label: 'UI Kit Showcase', path: showcase, icon: Icons.widgets_outlined, selectedIcon: Icons.widgets_rounded),
        NavItem(label: 'Help & Docs', path: help, icon: Icons.help_outline_rounded, selectedIcon: Icons.help_rounded),
      ],
    ),
  ];

  static List<NavItem> get allNavItems {
    return navigationSections.expand((s) => s.items).toList();
  }
}
