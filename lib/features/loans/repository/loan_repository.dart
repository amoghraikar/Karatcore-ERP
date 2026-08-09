import '../models/loan_model.dart';

class LoanFilterParams {
  const LoanFilterParams({
    this.status,
    this.riskStatus,
    this.metalType,
    this.branch,
    this.officer,
    this.minAmount,
    this.maxAmount,
    this.isOverdue,
  });

  final LoanStatus? status;
  final LoanRiskStatus? riskStatus;
  final String? metalType; // Gold, Silver
  final String? branch;
  final String? officer;
  final double? minAmount;
  final double? maxAmount;
  final bool? isOverdue;

  bool get isEmpty =>
      status == null &&
      riskStatus == null &&
      metalType == null &&
      branch == null &&
      officer == null &&
      minAmount == null &&
      maxAmount == null &&
      isOverdue == null;
}

enum LoanSortOption {
  newest('Date Disbursed (Newest)'),
  oldest('Date Disbursed (Oldest)'),
  principalHighToLow('Principal (High to Low)'),
  interestDueHighToLow('Interest Due (High to Low)'),
  nextDueSoonest('Next Due Date (Soonest)'),
  statusPriority('Status Priority');

  const LoanSortOption(this.label);
  final String label;
}

class LoanDashboardMetrics {
  const LoanDashboardMetrics({
    required this.activeLoansCount,
    required this.totalOutstandingPrincipal,
    required this.totalInterestDue,
    required this.totalInterestCollected,
    required this.overdueLoansCount,
    required this.loansDueSoonCount,
    required this.loansClosedThisMonthCount,
    required this.totalCollateralValue,
    required this.totalPledgedWeightGrams,
  });

  final int activeLoansCount;
  final double totalOutstandingPrincipal;
  final double totalInterestDue;
  final double totalInterestCollected;
  final int overdueLoansCount;
  final int loansDueSoonCount;
  final int loansClosedThisMonthCount;
  final double totalCollateralValue;
  final double totalPledgedWeightGrams;
}

abstract class ILoanRepository {
  Future<LoanDashboardMetrics> getDashboardMetrics();

  Future<List<LoanModel>> getLoans({
    String? searchQuery,
    LoanFilterParams? filters,
    LoanSortOption? sortOption,
  });

  Future<LoanModel?> getLoanById(String id);

  Future<List<LoanModel>> getLoansByCustomerId(String customerId);

  Future<LoanModel> createLoan(LoanModel loan);

  Future<LoanModel> updateLoan(LoanModel loan);

  Future<LoanModel> approveLoan({
    required String loanId,
    required String reviewerName,
    String notes = '',
  });

  Future<LoanModel> rejectLoan({
    required String loanId,
    required String reviewerName,
    required String reason,
  });

  Future<LoanModel> disburseLoan({
    required String loanId,
    required DisbursementMethod method,
    required String referenceNumber,
  });

  Future<LoanModel> recordPayment({
    required String loanId,
    required double amount,
    required DisbursementMethod method,
    required String recordedBy,
    String notes = '',
  });

  Future<LoanModel> settleLoan({
    required String loanId,
    required double settlementAmount,
    required DisbursementMethod method,
    required String settledBy,
  });

  Future<LoanModel> renewLoan({
    required String loanId,
    required double newPrincipal,
    required double newRate,
    required int extendedMonths,
    required String officerName,
  });

  Future<LoanModel> releaseCollateral({
    required String loanId,
    required String verifiedByStaff,
    String notes = '',
  });
}
