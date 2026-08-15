import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/accounting/presentation/pages/account_details_page.dart';
import '../../features/accounting/presentation/pages/accounting_page.dart';
import '../../features/accounting/presentation/pages/accounting_periods_page.dart';
import '../../features/accounting/presentation/pages/balance_sheet_page.dart';
import '../../features/accounting/presentation/pages/bank_book_page.dart';
import '../../features/accounting/presentation/pages/cash_book_page.dart';
import '../../features/accounting/presentation/pages/cash_flow_page.dart';
import '../../features/accounting/presentation/pages/chart_of_accounts_page.dart';
import '../../features/accounting/presentation/pages/create_journal_entry_page.dart';
import '../../features/accounting/presentation/pages/expenses_page.dart' as acc_exp;
import '../../features/accounting/presentation/pages/general_ledger_page.dart';
import '../../features/accounting/presentation/pages/income_page.dart' as acc_inc;
import '../../features/accounting/presentation/pages/journal_entries_page.dart';
import '../../features/accounting/presentation/pages/payables_page.dart';
import '../../features/accounting/presentation/pages/profit_loss_page.dart';
import '../../features/accounting/presentation/pages/receivables_page.dart';
import '../../features/accounting/presentation/pages/transaction_details_page.dart';
import '../../features/accounting/presentation/pages/transactions_page.dart';
import '../../features/accounting/presentation/pages/trial_balance_page.dart';
import '../../features/audit/presentation/pages/audit_log_page.dart';
import '../../features/auth/models/auth_state.dart';
import '../../features/auth/presentation/pages/access_denied_page.dart';
import '../../features/auth/presentation/pages/branch_selection_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/lock_screen_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/otp_verification_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/customer_portal/presentation/pages/customer_documents_page.dart';
import '../../features/customer_portal/presentation/pages/customer_home_page.dart';
import '../../features/customer_portal/presentation/pages/customer_jewellery_detail_page.dart';
import '../../features/customer_portal/presentation/pages/customer_jewellery_page.dart';
import '../../features/customer_portal/presentation/pages/customer_kyc_page.dart';
import '../../features/customer_portal/presentation/pages/customer_loan_detail_page.dart';
import '../../features/customer_portal/presentation/pages/customer_loans_page.dart';
import '../../features/customer_portal/presentation/pages/customer_notifications_page.dart';
import '../../features/customer_portal/presentation/pages/customer_payments_page.dart';
import '../../features/customer_portal/presentation/pages/customer_profile_page.dart';
import '../../features/customer_portal/presentation/pages/customer_shell_page.dart';
import '../../features/customers/presentation/pages/create_customer_page.dart';
import '../../features/customers/presentation/pages/customer_details_page.dart';
import '../../features/customers/presentation/pages/customers_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/expenses/presentation/pages/expenses_page.dart';
import '../../features/help/presentation/pages/help_page.dart';
import '../../features/income/presentation/pages/income_page.dart';
import '../../features/kyc/presentation/pages/kyc_history_audit_page.dart';
import '../../features/kyc/presentation/pages/kyc_page.dart';
import '../../features/kyc/presentation/pages/kyc_review_page.dart';
import '../../features/kyc/presentation/pages/kyc_start_wizard_page.dart';
import '../../features/loans/presentation/pages/collateral_release_page.dart';
import '../../features/loans/presentation/pages/create_loan_page.dart';
import '../../features/loans/presentation/pages/loan_details_page.dart';
import '../../features/loans/presentation/pages/loan_renewal_page.dart';
import '../../features/loans/presentation/pages/loan_settlement_page.dart';
import '../../features/loans/presentation/pages/loans_page.dart';
import '../../features/loans/presentation/pages/record_payment_page.dart';
import '../../features/notifications/presentation/pages/communication_log_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/ornaments/presentation/pages/create_ornament_page.dart';
import '../../features/ornaments/presentation/pages/inventory_categories_page.dart';
import '../../features/ornaments/presentation/pages/inventory_locations_page.dart';
import '../../features/ornaments/presentation/pages/inventory_movements_page.dart';
import '../../features/ornaments/presentation/pages/ornament_details_page.dart';
import '../../features/ornaments/presentation/pages/ornaments_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/reports/presentation/pages/accounting_reports_page.dart';
import '../../features/reports/presentation/pages/audit_reports_page.dart';
import '../../features/reports/presentation/pages/customer_reports_page.dart';
import '../../features/reports/presentation/pages/executive_overview_page.dart';
import '../../features/reports/presentation/pages/inventory_reports_page.dart';
import '../../features/reports/presentation/pages/kyc_reports_page.dart';
import '../../features/reports/presentation/pages/loan_reports_page.dart';
import '../../features/reports/presentation/pages/operational_reports_page.dart';
import '../../features/reports/presentation/pages/payment_reports_page.dart';
import '../../features/reports/presentation/pages/profitability_reports_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/reports/presentation/pages/risk_reports_page.dart';
import '../../features/reports/presentation/pages/saved_report_detail_page.dart';
import '../../features/security/presentation/pages/security_dashboard_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/pages/settings_subpages.dart';

import '../../shared/widgets/navigation/kc_bottom_navigation.dart';
import '../../shared/widgets/navigation/kc_navigation_rail.dart';
import '../../shared/widgets/navigation/kc_sidebar.dart';
import '../../shared/widgets/navigation/kc_top_bar.dart';
import '../extensions/context_extensions.dart';
import 'breadcrumbs.dart';
import 'routes.dart';

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this.ref) {
    ref.listen<AuthState>(authStateProvider, (_, __) {
      notifyListeners();
    });
  }
  final Ref ref;
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final currentPath = state.uri.path;

      final isAuthRoute = currentPath == AppRoutes.splash ||
          currentPath == AppRoutes.login ||
          currentPath == AppRoutes.register ||
          currentPath == AppRoutes.verify ||
          currentPath == AppRoutes.forgotPassword ||
          currentPath == AppRoutes.resetPassword;

      if (authState.status == AuthStatus.unauthenticated) {
        if (!isAuthRoute) {
          return AppRoutes.login;
        }
        return null;
      }

      if (authState.status == AuthStatus.pendingOtp) {
        if (currentPath != AppRoutes.verify) {
          return AppRoutes.verify;
        }
        return null;
      }

      if (authState.status == AuthStatus.pendingBranch) {
        if (currentPath != AppRoutes.selectBranch) {
          return AppRoutes.selectBranch;
        }
        return null;
      }

      if (authState.status == AuthStatus.locked || authState.status == AuthStatus.sessionExpired) {
        if (currentPath != AppRoutes.locked) {
          return AppRoutes.locked;
        }
        return null;
      }

      if (authState.status == AuthStatus.authenticated) {
        if (isAuthRoute || currentPath == AppRoutes.locked || currentPath == AppRoutes.selectBranch) {
          return AppRoutes.dashboard;
        }

        final ownerAuth = ref.read(ownerAuthorizationServiceProvider);
        if (!ownerAuth.canAccessOwnerArea(authState.session, currentPath) && currentPath != AppRoutes.accessDenied) {
          return AppRoutes.accessDenied;
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.verify,
        builder: (context, state) => const OtpVerificationPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (context, state) => const ResetPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.selectBranch,
        builder: (context, state) => const BranchSelectionPage(),
      ),
      GoRoute(
        path: AppRoutes.locked,
        builder: (context, state) => const LockScreenPage(),
      ),
      GoRoute(
        path: AppRoutes.accessDenied,
        builder: (context, state) => const AccessDeniedPage(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return _AppShell(currentPath: state.uri.toString(), child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: AppRoutes.customers,
            builder: (context, state) => const CustomersPage(),
          ),
          GoRoute(
            path: AppRoutes.customerCreate,
            builder: (context, state) => const CreateCustomerPage(),
          ),
          GoRoute(
            path: AppRoutes.customerDetails,
            builder: (context, state) => CustomerDetailsPage(id: state.pathParameters['id']),
          ),
          GoRoute(
            path: AppRoutes.kyc,
            builder: (context, state) => const KycPage(),
          ),
          GoRoute(
            path: AppRoutes.kycDetails,
            builder: (context, state) => KycReviewPage(customerId: state.pathParameters['customerId']),
          ),
          GoRoute(
            path: AppRoutes.kycStart,
            builder: (context, state) => KycStartWizardPage(customerId: state.pathParameters['customerId']),
          ),
          GoRoute(
            path: AppRoutes.kycReview,
            builder: (context, state) => KycReviewPage(customerId: state.pathParameters['customerId']),
          ),
          GoRoute(
            path: AppRoutes.kycHistory,
            builder: (context, state) => KycHistoryAuditPage(customerId: state.pathParameters['customerId']),
          ),
          GoRoute(
            path: AppRoutes.ornaments,
            builder: (context, state) => const OrnamentsPage(),
          ),
          GoRoute(
            path: AppRoutes.ornamentCreate,
            builder: (context, state) => const CreateOrnamentPage(),
          ),
          GoRoute(
            path: AppRoutes.ornamentDetails,
            builder: (context, state) => OrnamentDetailsPage(id: state.pathParameters['id']),
          ),
          GoRoute(
            path: AppRoutes.ornamentEdit,
            builder: (context, state) => OrnamentDetailsPage(id: state.pathParameters['id']),
          ),
          GoRoute(
            path: AppRoutes.ornamentHistory,
            builder: (context, state) => OrnamentDetailsPage(id: state.pathParameters['id']),
          ),
          GoRoute(
            path: AppRoutes.inventoryMovements,
            builder: (context, state) => const InventoryMovementsPage(),
          ),
          GoRoute(
            path: AppRoutes.inventoryCategories,
            builder: (context, state) => const InventoryCategoriesPage(),
          ),
          GoRoute(
            path: AppRoutes.inventoryLocations,
            builder: (context, state) => const InventoryLocationsPage(),
          ),
          GoRoute(
            path: AppRoutes.loans,
            builder: (context, state) => const LoansPage(),
          ),
          GoRoute(
            path: AppRoutes.loanCreate,
            builder: (context, state) => const CreateLoanPage(),
          ),
          GoRoute(
            path: AppRoutes.loanDetails,
            builder: (context, state) => LoanDetailsPage(id: state.pathParameters['id']),
          ),
          GoRoute(
            path: AppRoutes.loanEdit,
            builder: (context, state) => LoanDetailsPage(id: state.pathParameters['id']),
          ),
          GoRoute(
            path: AppRoutes.loanPayments,
            builder: (context, state) => RecordPaymentPage(id: state.pathParameters['id']),
          ),
          GoRoute(
            path: AppRoutes.loanSchedule,
            builder: (context, state) => LoanDetailsPage(id: state.pathParameters['id']),
          ),
          GoRoute(
            path: AppRoutes.loanCollateral,
            builder: (context, state) => LoanDetailsPage(id: state.pathParameters['id']),
          ),
          GoRoute(
            path: AppRoutes.loanHistory,
            builder: (context, state) => LoanDetailsPage(id: state.pathParameters['id']),
          ),
          GoRoute(
            path: AppRoutes.loanAudit,
            builder: (context, state) => LoanDetailsPage(id: state.pathParameters['id']),
          ),
          GoRoute(
            path: AppRoutes.loanSettlement,
            builder: (context, state) => LoanSettlementPage(id: state.pathParameters['id']),
          ),
          GoRoute(
            path: AppRoutes.loanRelease,
            builder: (context, state) => CollateralReleasePage(id: state.pathParameters['id']),
          ),
          GoRoute(
            path: AppRoutes.loanRenew,
            builder: (context, state) => LoanRenewalPage(id: state.pathParameters['id']),
          ),
          GoRoute(
            path: AppRoutes.accounting,
            builder: (context, state) => const AccountingPage(),
          ),
          GoRoute(
            path: AppRoutes.accountingAccounts,
            builder: (context, state) => const ChartOfAccountsPage(),
          ),
          GoRoute(
            path: AppRoutes.accountingAccountDetails,
            builder: (context, state) => AccountDetailsPage(id: state.pathParameters['id']),
          ),
          GoRoute(
            path: AppRoutes.accountingJournal,
            builder: (context, state) => const JournalEntriesPage(),
          ),
          GoRoute(
            path: AppRoutes.accountingJournalCreate,
            builder: (context, state) => const CreateJournalEntryPage(),
          ),
          GoRoute(
            path: AppRoutes.accountingTransactions,
            builder: (context, state) => const TransactionsPage(),
          ),
          GoRoute(
            path: AppRoutes.accountingTransactionDetails,
            builder: (context, state) => TransactionDetailsPage(id: state.pathParameters['id']),
          ),
          GoRoute(
            path: AppRoutes.accountingCashBook,
            builder: (context, state) => const CashBookPage(),
          ),
          GoRoute(
            path: AppRoutes.accountingBankBook,
            builder: (context, state) => const BankBookPage(),
          ),
          GoRoute(
            path: AppRoutes.accountingIncome,
            builder: (context, state) => const acc_inc.IncomePage(),
          ),
          GoRoute(
            path: AppRoutes.accountingExpenses,
            builder: (context, state) => const acc_exp.ExpensesPage(),
          ),
          GoRoute(
            path: AppRoutes.accountingReceivables,
            builder: (context, state) => const ReceivablesPage(),
          ),
          GoRoute(
            path: AppRoutes.accountingPayables,
            builder: (context, state) => const PayablesPage(),
          ),
          GoRoute(
            path: AppRoutes.accountingLedger,
            builder: (context, state) => const GeneralLedgerPage(),
          ),
          GoRoute(
            path: AppRoutes.accountingTrialBalance,
            builder: (context, state) => const TrialBalancePage(),
          ),
          GoRoute(
            path: AppRoutes.accountingProfitLoss,
            builder: (context, state) => const ProfitLossPage(),
          ),
          GoRoute(
            path: AppRoutes.accountingBalanceSheet,
            builder: (context, state) => const BalanceSheetPage(),
          ),
          GoRoute(
            path: AppRoutes.accountingCashFlow,
            builder: (context, state) => const CashFlowPage(),
          ),
          GoRoute(
            path: AppRoutes.accountingPeriods,
            builder: (context, state) => const AccountingPeriodsPage(),
          ),
          GoRoute(
            path: AppRoutes.expenses,
            builder: (context, state) => const ExpensesPage(),
          ),
          GoRoute(
            path: AppRoutes.income,
            builder: (context, state) => const IncomePage(),
          ),
          GoRoute(
            path: AppRoutes.reports,
            builder: (context, state) => const ReportsPage(),
          ),
          GoRoute(
            path: AppRoutes.reportsExecutive,
            builder: (context, state) => const ExecutiveOverviewPage(),
          ),
          GoRoute(
            path: AppRoutes.reportsCustomers,
            builder: (context, state) => const CustomerReportsPage(),
          ),
          GoRoute(
            path: AppRoutes.reportsKyc,
            builder: (context, state) => const KycReportsPage(),
          ),
          GoRoute(
            path: AppRoutes.reportsInventory,
            builder: (context, state) => const InventoryReportsPage(),
          ),
          GoRoute(
            path: AppRoutes.reportsLoans,
            builder: (context, state) => const LoanReportsPage(),
          ),
          GoRoute(
            path: AppRoutes.reportsPayments,
            builder: (context, state) => const PaymentReportsPage(),
          ),
          GoRoute(
            path: AppRoutes.reportsAccounting,
            builder: (context, state) => const AccountingReportsPage(),
          ),
          GoRoute(
            path: AppRoutes.reportsProfitability,
            builder: (context, state) => const ProfitabilityReportsPage(),
          ),
          GoRoute(
            path: AppRoutes.reportsRisk,
            builder: (context, state) => const RiskReportsPage(),
          ),
          GoRoute(
            path: AppRoutes.reportsOperations,
            builder: (context, state) => const OperationalReportsPage(),
          ),
          GoRoute(
            path: AppRoutes.reportsAudit,
            builder: (context, state) => const AuditReportsPage(),
          ),
          GoRoute(
            path: AppRoutes.reportsDetail,
            builder: (context, state) => SavedReportDetailPage(reportId: state.pathParameters['reportId']),
          ),
          GoRoute(
            path: AppRoutes.notifications,
            builder: (context, state) => const NotificationsPage(),
          ),
          GoRoute(
            path: AppRoutes.communication,
            builder: (context, state) => const CommunicationLogPage(),
          ),
          GoRoute(
            path: AppRoutes.securityActivity,
            builder: (context, state) => const SecurityDashboardPage(),
          ),
          GoRoute(
            path: AppRoutes.security,
            builder: (context, state) => const SecurityDashboardPage(),
          ),
          GoRoute(
            path: AppRoutes.audit,
            builder: (context, state) => const AuditLogPage(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (context, state) => const SettingsPage(),
          ),
          GoRoute(
            path: AppRoutes.settingsSecurity,
            builder: (context, state) => const SettingsSecurityPage(),
          ),
          GoRoute(
            path: AppRoutes.settingsBusiness,
            builder: (context, state) => const SettingsBusinessPage(),
          ),
          GoRoute(
            path: AppRoutes.settingsFinancial,
            builder: (context, state) => const SettingsFinancialPage(),
          ),
          GoRoute(
            path: AppRoutes.settingsNotifications,
            builder: (context, state) => const SettingsNotificationsPage(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: AppRoutes.help,
            builder: (context, state) => const HelpPage(),
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) => CustomerShellPage(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.customerHome,
            builder: (context, state) => const CustomerHomePage(),
          ),
          GoRoute(
            path: AppRoutes.customerLoans,
            builder: (context, state) => const CustomerLoansPage(),
          ),
          GoRoute(
            path: AppRoutes.customerLoanDetail,
            builder: (context, state) => CustomerLoanDetailPage(loanId: state.pathParameters['id'] ?? ''),
          ),
          GoRoute(
            path: AppRoutes.customerJewellery,
            builder: (context, state) => const CustomerJewelleryPage(),
          ),
          GoRoute(
            path: AppRoutes.customerJewelleryDetail,
            builder: (context, state) => CustomerJewelleryDetailPage(ornamentId: state.pathParameters['id'] ?? ''),
          ),
          GoRoute(
            path: AppRoutes.customerPayments,
            builder: (context, state) => const CustomerPaymentsPage(),
          ),
          GoRoute(
            path: AppRoutes.customerDocuments,
            builder: (context, state) => const CustomerDocumentsPage(),
          ),
          GoRoute(
            path: AppRoutes.customerKyc,
            builder: (context, state) => const CustomerKycPage(),
          ),
          GoRoute(
            path: AppRoutes.customerNotifications,
            builder: (context, state) => const CustomerNotificationsPage(),
          ),
          GoRoute(
            path: AppRoutes.customerProfile,
            builder: (context, state) => const CustomerProfilePage(),
          ),
        ],
      ),
    ],
  );
});

class _AppShell extends ConsumerStatefulWidget {
  const _AppShell({required this.currentPath, required this.child});
  final String currentPath;
  final Widget child;

  @override
  ConsumerState<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<_AppShell> {
  bool _sidebarCollapsed = false;

  @override
  void didUpdateWidget(covariant _AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPath != widget.currentPath) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        updateBreadcrumbsForPath(ref, widget.currentPath);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (context.isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            KcSidebar(
              currentPath: widget.currentPath,
              isCollapsed: _sidebarCollapsed,
              onToggleCollapse: () => setState(() => _sidebarCollapsed = !_sidebarCollapsed),
            ),
            Expanded(
              child: Column(
                children: [
                  const KcTopBar(),
                  Expanded(child: widget.child),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (context.isTablet) {
      return Scaffold(
        body: Row(
          children: [
            KcNavigationRail(currentPath: widget.currentPath),
            Expanded(
              child: Column(
                children: [
                  const KcTopBar(),
                  Expanded(child: widget.child),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Mobile layout
    return Scaffold(
      appBar: const KcTopBar(),
      drawer: Drawer(
        child: KcSidebar(
          currentPath: widget.currentPath,
          isCollapsed: false,
        ),
      ),
      body: widget.child,
      bottomNavigationBar: KcBottomNavigation(currentPath: widget.currentPath),
    );
  }
}
