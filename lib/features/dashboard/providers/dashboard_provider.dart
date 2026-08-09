import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/color_tokens.dart';
import '../../../shared/widgets/charts/kc_chart_wrapper.dart';

class DashboardKpi {
  const DashboardKpi({
    required this.title,
    required this.value,
    required this.trend,
    required this.icon,
    this.isPositive = true,
  });

  final String title;
  final String value;
  final String trend;
  final IconData icon;
  final bool isPositive;
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
  bool completed;
}

final dashboardKpisProvider = Provider<List<DashboardKpi>>((ref) {
  return const [
    DashboardKpi(
      title: "Today's Revenue",
      value: '₹14,50,000',
      trend: '+18.4% vs yesterday',
      icon: Icons.payments_outlined,
    ),
    DashboardKpi(
      title: 'Outstanding Loans',
      value: '₹3,42,80,000',
      trend: '+4.2% active book',
      icon: Icons.account_balance_outlined,
    ),
    DashboardKpi(
      title: 'Interest Collected',
      value: '₹6,85,400',
      trend: '+12.1% MTD',
      icon: Icons.trending_up_rounded,
    ),
    DashboardKpi(
      title: 'Active Customers',
      value: '1,248',
      trend: '+24 new this week',
      icon: Icons.people_outline_rounded,
    ),
    DashboardKpi(
      title: 'Loans Due Today',
      value: '8 Receipts',
      trend: '₹12,40,000 due',
      icon: Icons.event_note_rounded,
    ),
    DashboardKpi(
      title: 'Overdue Loans',
      value: '3 Receipts',
      trend: 'Action required',
      icon: Icons.warning_amber_rounded,
      isPositive: false,
    ),
  ];
});

final revenueChartDataProvider = Provider<List<KcChartDataPoint>>((ref) {
  return const [
    KcChartDataPoint(xLabel: 'Mon', value: 850000),
    KcChartDataPoint(xLabel: 'Tue', value: 1120000),
    KcChartDataPoint(xLabel: 'Wed', value: 980000),
    KcChartDataPoint(xLabel: 'Thu', value: 1450000),
    KcChartDataPoint(xLabel: 'Fri', value: 1680000),
    KcChartDataPoint(xLabel: 'Sat', value: 2100000),
    KcChartDataPoint(xLabel: 'Sun', value: 1350000),
  ];
});

final loanDistributionChartProvider = Provider<List<KcDonutDataPoint>>((ref) {
  return const [
    KcDonutDataPoint(label: '24K Bullion Loans', value: 48, color: KcColors.signalOrange),
    KcDonutDataPoint(label: '22K Jewellery Loans', value: 38, color: KcColors.signalGreen),
    KcDonutDataPoint(label: '18K Diamond Loans', value: 14, color: KcColors.signalBlue),
  ];
});

final monthlyTransactionsChartProvider = Provider<List<KcChartDataPoint>>((ref) {
  return const [
    KcChartDataPoint(xLabel: 'Jan', value: 42),
    KcChartDataPoint(xLabel: 'Feb', value: 58),
    KcChartDataPoint(xLabel: 'Mar', value: 65),
    KcChartDataPoint(xLabel: 'Apr', value: 72),
    KcChartDataPoint(xLabel: 'May', value: 84),
    KcChartDataPoint(xLabel: 'Jun', value: 96),
  ];
});

final dashboardActivitiesProvider = Provider<List<DashboardActivity>>((ref) {
  return const [
    DashboardActivity(
      title: 'Gold Loan Disbursed #GL-9481',
      subtitle: 'Aarav Mehta pledged 145.2g 22K Gold for ₹8,45,000',
      time: '12:42 PM',
      icon: Icons.account_balance_outlined,
      color: KcColors.signalGreen,
    ),
    DashboardActivity(
      title: 'BIS Hallmark Audit Verified',
      subtitle: 'Inspector verified Batch #BH-881 (Score: 100%)',
      time: '11:15 AM',
      icon: Icons.verified_rounded,
      color: KcColors.signalOrange,
    ),
    DashboardActivity(
      title: 'Loan Principal Settled #GL-9210',
      subtitle: 'Priya Sharma repaid ₹4,90,000 + ₹14,700 interest',
      time: '10:05 AM',
      icon: Icons.check_circle_outline_rounded,
      color: KcColors.signalGreen,
    ),
    DashboardActivity(
      title: 'KYC Document Updated',
      subtitle: 'Vikram Singhania uploaded Aadhar & PAN',
      time: '09:30 AM',
      icon: Icons.badge_outlined,
      color: KcColors.signalBlue,
    ),
  ];
});

final dashboardTasksProvider = StateProvider<List<DashboardTask>>((ref) {
  return [
    DashboardTask(id: '1', title: 'Verify 24K Vault Bullion Weight', subtitle: 'Daily morning audit at 10:00 AM', completed: true),
    DashboardTask(id: '2', title: 'Call 3 Overdue Loan Clients', subtitle: 'Receipts #901, #904, #912', completed: false),
    DashboardTask(id: '3', title: 'Upload BIS Hallmark Compliance Report', subtitle: 'Monthly submission required', completed: false),
    DashboardTask(id: '4', title: 'Reconcile Cash Counter & Bank Deposit', subtitle: 'End of day closure', completed: false),
  ];
});
