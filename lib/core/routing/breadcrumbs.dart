import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/breadcrumb_item.dart';
import 'routes.dart';

final breadcrumbProvider = StateProvider<List<BreadcrumbItem>>((ref) {
  return [
    const BreadcrumbItem(label: 'KaratCore ERP', path: AppRoutes.dashboard),
    const BreadcrumbItem(label: 'Dashboard'),
  ];
});

void updateBreadcrumbsForPath(WidgetRef ref, String path) {
  List<BreadcrumbItem> items = [
    const BreadcrumbItem(label: 'KaratCore ERP', path: AppRoutes.dashboard),
  ];

  if (path.startsWith(AppRoutes.dashboard)) {
    items.add(const BreadcrumbItem(label: 'Dashboard'));
  } else if (path.startsWith(AppRoutes.customers)) {
    items.add(const BreadcrumbItem(label: 'Customers', path: AppRoutes.customers));
    if (path.contains('/create')) {
      items.add(const BreadcrumbItem(label: 'Create Customer'));
    } else if (path.contains('/KC-CUS-')) {
      final parts = path.split('/');
      final customerId = parts.isNotEmpty ? parts.last : 'Details';
      items.add(BreadcrumbItem(label: customerId));
    }
  } else if (path.startsWith(AppRoutes.kyc)) {
    items.add(const BreadcrumbItem(label: 'KYC Verification', path: AppRoutes.kyc));
    if (path.contains('/start')) {
      items.add(const BreadcrumbItem(label: 'Start KYC Wizard'));
    } else if (path.contains('/review')) {
      items.add(const BreadcrumbItem(label: 'Document Review'));
    } else if (path.contains('/history')) {
      items.add(const BreadcrumbItem(label: 'Audit Trail & Timeline'));
    } else if (path != AppRoutes.kyc) {
      final parts = path.split('/');
      final id = parts.isNotEmpty ? parts.last : 'Profile';
      items.add(BreadcrumbItem(label: id));
    }
  } else if (path.startsWith('/inventory') || path.startsWith('/ornaments')) {
    items.add(const BreadcrumbItem(label: 'Ornaments & Inventory', path: AppRoutes.ornaments));
    if (path.contains('/create')) {
      items.add(const BreadcrumbItem(label: 'Add Ornament Wizard'));
    } else if (path.contains('/movements')) {
      items.add(const BreadcrumbItem(label: 'Stock Movements Log'));
    } else if (path.contains('/categories')) {
      items.add(const BreadcrumbItem(label: 'Category Management'));
    } else if (path.contains('/locations')) {
      items.add(const BreadcrumbItem(label: 'Location Hierarchy'));
    } else if (path.contains('/history')) {
      items.add(const BreadcrumbItem(label: 'Ornament History'));
    } else if (path != AppRoutes.ornaments) {
      final parts = path.split('/');
      final id = parts.isNotEmpty ? parts.last : 'Details';
      items.add(BreadcrumbItem(label: id));
    }
  } else if (path.startsWith(AppRoutes.loans)) {
    items.add(const BreadcrumbItem(label: 'Gold Loans', path: AppRoutes.loans));
    if (path.contains('/create')) {
      items.add(const BreadcrumbItem(label: 'New Loan & Pledge Wizard'));
    } else if (path.contains('/payments')) {
      items.add(const BreadcrumbItem(label: 'Record Payment'));
    } else if (path.contains('/settlement')) {
      items.add(const BreadcrumbItem(label: 'Full Settlement'));
    } else if (path.contains('/release')) {
      items.add(const BreadcrumbItem(label: 'Collateral Release'));
    } else if (path.contains('/renew')) {
      items.add(const BreadcrumbItem(label: 'Loan Renewal'));
    } else if (path != AppRoutes.loans) {
      final parts = path.split('/');
      final id = parts.isNotEmpty ? parts.last : 'Details';
      items.add(BreadcrumbItem(label: id));
    }
  } else if (path.startsWith(AppRoutes.accounting)) {
    items.add(const BreadcrumbItem(label: 'Accounting Ledger', path: AppRoutes.accounting));
    if (path.contains('/accounts')) {
      items.add(const BreadcrumbItem(label: 'Chart of Accounts'));
    } else if (path.contains('/journal/create')) {
      items.add(const BreadcrumbItem(label: 'New Journal Entry'));
    } else if (path.contains('/journal')) {
      items.add(const BreadcrumbItem(label: 'Journal Entries'));
    } else if (path.contains('/transactions')) {
      items.add(const BreadcrumbItem(label: 'Transactions'));
    } else if (path.contains('/cash-book')) {
      items.add(const BreadcrumbItem(label: 'Cash Book'));
    } else if (path.contains('/bank-book')) {
      items.add(const BreadcrumbItem(label: 'Bank Book'));
    } else if (path.contains('/income')) {
      items.add(const BreadcrumbItem(label: 'Income'));
    } else if (path.contains('/expenses')) {
      items.add(const BreadcrumbItem(label: 'Expenses'));
    } else if (path.contains('/receivables')) {
      items.add(const BreadcrumbItem(label: 'Receivables'));
    } else if (path.contains('/payables')) {
      items.add(const BreadcrumbItem(label: 'Payables'));
    } else if (path.contains('/trial-balance')) {
      items.add(const BreadcrumbItem(label: 'Trial Balance'));
    } else if (path.contains('/profit-loss')) {
      items.add(const BreadcrumbItem(label: 'Profit & Loss'));
    } else if (path.contains('/balance-sheet')) {
      items.add(const BreadcrumbItem(label: 'Balance Sheet'));
    } else if (path.contains('/cash-flow')) {
      items.add(const BreadcrumbItem(label: 'Cash Flow'));
    } else if (path.contains('/periods')) {
      items.add(const BreadcrumbItem(label: 'Accounting Periods'));
    }
  } else if (path.startsWith(AppRoutes.expenses)) {
    items.add(const BreadcrumbItem(label: 'Expenses'));
  } else if (path.startsWith(AppRoutes.income)) {
    items.add(const BreadcrumbItem(label: 'Income / Revenue'));
  } else if (path.startsWith(AppRoutes.reports)) {
    items.add(const BreadcrumbItem(label: 'Reports & Analytics'));
  } else if (path.startsWith(AppRoutes.notifications)) {
    items.add(const BreadcrumbItem(label: 'Notifications'));
  } else if (path.startsWith(AppRoutes.settings)) {
    items.add(const BreadcrumbItem(label: 'Settings'));
  } else if (path.startsWith(AppRoutes.profile)) {
    items.add(const BreadcrumbItem(label: 'User Profile'));
  } else if (path.startsWith(AppRoutes.help)) {
    items.add(const BreadcrumbItem(label: 'Help & Documentation'));
  }

  ref.read(breadcrumbProvider.notifier).state = items;
}
