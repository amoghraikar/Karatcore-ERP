import 'package:flutter/material.dart';

import '../../accounting/models/accounting_model.dart';
import '../../customers/models/customer_model.dart';
import '../../kyc/models/kyc_model.dart';
import '../../loans/models/loan_model.dart';
import '../../ornaments/models/ornament_model.dart';
import '../models/reports_model.dart';

abstract class IReportsCalculationService {
  ExecutiveDashboardMetrics calculateExecutiveMetrics({
    required List<CustomerModel> customers,
    required List<KycRecordModel> kycRecords,
    required List<OrnamentModel> ornaments,
    required List<LoanModel> loans,
    required List<AccountModel> accounts,
  });

  ComparisonMetric calculateComparison(double current, double previous, {bool isPositiveGood = true});

  List<AttentionIndicatorItem> calculateAttentionItems({
    required List<LoanModel> loans,
    required List<KycRecordModel> kycRecords,
    required List<OrnamentModel> ornaments,
    required List<AccountModel> accounts,
  });

  Map<String, dynamic> calculateCustomerAnalytics(List<CustomerModel> customers, List<LoanModel> loans);

  Map<String, dynamic> calculateKycAnalytics(List<KycRecordModel> kycRecords);

  Map<String, dynamic> calculateInventoryAnalytics(List<OrnamentModel> ornaments);

  Map<String, dynamic> calculateLoanAnalytics(List<LoanModel> loans);

  Map<String, dynamic> calculatePaymentAnalytics(List<LoanModel> loans);

  Map<String, dynamic> calculateProfitabilityAnalytics(List<AccountModel> accounts);

  Map<String, dynamic> calculateRiskAnalytics(List<CustomerModel> customers, List<LoanModel> loans, List<KycRecordModel> kycRecords);

  List<CustomerExposureReportItem> calculateCustomerExposure(List<CustomerModel> customers, List<LoanModel> loans);

  List<CollateralReportItem> calculateCollateralReport(List<LoanModel> loans, List<OrnamentModel> ornaments);

  List<InventoryWeightReportItem> calculateInventoryWeightReport(List<OrnamentModel> ornaments);

  List<InventoryValuationReportItem> calculateInventoryValuationReport(List<OrnamentModel> ornaments);
}

class ReportsCalculationService implements IReportsCalculationService {
  @override
  ExecutiveDashboardMetrics calculateExecutiveMetrics({
    required List<CustomerModel> customers,
    required List<KycRecordModel> kycRecords,
    required List<OrnamentModel> ornaments,
    required List<LoanModel> loans,
    required List<AccountModel> accounts,
  }) {
    final activeLoans = loans.where((l) => l.status == LoanStatus.active || l.status == LoanStatus.dueSoon || l.status == LoanStatus.overdue || l.status == LoanStatus.partiallyRepaid).toList();
    final overdueLoans = loans.where((l) => l.status == LoanStatus.overdue).toList();

    final loanOutstanding = activeLoans.fold(0.0, (sum, l) => sum + l.totalOutstanding);
    final interestIncome = loans.fold(0.0, (sum, l) => sum + l.accruedInterest);

    final inventoryValue = ornaments.fold(0.0, (sum, o) => sum + o.valuation.totalEstimatedValue);
    final pledgedInventoryValue = ornaments.where((o) => o.status == OrnamentStatus.pledged).fold(0.0, (sum, o) => sum + o.valuation.totalEstimatedValue);

    final revenueAccs = accounts.where((a) => a.type == AccountType.income).fold(0.0, (sum, a) => sum + a.currentBalance);
    final expenseAccs = accounts.where((a) => a.type == AccountType.expense).fold(0.0, (sum, a) => sum + a.currentBalance);
    final netProfit = revenueAccs - expenseAccs;

    final cashAccs = accounts.where((a) => a.category == AccountCategory.cash).fold(0.0, (sum, a) => sum + a.currentBalance);
    final bankAccs = accounts.where((a) => a.category == AccountCategory.bankAccount).fold(0.0, (sum, a) => sum + a.currentBalance);

    return ExecutiveDashboardMetrics(
      revenue: revenueAccs,
      expenses: expenseAccs,
      netProfit: netProfit,
      activeLoansCount: activeLoans.length,
      loanOutstanding: loanOutstanding,
      interestIncome: interestIncome,
      inventoryValue: inventoryValue,
      pledgedInventoryValue: pledgedInventoryValue,
      customerCount: customers.length,
      overdueLoansCount: overdueLoans.length,
      cashBalance: cashAccs,
      bankBalance: bankAccs,
    );
  }

  @override
  ComparisonMetric calculateComparison(double current, double previous, {bool isPositiveGood = true}) {
    final diff = current - previous;
    final pct = previous != 0 ? (diff / previous) * 100 : 0.0;
    return ComparisonMetric(
      currentValue: current,
      previousValue: previous,
      difference: diff,
      percentageChange: pct,
      isPositiveGood: isPositiveGood,
    );
  }

  @override
  List<AttentionIndicatorItem> calculateAttentionItems({
    required List<LoanModel> loans,
    required List<KycRecordModel> kycRecords,
    required List<OrnamentModel> ornaments,
    required List<AccountModel> accounts,
  }) {
    final overdueCount = loans.where((l) => l.status == LoanStatus.overdue).length;
    final pendingKycCount = kycRecords.where((k) => k.status == KycStatus.underReview || k.status == KycStatus.submitted).length;
    final pendingApprovalLoansCount = loans.where((l) => l.status == LoanStatus.pendingApproval || l.riskStatus == LoanRiskStatus.high).length;
    final ornamentsAttentionCount = ornaments.where((o) => o.status == OrnamentStatus.damaged).length;
    final overdueReceivablesCount = loans.where((l) => l.status == LoanStatus.overdue && l.accruedInterest > 0).length;
    final highRiskCount = loans.where((l) => l.riskStatus == LoanRiskStatus.high).length;

    return [
      AttentionIndicatorItem(
        id: 'ATTN-01',
        title: 'Overdue Gold Loans',
        count: overdueCount,
        description: 'Pledge accounts past their scheduled maturity due date.',
        category: ReportCategory.loans,
        route: '/reports/loans?filter=overdue',
        statusColor: const Color(0xFFDC2626),
        icon: Icons.warning_rounded,
      ),
      AttentionIndicatorItem(
        id: 'ATTN-02',
        title: 'Pending KYC Records',
        count: pendingKycCount,
        description: 'Customer identity verification submissions awaiting manager review.',
        category: ReportCategory.kyc,
        route: '/reports/kyc?filter=pending',
        statusColor: const Color(0xFFD97706),
        icon: Icons.rule_rounded,
      ),
      AttentionIndicatorItem(
        id: 'ATTN-03',
        title: 'Loans Awaiting Approval',
        count: pendingApprovalLoansCount,
        description: 'Loan pledges with LTV exceeding 75% requiring senior manager approval.',
        category: ReportCategory.risk,
        route: '/reports/risk?filter=high-ltv',
        statusColor: const Color(0xFF7C3AED),
        icon: Icons.shield_rounded,
      ),
      AttentionIndicatorItem(
        id: 'ATTN-04',
        title: 'Ornaments Requiring Attention',
        count: ornamentsAttentionCount,
        description: 'Pledged ornaments scheduled for quarterly physical vault audit.',
        category: ReportCategory.inventory,
        route: '/reports/inventory?filter=vault-audit',
        statusColor: const Color(0xFF2563EB),
        icon: Icons.inventory_2_rounded,
      ),
      AttentionIndicatorItem(
        id: 'ATTN-05',
        title: 'Overdue Receivables',
        count: overdueReceivablesCount,
        description: 'Customer balances & interest yield receivables past 30 days.',
        category: ReportCategory.accounting,
        route: '/accounting/receivables',
        statusColor: const Color(0xFFEC4899),
        icon: Icons.call_made_rounded,
      ),
      AttentionIndicatorItem(
        id: 'ATTN-06',
        title: 'High-Risk Customer Records',
        count: highRiskCount,
        description: 'Borrower profiles with multi-pledge exposure & late payment history.',
        category: ReportCategory.risk,
        route: '/reports/risk?filter=high-risk',
        statusColor: const Color(0xFFB91C1C),
        icon: Icons.error_outline_rounded,
      ),
    ];
  }

  @override
  Map<String, dynamic> calculateCustomerAnalytics(List<CustomerModel> customers, List<LoanModel> loans) {
    final verified = customers.where((c) => c.kycStatus == CustomerKycStatus.verified).length;
    final pending = customers.where((c) => c.kycStatus == CustomerKycStatus.pending).length;
    final rejected = customers.where((c) => c.kycStatus == CustomerKycStatus.rejected).length;

    final activeCustomerIds = loans.where((l) => l.status == LoanStatus.active).map((l) => l.customerId).toSet();
    final now = DateTime.now();
    final newCustCount = customers.where((c) => c.createdAt.isAfter(now.subtract(const Duration(days: 30)))).length;
    final frequentCount = customers.where((c) => loans.where((l) => l.customerId == c.id).length >= 5).length;
    final riskyCount = customers.where((c) => c.customerStatus == CustomerStatus.blocked || c.riskStatus == CustomerRiskLevel.high).length;

    return {
      'totalCustomers': customers.length,
      'verifiedCount': verified,
      'pendingCount': pending,
      'rejectedCount': rejected,
      'activeBorrowersCount': activeCustomerIds.length,
      'segments': [
        CustomerSegmentSummary(segmentName: 'New Customers', count: newCustCount, description: 'Joined within last 30 days', color: const Color(0xFF2563EB)),
        CustomerSegmentSummary(segmentName: 'Active Borrowers', count: activeCustomerIds.length, description: 'Has at least one active gold loan', color: const Color(0xFF059669)),
        const CustomerSegmentSummary(segmentName: 'High Value VIP', count: 0, description: 'Total portfolio pledge > ₹10,00,000', color: Color(0xFF7C3AED)),
        CustomerSegmentSummary(segmentName: 'Frequent Traders', count: frequentCount, description: 'Over 5 completed loan cycles', color: const Color(0xFFD97706)),
        CustomerSegmentSummary(segmentName: 'Watchlist / Risky', count: riskyCount, description: 'History of late repayments or blocked', color: const Color(0xFFDC2626)),
      ],
    };
  }

  @override
  Map<String, dynamic> calculateKycAnalytics(List<KycRecordModel> kycRecords) {
    final verified = kycRecords.where((k) => k.status == KycStatus.verified).length;
    final pending = kycRecords.where((k) => k.status == KycStatus.underReview || k.status == KycStatus.submitted).length;
    final rejected = kycRecords.where((k) => k.status == KycStatus.rejected).length;

    final methods = <String, int>{};
    for (final r in kycRecords) {
      final m = r.method.label;
      methods[m] = (methods[m] ?? 0) + 1;
    }

    return {
      'totalRecords': kycRecords.length,
      'verifiedCount': verified,
      'pendingCount': pending,
      'rejectedCount': rejected,
      'avgReviewTimeMinutes': 0.0,
      'verificationMethods': methods,
    };
  }

  @override
  Map<String, dynamic> calculateInventoryAnalytics(List<OrnamentModel> ornaments) {
    final goldOrnaments = ornaments.where((o) => o.metalType == MetalType.gold).toList();
    final silverOrnaments = ornaments.where((o) => o.metalType == MetalType.silver).toList();

    final totalGrossWeight = ornaments.fold(0.0, (sum, o) => sum + o.weight.grossWeight);
    final totalStoneWeight = ornaments.fold(0.0, (sum, o) => sum + o.weight.stoneWeight);
    final totalOtherWeight = ornaments.fold(0.0, (sum, o) => sum + o.weight.otherWeight);
    final totalNetMetalWeight = ornaments.fold(0.0, (sum, o) => sum + o.weight.netMetalWeight);

    final totalValuation = ornaments.fold(0.0, (sum, o) => sum + o.valuation.totalEstimatedValue);
    final pledgedValuation = ornaments.where((o) => o.status == OrnamentStatus.pledged).fold(0.0, (sum, o) => sum + o.valuation.totalEstimatedValue);

    return {
      'totalCount': ornaments.length,
      'goldCount': goldOrnaments.length,
      'silverCount': silverOrnaments.length,
      'totalGrossWeightGrams': totalGrossWeight,
      'totalStoneWeightGrams': totalStoneWeight,
      'totalOtherWeightGrams': totalOtherWeight,
      'totalNetMetalWeightGrams': totalNetMetalWeight,
      'totalValuation': totalValuation,
      'pledgedValuation': pledgedValuation,
      'availableValuation': totalValuation - pledgedValuation,
    };
  }

  @override
  Map<String, dynamic> calculateLoanAnalytics(List<LoanModel> loans) {
    final active = loans.where((l) => l.status == LoanStatus.active).length;
    final overdue = loans.where((l) => l.status == LoanStatus.overdue).length;
    final closed = loans.where((l) => l.status == LoanStatus.closed || l.status == LoanStatus.cancelled || l.status == LoanStatus.writtenOff).length;
    final dueSoon = loans.where((l) => l.status == LoanStatus.dueSoon).length;

    final totalDisbursed = loans.fold(0.0, (sum, l) => sum + l.principalAmount);
    final totalOutstanding = loans.fold(0.0, (sum, l) => sum + l.totalOutstanding);
    final totalInterestEarned = loans.fold(0.0, (sum, l) => sum + l.accruedInterest);
    final avgLtv = loans.isEmpty ? 0.0 : (loans.fold(0.0, (sum, l) => sum + l.ltvPercentage) / loans.length);

    return {
      'totalLoansCount': loans.length,
      'activeCount': active,
      'overdueCount': overdue,
      'closedCount': closed,
      'dueSoonCount': dueSoon,
      'totalDisbursed': totalDisbursed,
      'totalOutstanding': totalOutstanding,
      'totalInterestEarned': totalInterestEarned,
      'avgLtvPercentage': avgLtv,
    };
  }

  @override
  Map<String, dynamic> calculatePaymentAnalytics(List<LoanModel> loans) {
    final totalInterestCollected = loans.fold(0.0, (sum, l) => sum + l.accruedInterest);
    final totalPrincipalCollected = loans.fold(0.0, (sum, l) => sum + (l.principalAmount - l.outstandingPrincipal));

    return {
      'totalCollections': totalInterestCollected + totalPrincipalCollected,
      'principalCollected': totalPrincipalCollected,
      'interestCollected': totalInterestCollected,
      'methodBreakdown': <String, double>{},
    };
  }

  @override
  Map<String, dynamic> calculateProfitabilityAnalytics(List<AccountModel> accounts) {
    final revenue = accounts.where((a) => a.type == AccountType.income).fold(0.0, (sum, a) => sum + a.currentBalance);
    final expenses = accounts.where((a) => a.type == AccountType.expense).fold(0.0, (sum, a) => sum + a.currentBalance);
    final netProfit = revenue - expenses;
    final margin = revenue > 0 ? (netProfit / revenue) * 100 : 0.0;

    return {
      'totalRevenue': revenue,
      'totalExpenses': expenses,
      'netProfit': netProfit,
      'profitMarginPercentage': margin,
    };
  }

  @override
  Map<String, dynamic> calculateRiskAnalytics(List<CustomerModel> customers, List<LoanModel> loans, List<KycRecordModel> kycRecords) {
    final highRiskLoans = loans.where((l) => l.riskStatus == LoanRiskStatus.high).toList();
    final overdueLoans = loans.where((l) => l.status == LoanStatus.overdue).toList();

    return {
      'highRiskLoansCount': highRiskLoans.length,
      'overdueLoansCount': overdueLoans.length,
      'unverifiedKycCount': customers.where((c) => c.kycStatus != CustomerKycStatus.verified).length,
      'totalExposureAmount': overdueLoans.fold(0.0, (sum, l) => sum + l.totalOutstanding),
    };
  }

  @override
  List<CustomerExposureReportItem> calculateCustomerExposure(List<CustomerModel> customers, List<LoanModel> loans) {
    return customers.map((c) {
      final custLoans = loans.where((l) => l.customerId == c.id || l.customerName == c.fullName).toList();
      final activeLoans = custLoans.where((l) => l.status == LoanStatus.active || l.status == LoanStatus.dueSoon || l.status == LoanStatus.overdue).toList();
      final totalPrincipal = custLoans.fold(0.0, (sum, l) => sum + l.principalAmount);
      final totalOutstanding = activeLoans.fold(0.0, (sum, l) => sum + l.totalOutstanding);
      final totalInterest = activeLoans.fold(0.0, (sum, l) => sum + l.accruedInterest);
      final collateralVal = custLoans.fold(0.0, (sum, l) => sum + l.collateralTotalValue);
      final avgLtv = collateralVal > 0 ? (totalOutstanding / collateralVal) * 100 : 0.0;

      final isHighRisk = avgLtv > 75 || activeLoans.any((l) => l.status == LoanStatus.overdue);

      return CustomerExposureReportItem(
        customerId: c.id,
        customerName: c.fullName,
        activeLoansCount: activeLoans.length,
        totalPrincipal: totalPrincipal,
        totalOutstanding: totalOutstanding,
        interestDue: totalInterest,
        collateralValue: collateralVal,
        ltvPercentage: avgLtv,
        riskStatus: isHighRisk ? 'HIGH' : 'NORMAL',
        kycStatus: c.kycStatus.name.toUpperCase(),
      );
    }).toList();
  }

  @override
  List<CollateralReportItem> calculateCollateralReport(List<LoanModel> loans, List<OrnamentModel> ornaments) {
    final now = DateTime.now();
    return ornaments.map((o) {
      final matchingLoans = loans.where((l) => l.collateralOrnaments.any((item) => item.id == o.id)).toList();
      final loan = matchingLoans.isNotEmpty ? matchingLoans.first : null;

      return CollateralReportItem(
        customerName: loan?.customerName ?? 'In Vault',
        loanId: loan?.id ?? 'N/A',
        ornamentId: o.id,
        metalType: o.metalType.label,
        purity: o.purity.label,
        netWeightGrams: o.weight.netMetalWeight,
        collateralValue: o.valuation.totalEstimatedValue,
        pledgeDate: loan?.pledgeDate ?? now,
        loanStatus: loan?.status.name.toUpperCase() ?? 'AVAILABLE',
        releaseStatus: o.status == OrnamentStatus.released ? 'RELEASED' : 'IN_VAULT',
      );
    }).toList();
  }

  @override
  List<InventoryWeightReportItem> calculateInventoryWeightReport(List<OrnamentModel> ornaments) {
    final Map<String, List<OrnamentModel>> grouped = {};
    for (final o in ornaments) {
      final key = '${o.metalType.label} - ${o.purity.label} (${o.category.label})';
      grouped.putIfAbsent(key, () => []).add(o);
    }

    return grouped.entries.map((e) {
      final list = e.value;
      final first = list.first;
      final gross = list.fold(0.0, (sum, o) => sum + o.weight.grossWeight);
      final stone = list.fold(0.0, (sum, o) => sum + o.weight.stoneWeight);
      final other = list.fold(0.0, (sum, o) => sum + o.weight.otherWeight);
      final net = list.fold(0.0, (sum, o) => sum + o.weight.netMetalWeight);

      return InventoryWeightReportItem(
        groupKey: e.key,
        metal: first.metalType.label,
        purity: first.purity.label,
        category: first.category.label,
        location: first.location.fullLocationPath,
        grossWeightGrams: gross,
        stoneWeightGrams: stone,
        otherWeightGrams: other,
        netMetalWeightGrams: net,
        itemCount: list.length,
      );
    }).toList();
  }

  @override
  List<InventoryValuationReportItem> calculateInventoryValuationReport(List<OrnamentModel> ornaments) {
    final Map<String, List<OrnamentModel>> grouped = {};
    for (final o in ornaments) {
      final key = '${o.metalType.label} - ${o.category.label} (${o.status.label})';
      grouped.putIfAbsent(key, () => []).add(o);
    }

    return grouped.entries.map((e) {
      final list = e.value;
      final first = list.first;
      final metalVal = list.fold(0.0, (sum, o) => sum + o.valuation.metalValue);
      final makingVal = list.fold(0.0, (sum, o) => sum + o.valuation.makingCharges);
      final stoneVal = list.fold(0.0, (sum, o) => sum + o.valuation.stoneValue);
      final otherVal = list.fold(0.0, (sum, o) => sum + o.valuation.otherCharges);
      final totalEst = list.fold(0.0, (sum, o) => sum + o.valuation.totalEstimatedValue);

      return InventoryValuationReportItem(
        groupKey: e.key,
        metal: first.metalType.label,
        category: first.category.label,
        location: first.location.fullLocationPath,
        status: first.status.label,
        metalValue: metalVal,
        makingValue: makingVal,
        stoneValue: stoneVal,
        otherValue: otherVal,
        totalEstimatedValue: totalEst,
      );
    }).toList();
  }
}
