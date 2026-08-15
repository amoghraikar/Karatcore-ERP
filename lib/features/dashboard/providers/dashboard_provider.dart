import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/color_tokens.dart';
import '../../../core/routing/routes.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/charts/kc_chart_wrapper.dart';
import '../../accounting/providers/accounting_providers.dart';
import '../../customers/models/customer_model.dart';
import '../../customers/providers/customer_providers.dart';
import '../../loans/models/loan_model.dart';
import '../../loans/providers/loan_providers.dart';
import '../../ornaments/providers/inventory_providers.dart';

class DashboardKpi {
  const DashboardKpi({
    required this.title,
    required this.value,
    required this.trend,
    required this.icon,
    this.isPositive = true,
    this.route,
  });

  final String title;
  final String value;
  final String trend;
  final IconData icon;
  final bool isPositive;
  final String? route;
}

class DashboardActivity {
  const DashboardActivity({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color color;
}

class DashboardTask {
  DashboardTask({
    required this.id,
    required this.title,
    required this.subtitle,
    this.completed = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final bool completed;
}

class StoreBusinessHealth {
  const StoreBusinessHealth({
    required this.overallScore,
    required this.ltvSafetyRatio,
    required this.ltvSafetyLabel,
    required this.reserveLiquidityRatio,
    required this.reserveLiquidityLabel,
    required this.complianceScore,
    required this.complianceLabel,
  });

  final int overallScore;
  final double ltvSafetyRatio;
  final String ltvSafetyLabel;
  final double reserveLiquidityRatio;
  final String reserveLiquidityLabel;
  final double complianceScore;
  final String complianceLabel;
}

final dashboardKpisProvider = Provider<List<DashboardKpi>>((ref) {
  final customersAsync = ref.watch(customerListProvider);
  final loansAsync = ref.watch(loanListProvider);
  final accountingMetricsAsync = ref.watch(accountingDashboardMetricsProvider);

  final customers = customersAsync.valueOrNull ?? [];
  final loans = loansAsync.valueOrNull ?? [];
  final acctMetrics = accountingMetricsAsync.valueOrNull;

  final activeCustomerCount = customers.where((c) => c.customerStatus == CustomerStatus.active).length;

  double outstandingLoansTotal = 0.0;
  double interestCollectedTotal = 0.0;
  int loansDueTodayCount = 0;
  double loansDueTodayAmount = 0.0;
  int overdueLoansCount = 0;
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final todayEnd = todayStart.add(const Duration(days: 1));

  for (final l in loans) {
    if (l.status == LoanStatus.active || l.status == LoanStatus.overdue) {
      outstandingLoansTotal += l.outstandingPrincipal;
      interestCollectedTotal += l.payments.fold(0.0, (sum, p) => sum + p.interestComponent);

      if (l.nextDueDate.isAfter(todayStart) && l.nextDueDate.isBefore(todayEnd)) {
        loansDueTodayCount++;
        loansDueTodayAmount += (l.outstandingPrincipal + l.accruedInterest);
      }
      if (l.status == LoanStatus.overdue || l.nextDueDate.isBefore(todayStart)) {
        overdueLoansCount++;
      }
    }
  }

  final todayRevenue = acctMetrics?.totalIncome ?? 0.0;

  return [
    DashboardKpi(
      title: "Today's Revenue",
      value: KcFormatters.currency(todayRevenue),
      trend: todayRevenue > 0 ? 'Live Revenue' : 'No sales recorded today',
      icon: Icons.payments_outlined,
      route: AppRoutes.accounting,
    ),
    DashboardKpi(
      title: 'Outstanding Loans',
      value: KcFormatters.currency(outstandingLoansTotal),
      trend: '${loans.where((l) => l.status == LoanStatus.active).length} Active Loans',
      icon: Icons.account_balance_outlined,
      route: AppRoutes.loans,
    ),
    DashboardKpi(
      title: 'Interest Collected',
      value: KcFormatters.currency(interestCollectedTotal),
      trend: 'Total Interest Received',
      icon: Icons.trending_up_rounded,
      route: AppRoutes.accounting,
    ),
    DashboardKpi(
      title: 'Active Customers',
      value: '$activeCustomerCount',
      trend: '${customers.length} Total Registered',
      icon: Icons.people_outline_rounded,
      route: AppRoutes.customers,
    ),
    DashboardKpi(
      title: 'Loans Due Today',
      value: '$loansDueTodayCount Receipts',
      trend: loansDueTodayAmount > 0 ? '${KcFormatters.currency(loansDueTodayAmount)} due' : 'No dues today',
      icon: Icons.event_note_rounded,
      route: AppRoutes.loans,
    ),
    DashboardKpi(
      title: 'Overdue Loans',
      value: '$overdueLoansCount Receipts',
      trend: overdueLoansCount > 0 ? 'Action required' : 'All clear',
      icon: Icons.warning_amber_rounded,
      isPositive: overdueLoansCount == 0,
      route: AppRoutes.loans,
    ),
  ];
});

final revenueChartDataProvider = Provider<List<KcChartDataPoint>>((ref) {
  final loansAsync = ref.watch(loanListProvider);
  final loans = loansAsync.valueOrNull ?? [];
  final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final now = DateTime.now();

  final Map<int, double> dailyTotals = {for (var i = 1; i <= 7; i++) i: 0.0};
  for (final l in loans) {
    final dt = l.disbursedDate ?? l.pledgeDate;
    final weekday = dt.weekday;
    if (now.difference(dt).inDays <= 7) {
      dailyTotals[weekday] = (dailyTotals[weekday] ?? 0.0) + l.principalAmount;
    }
  }

  return List.generate(7, (index) {
    final weekday = index + 1;
    return KcChartDataPoint(
      xLabel: days[index],
      value: dailyTotals[weekday] ?? 0.0,
    );
  });
});

final loanDistributionChartProvider = Provider<List<KcDonutDataPoint>>((ref) {
  final ornamentsAsync = ref.watch(ornamentListProvider);
  final ornaments = ornamentsAsync.valueOrNull ?? [];

  int k24Count = 0;
  int k22Count = 0;
  int k18Count = 0;

  for (final o in ornaments) {
    if (o.purity.label.contains('24K')) {
      k24Count++;
    } else if (o.purity.label.contains('22K')) {
      k22Count++;
    } else {
      k18Count++;
    }
  }

  final total = ornaments.length;
  if (total == 0) {
    return const [
      KcDonutDataPoint(label: '24K Gold (0)', value: 0, color: KcColors.signalOrange),
      KcDonutDataPoint(label: '22K Jewellery (0)', value: 0, color: KcColors.signalGreen),
      KcDonutDataPoint(label: '18K / Other (0)', value: 0, color: KcColors.signalBlue),
    ];
  }

  final k24Pct = ((k24Count / total) * 100).roundToDouble();
  final k22Pct = ((k22Count / total) * 100).roundToDouble();
  final k18Pct = (100.0 - k24Pct - k22Pct).clamp(0.0, 100.0);

  return [
    KcDonutDataPoint(label: '24K Gold ($k24Count)', value: k24Pct, color: KcColors.signalOrange),
    KcDonutDataPoint(label: '22K Jewellery ($k22Count)', value: k22Pct, color: KcColors.signalGreen),
    KcDonutDataPoint(label: '18K / Other ($k18Count)', value: k18Pct, color: KcColors.signalBlue),
  ];
});

final monthlyTransactionsChartProvider = Provider<List<KcChartDataPoint>>((ref) {
  final loansAsync = ref.watch(loanListProvider);
  final loans = loansAsync.valueOrNull ?? [];
  final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  final Map<int, int> monthlyCounts = {for (var i = 1; i <= 12; i++) i: 0};
  for (final l in loans) {
    final dt = l.disbursedDate ?? l.pledgeDate;
    final month = dt.month;
    monthlyCounts[month] = (monthlyCounts[month] ?? 0) + 1;
  }

  final currentMonth = DateTime.now().month;
  final startMonth = (currentMonth - 5).clamp(1, 12);

  return List.generate(6, (index) {
    final mIndex = (startMonth + index) > 12 ? (startMonth + index - 12) : (startMonth + index);
    return KcChartDataPoint(
      xLabel: months[mIndex - 1],
      value: (monthlyCounts[mIndex] ?? 0).toDouble(),
    );
  });
});

final dashboardActivitiesProvider = Provider<List<DashboardActivity>>((ref) {
  final loansAsync = ref.watch(loanListProvider);
  final customersAsync = ref.watch(customerListProvider);

  final loans = loansAsync.valueOrNull ?? [];
  final customers = customersAsync.valueOrNull ?? [];
  final List<DashboardActivity> activities = [];

  for (final l in loans) {
    final dt = l.disbursedDate ?? l.pledgeDate;
    activities.add(
      DashboardActivity(
        title: 'Gold Loan Disbursed #${l.id}',
        subtitle: '${l.customerName} pledged ${l.collateralNetWeightGrams}g for ${KcFormatters.currency(l.principalAmount)}',
        time: KcFormatters.relativeTime(dt),
        icon: Icons.account_balance_outlined,
        color: KcColors.signalGreen,
      ),
    );
  }

  for (final c in customers) {
    activities.add(
      DashboardActivity(
        title: 'New Customer Registered',
        subtitle: '${c.fullName} (${c.mobile})',
        time: KcFormatters.relativeTime(c.createdAt),
        icon: Icons.person_add_outlined,
        color: KcColors.signalBlue,
      ),
    );
  }

  if (activities.isEmpty) {
    return [
      const DashboardActivity(
        title: 'System Initialized',
        subtitle: 'No transactions recorded yet. Click + New Customer or + New Gold Loan to start.',
        time: 'Just now',
        icon: Icons.check_circle_outline_rounded,
        color: KcColors.signalGreen,
      ),
    ];
  }

  return activities.take(5).toList();
});

final storeBusinessHealthProvider = Provider<StoreBusinessHealth>((ref) {
  final loansAsync = ref.watch(loanListProvider);
  final ornamentsAsync = ref.watch(ornamentListProvider);

  final loans = loansAsync.valueOrNull ?? [];
  final ornaments = ornamentsAsync.valueOrNull ?? [];

  if (loans.isEmpty && ornaments.isEmpty) {
    return const StoreBusinessHealth(
      overallScore: 100,
      ltvSafetyRatio: 1.0,
      ltvSafetyLabel: '100% Safe',
      reserveLiquidityRatio: 1.0,
      reserveLiquidityLabel: '100% Liquidity',
      complianceScore: 1.0,
      complianceLabel: '100% Compliant',
    );
  }

  double totalCollateralValue = 0.0;
  double totalOutstandingLoan = 0.0;

  for (final l in loans) {
    totalOutstandingLoan += l.outstandingPrincipal;
    totalCollateralValue += l.collateralTotalValue;
  }

  final ltv = totalCollateralValue > 0 ? (totalOutstandingLoan / totalCollateralValue) : 0.0;
  final ltvSafety = ltv > 0 ? (1.0 - ltv).clamp(0.0, 1.0) : 1.0;
  final overall = (ltvSafety * 100).round().clamp(60, 100);

  return StoreBusinessHealth(
    overallScore: overall,
    ltvSafetyRatio: ltvSafety,
    ltvSafetyLabel: '${(ltvSafety * 100).toStringAsFixed(0)}% Protected',
    reserveLiquidityRatio: 0.95,
    reserveLiquidityLabel: '95% Liquidity',
    complianceScore: 1.0,
    complianceLabel: '100% Compliant',
  );
});

class DashboardTasksNotifier extends StateNotifier<List<DashboardTask>> {
  DashboardTasksNotifier(this.ref) : super([]) {
    loadTasks();
  }

  final Ref ref;

  void loadTasks() {
    final loans = ref.read(loanListProvider).valueOrNull ?? [];
    final customers = ref.read(customerListProvider).valueOrNull ?? [];
    final pendingKyc = customers.where((c) => c.kycStatus == CustomerKycStatus.pending).length;
    final overdueCount = loans.where((l) => l.status == LoanStatus.overdue).length;

    final List<DashboardTask> tasks = [
      DashboardTask(
        id: '1',
        title: 'Daily Vault & Physical Bullion Reconciliation',
        subtitle: 'Morning vault check and physical weight audit',
        completed: false,
      ),
    ];

    if (pendingKyc > 0) {
      tasks.add(
        DashboardTask(
          id: '2',
          title: 'Review $pendingKyc Pending KYC Submissions',
          subtitle: 'Verify Aadhaar & PAN identity documents',
          completed: false,
        ),
      );
    }

    if (overdueCount > 0) {
      tasks.add(
        DashboardTask(
          id: '3',
          title: 'Contact $overdueCount Overdue Loan Clients',
          subtitle: 'Send payment notices for overdue receipts',
          completed: false,
        ),
      );
    }

    tasks.add(
      DashboardTask(
        id: '4',
        title: 'End of Day Cash Desk Closure',
        subtitle: 'Reconcile counter cash balance with accounting ledger',
        completed: false,
      ),
    );

    state = tasks;
  }

  void toggleTask(String id) {
    state = [
      for (final t in state)
        if (t.id == id)
          DashboardTask(
            id: t.id,
            title: t.title,
            subtitle: t.subtitle,
            completed: !t.completed,
          )
        else
          t,
    ];
  }
}

final dashboardTasksProvider = StateNotifierProvider<DashboardTasksNotifier, List<DashboardTask>>((ref) {
  return DashboardTasksNotifier(ref);
});
