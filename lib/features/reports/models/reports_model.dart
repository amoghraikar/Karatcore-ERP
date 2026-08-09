import 'package:flutter/material.dart';

enum ReportCategory {
  executive('Executive Overview', Icons.dashboard_rounded),
  customers('Customer Reports', Icons.people_rounded),
  kyc('KYC Reports', Icons.verified_user_rounded),
  inventory('Inventory Reports', Icons.inventory_2_rounded),
  loans('Loan Reports', Icons.request_quote_rounded),
  payments('Payment Reports', Icons.payments_rounded),
  accounting('Accounting Reports', Icons.account_balance_rounded),
  profitability('Profitability Reports', Icons.trending_up_rounded),
  risk('Risk Reports', Icons.warning_rounded),
  operations('Operational Reports', Icons.insights_rounded),
  audit('Audit Reports', Icons.history_rounded);

  const ReportCategory(this.label, this.icon);
  final String label;
  final IconData icon;
}

enum DateFilterPreset {
  today('Today'),
  yesterday('Yesterday'),
  thisWeek('This Week'),
  thisMonth('This Month'),
  lastMonth('Last Month'),
  thisQuarter('This Quarter'),
  thisYear('This Year'),
  financialYear('Financial Year (FY 2026-27)'),
  custom('Custom Range');

  const DateFilterPreset(this.label);
  final String label;
}

enum ComparisonMode {
  none('No Comparison'),
  previousPeriod('Previous Period'),
  samePeriodLastYear('Same Period Last Year');

  const ComparisonMode(this.label);
  final String label;
}

class ReportDateFilterModel {
  const ReportDateFilterModel({
    required this.preset,
    required this.startDate,
    required this.endDate,
    this.comparisonMode = ComparisonMode.none,
  });

  final DateFilterPreset preset;
  final DateTime startDate;
  final DateTime endDate;
  final ComparisonMode comparisonMode;

  ReportDateFilterModel copyWith({
    DateFilterPreset? preset,
    DateTime? startDate,
    DateTime? endDate,
    ComparisonMode? comparisonMode,
  }) {
    return ReportDateFilterModel(
      preset: preset ?? this.preset,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      comparisonMode: comparisonMode ?? this.comparisonMode,
    );
  }
}

class ComparisonMetric {
  const ComparisonMetric({
    required this.currentValue,
    required this.previousValue,
    required this.difference,
    required this.percentageChange,
    this.isPositiveGood = true,
  });

  final double currentValue;
  final double previousValue;
  final double difference;
  final double percentageChange;
  final bool isPositiveGood;

  bool get isUp => percentageChange >= 0;
}

class AttentionIndicatorItem {
  const AttentionIndicatorItem({
    required this.id,
    required this.title,
    required this.count,
    required this.description,
    required this.category,
    required this.route,
    required this.statusColor,
    required this.icon,
  });

  final String id;
  final String title;
  final int count;
  final String description;
  final ReportCategory category;
  final String route;
  final Color statusColor;
  final IconData icon;
}

class ExecutiveDashboardMetrics {
  const ExecutiveDashboardMetrics({
    required this.revenue,
    required this.expenses,
    required this.netProfit,
    required this.activeLoansCount,
    required this.loanOutstanding,
    required this.interestIncome,
    required this.inventoryValue,
    required this.pledgedInventoryValue,
    required this.customerCount,
    required this.overdueLoansCount,
    required this.cashBalance,
    required this.bankBalance,
  });

  final double revenue;
  final double expenses;
  final double netProfit;
  final int activeLoansCount;
  final double loanOutstanding;
  final double interestIncome;
  final double inventoryValue;
  final double pledgedInventoryValue;
  final int customerCount;
  final int overdueLoansCount;
  final double cashBalance;
  final double bankBalance;
}

class CustomerSegmentSummary {
  const CustomerSegmentSummary({
    required this.segmentName,
    required this.count,
    required this.description,
    required this.color,
  });

  final String segmentName;
  final int count;
  final String description;
  final Color color;
}

class SavedReportView {
  const SavedReportView({
    required this.id,
    required this.title,
    required this.category,
    required this.filterPreset,
    this.isFavorite = false,
    this.isPinned = false,
    required this.lastViewedAt,
  });

  final String id;
  final String title;
  final ReportCategory category;
  final DateFilterPreset filterPreset;
  final bool isFavorite;
  final bool isPinned;
  final DateTime lastViewedAt;

  SavedReportView copyWith({
    bool? isFavorite,
    bool? isPinned,
    DateTime? lastViewedAt,
  }) {
    return SavedReportView(
      id: id,
      title: title,
      category: category,
      filterPreset: filterPreset,
      isFavorite: isFavorite ?? this.isFavorite,
      isPinned: isPinned ?? this.isPinned,
      lastViewedAt: lastViewedAt ?? this.lastViewedAt,
    );
  }
}

class UnifiedActivityItem {
  const UnifiedActivityItem({
    required this.id,
    required this.timestamp,
    required this.module,
    required this.actor,
    required this.action,
    required this.recordId,
    required this.description,
    required this.route,
  });

  final String id;
  final DateTime timestamp;
  final String module;
  final String actor;
  final String action;
  final String recordId;
  final String description;
  final String route;
}

class StaffPerformanceItem {
  const StaffPerformanceItem({
    required this.staffName,
    required this.role,
    required this.loansProcessed,
    required this.kycReviews,
    required this.customersAdded,
    required this.paymentsRecorded,
    required this.inventoryMovements,
    required this.avgProcessingTimeMinutes,
  });

  final String staffName;
  final String role;
  final int loansProcessed;
  final int kycReviews;
  final int customersAdded;
  final int paymentsRecorded;
  final int inventoryMovements;
  final double avgProcessingTimeMinutes;
}

class CustomerExposureReportItem {
  const CustomerExposureReportItem({
    required this.customerId,
    required this.customerName,
    required this.activeLoansCount,
    required this.totalPrincipal,
    required this.totalOutstanding,
    required this.interestDue,
    required this.collateralValue,
    required this.ltvPercentage,
    required this.riskStatus,
    required this.kycStatus,
  });

  final String customerId;
  final String customerName;
  final int activeLoansCount;
  final double totalPrincipal;
  final double totalOutstanding;
  final double interestDue;
  final double collateralValue;
  final double ltvPercentage;
  final String riskStatus;
  final String kycStatus;
}

class CollateralReportItem {
  const CollateralReportItem({
    required this.customerName,
    required this.loanId,
    required this.ornamentId,
    required this.metalType,
    required this.purity,
    required this.netWeightGrams,
    required this.collateralValue,
    required this.pledgeDate,
    required this.loanStatus,
    required this.releaseStatus,
  });

  final String customerName;
  final String loanId;
  final String ornamentId;
  final String metalType;
  final String purity;
  final double netWeightGrams;
  final double collateralValue;
  final DateTime pledgeDate;
  final String loanStatus;
  final String releaseStatus;
}

class InventoryWeightReportItem {
  const InventoryWeightReportItem({
    required this.groupKey,
    required this.metal,
    required this.purity,
    required this.category,
    required this.location,
    required this.grossWeightGrams,
    required this.stoneWeightGrams,
    required this.otherWeightGrams,
    required this.netMetalWeightGrams,
    required this.itemCount,
  });

  final String groupKey;
  final String metal;
  final String purity;
  final String category;
  final String location;
  final double grossWeightGrams;
  final double stoneWeightGrams;
  final double otherWeightGrams;
  final double netMetalWeightGrams;
  final int itemCount;
}

class InventoryValuationReportItem {
  const InventoryValuationReportItem({
    required this.groupKey,
    required this.metal,
    required this.category,
    required this.location,
    required this.status,
    required this.metalValue,
    required this.makingValue,
    required this.stoneValue,
    required this.otherValue,
    required this.totalEstimatedValue,
  });

  final String groupKey;
  final String metal;
  final String category;
  final String location;
  final String status;
  final double metalValue;
  final double makingValue;
  final double stoneValue;
  final double otherValue;
  final double totalEstimatedValue;
}
