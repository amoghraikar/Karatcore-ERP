import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../accounting/providers/accounting_providers.dart';
import '../../customers/models/customer_model.dart';
import '../../customers/providers/customer_providers.dart';
import '../../kyc/models/kyc_model.dart';
import '../../kyc/providers/kyc_providers.dart';
import '../../loans/models/loan_model.dart';
import '../../loans/providers/loan_providers.dart';
import '../../ornaments/models/ornament_model.dart';
import '../../ornaments/providers/inventory_providers.dart';

import '../../../core/network/api_client.dart';
import '../models/reports_model.dart';
import '../repository/api_reports_repository.dart';
import '../repository/reports_repository.dart';
import '../services/export_service.dart';
import '../services/reports_calculation_service.dart';

final reportsRepositoryProvider = Provider<IReportsRepository>((ref) {
  return ApiReportsRepository(ref.watch(apiClientProvider));
});

final reportsCalculationServiceProvider = Provider<IReportsCalculationService>((ref) {
  return ReportsCalculationService();
});

final exportServiceProvider = Provider<IExportService>((ref) {
  return ExportService();
});

// Centralized Date Filter State Provider
class ReportDateFilterNotifier extends StateNotifier<ReportDateFilterModel> {
  ReportDateFilterNotifier()
      : super(
          ReportDateFilterModel(
            preset: DateFilterPreset.thisMonth,
            startDate: DateTime(DateTime.now().year, DateTime.now().month, 1),
            endDate: DateTime.now(),
          ),
        );

  void setPreset(DateFilterPreset preset) {
    final now = DateTime.now();
    DateTime start;
    DateTime end = now;

    switch (preset) {
      case DateFilterPreset.today:
        start = DateTime(now.year, now.month, now.day);
        break;
      case DateFilterPreset.yesterday:
        start = DateTime(now.year, now.month, now.day - 1);
        end = DateTime(now.year, now.month, now.day - 1, 23, 59, 59);
        break;
      case DateFilterPreset.thisWeek:
        start = now.subtract(Duration(days: now.weekday - 1));
        break;
      case DateFilterPreset.thisMonth:
        start = DateTime(now.year, now.month, 1);
        break;
      case DateFilterPreset.lastMonth:
        start = DateTime(now.year, now.month - 1, 1);
        end = DateTime(now.year, now.month, 0, 23, 59, 59);
        break;
      case DateFilterPreset.thisQuarter:
        final quarterMonth = ((now.month - 1) ~/ 3) * 3 + 1;
        start = DateTime(now.year, quarterMonth, 1);
        break;
      case DateFilterPreset.thisYear:
        start = DateTime(now.year, 1, 1);
        break;
      case DateFilterPreset.financialYear:
        start = DateTime(now.month >= 4 ? now.year : now.year - 1, 4, 1);
        break;
      case DateFilterPreset.custom:
        return;
    }

    state = state.copyWith(preset: preset, startDate: start, endDate: end);
  }

  void setCustomRange(DateTime start, DateTime end) {
    state = state.copyWith(preset: DateFilterPreset.custom, startDate: start, endDate: end);
  }

  void setComparisonMode(ComparisonMode mode) {
    state = state.copyWith(comparisonMode: mode);
  }

  void reset() {
    setPreset(DateFilterPreset.thisMonth);
  }
}

final reportDateFilterProvider = StateNotifierProvider<ReportDateFilterNotifier, ReportDateFilterModel>((ref) {
  return ReportDateFilterNotifier();
});

// Executive Dashboard Metrics Derived Provider
final executiveMetricsProvider = FutureProvider<ExecutiveDashboardMetrics>((ref) async {
  final customers = ref.watch(customerListProvider).value ?? const <CustomerModel>[];
  final kycRecords = ref.watch(kycQueueProvider).value ?? const <KycRecordModel>[];
  final ornaments = ref.watch(ornamentListProvider).value ?? const <OrnamentModel>[];
  final loans = ref.watch(loanListProvider).value ?? const <LoanModel>[];
  final accounts = await ref.watch(chartOfAccountsProvider(null).future);

  final calc = ref.read(reportsCalculationServiceProvider);
  return calc.calculateExecutiveMetrics(
    customers: customers,
    kycRecords: kycRecords,
    ornaments: ornaments,
    loans: loans,
    accounts: accounts,
  );
});

// Attention Items Provider
final attentionItemsProvider = FutureProvider<List<AttentionIndicatorItem>>((ref) async {
  final loans = ref.watch(loanListProvider).value ?? const <LoanModel>[];
  final kycRecords = ref.watch(kycQueueProvider).value ?? const <KycRecordModel>[];
  final ornaments = ref.watch(ornamentListProvider).value ?? const <OrnamentModel>[];
  final accounts = await ref.watch(chartOfAccountsProvider(null).future);

  final calc = ref.read(reportsCalculationServiceProvider);
  return calc.calculateAttentionItems(
    loans: loans,
    kycRecords: kycRecords,
    ornaments: ornaments,
    accounts: accounts,
  );
});

// Customer Analytics Provider
final customerAnalyticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final customers = ref.watch(customerListProvider).value ?? const <CustomerModel>[];
  final loans = ref.watch(loanListProvider).value ?? const <LoanModel>[];

  final calc = ref.read(reportsCalculationServiceProvider);
  return calc.calculateCustomerAnalytics(customers, loans);
});

// KYC Analytics Provider
final kycAnalyticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final kycRecords = ref.watch(kycQueueProvider).value ?? const <KycRecordModel>[];
  final calc = ref.read(reportsCalculationServiceProvider);
  return calc.calculateKycAnalytics(kycRecords);
});

// Inventory Analytics Provider
final inventoryAnalyticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final ornaments = ref.watch(ornamentListProvider).value ?? const <OrnamentModel>[];
  final calc = ref.read(reportsCalculationServiceProvider);
  return calc.calculateInventoryAnalytics(ornaments);
});

// Loan Analytics Provider
final loanAnalyticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final loans = ref.watch(loanListProvider).value ?? const <LoanModel>[];
  final calc = ref.read(reportsCalculationServiceProvider);
  return calc.calculateLoanAnalytics(loans);
});

// Payment Analytics Provider
final paymentAnalyticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final loans = ref.watch(loanListProvider).value ?? const <LoanModel>[];
  final calc = ref.read(reportsCalculationServiceProvider);
  return calc.calculatePaymentAnalytics(loans);
});

// Profitability Analytics Provider
final profitabilityAnalyticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final accounts = await ref.watch(chartOfAccountsProvider(null).future);
  final calc = ref.read(reportsCalculationServiceProvider);
  return calc.calculateProfitabilityAnalytics(accounts);
});

// Risk Analytics Provider
final riskAnalyticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final customers = ref.watch(customerListProvider).value ?? const <CustomerModel>[];
  final loans = ref.watch(loanListProvider).value ?? const <LoanModel>[];
  final kycRecords = ref.watch(kycQueueProvider).value ?? const <KycRecordModel>[];

  final calc = ref.read(reportsCalculationServiceProvider);
  return calc.calculateRiskAnalytics(customers, loans, kycRecords);
});

// Saved Views Provider
final savedReportViewsProvider = FutureProvider<List<SavedReportView>>((ref) async {
  final repo = ref.watch(reportsRepositoryProvider);
  return repo.getSavedReportViews();
});

// Unified Activity Feed Provider
final unifiedActivityFeedProvider = FutureProvider<List<UnifiedActivityItem>>((ref) async {
  final repo = ref.watch(reportsRepositoryProvider);
  return repo.getUnifiedActivityFeed();
});

// Staff Performance Provider
final staffPerformanceProvider = FutureProvider<List<StaffPerformanceItem>>((ref) async {
  final repo = ref.watch(reportsRepositoryProvider);
  return repo.getStaffPerformance();
});

// Customer Exposure Provider
final customerExposureProvider = FutureProvider<List<CustomerExposureReportItem>>((ref) async {
  final customers = ref.watch(customerListProvider).value ?? const <CustomerModel>[];
  final loans = ref.watch(loanListProvider).value ?? const <LoanModel>[];
  final calc = ref.read(reportsCalculationServiceProvider);
  return calc.calculateCustomerExposure(customers, loans);
});

// Collateral Report Provider
final collateralReportProvider = FutureProvider<List<CollateralReportItem>>((ref) async {
  final loans = ref.watch(loanListProvider).value ?? const <LoanModel>[];
  final ornaments = ref.watch(ornamentListProvider).value ?? const <OrnamentModel>[];
  final calc = ref.read(reportsCalculationServiceProvider);
  return calc.calculateCollateralReport(loans, ornaments);
});

// Inventory Weight Report Provider
final inventoryWeightReportProvider = FutureProvider<List<InventoryWeightReportItem>>((ref) async {
  final ornaments = ref.watch(ornamentListProvider).value ?? const <OrnamentModel>[];
  final calc = ref.read(reportsCalculationServiceProvider);
  return calc.calculateInventoryWeightReport(ornaments);
});

// Inventory Valuation Report Provider
final inventoryValuationReportProvider = FutureProvider<List<InventoryValuationReportItem>>((ref) async {
  final ornaments = ref.watch(ornamentListProvider).value ?? const <OrnamentModel>[];
  final calc = ref.read(reportsCalculationServiceProvider);
  return calc.calculateInventoryValuationReport(ornaments);
});
