import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/loan_model.dart';
import 'loan_repository.dart';

class ApiLoanRepository implements ILoanRepository {
  ApiLoanRepository(this._api);

  final ApiClient _api;

  @override
  Future<LoanDashboardMetrics> getDashboardMetrics() async {
    try {
      final dynamic data = await _api.get('${ApiEndpoints.loans}/metrics');
      return LoanDashboardMetrics(
        activeLoansCount: (data['active_loans_count'] as int?) ?? 0,
        totalOutstandingPrincipal: (data['total_outstanding_principal'] as num?)?.toDouble() ?? 0.0,
        totalInterestDue: (data['total_interest_due'] as num?)?.toDouble() ?? 0.0,
        totalInterestCollected: (data['total_interest_collected'] as num?)?.toDouble() ?? 0.0,
        overdueLoansCount: (data['overdue_loans_count'] as int?) ?? 0,
        loansDueSoonCount: (data['loans_due_soon_count'] as int?) ?? 0,
        loansClosedThisMonthCount: (data['loans_closed_this_month_count'] as int?) ?? 0,
        totalCollateralValue: (data['total_collateral_value'] as num?)?.toDouble() ?? 0.0,
        totalPledgedWeightGrams: (data['total_pledged_weight_grams'] as num?)?.toDouble() ?? 0.0,
      );
    } catch (_) {
      return const LoanDashboardMetrics(
        activeLoansCount: 0,
        totalOutstandingPrincipal: 0.0,
        totalInterestDue: 0.0,
        totalInterestCollected: 0.0,
        overdueLoansCount: 0,
        loansDueSoonCount: 0,
        loansClosedThisMonthCount: 0,
        totalCollateralValue: 0.0,
        totalPledgedWeightGrams: 0.0,
      );
    }
  }

  @override
  Future<List<LoanModel>> getLoans({
    String? searchQuery,
    LoanFilterParams? filters,
    LoanSortOption? sortOption,
  }) async {
    try {
      final dynamic data = await _api.get(
        '${ApiEndpoints.loans}?search=${Uri.encodeComponent(searchQuery ?? '')}',
      );
      if (data is List) {
        return _parseLoansFromJson(data);
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<LoanModel?> getLoanById(String id) async {
    try {
      final dynamic data = await _api.get('${ApiEndpoints.loanById}$id');
      return _parseLoanFromJson(data);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<LoanModel>> getLoansByCustomerId(String customerId) async {
    try {
      final dynamic data = await _api.get('${ApiEndpoints.loans}/customer/$customerId');
      if (data is List) {
        return _parseLoansFromJson(data);
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<LoanModel> createLoan(LoanModel loan) async {
    final dynamic data = await _api.post(
      ApiEndpoints.loans,
      body: _loanToJson(loan),
    );
    return _parseLoanFromJson(data);
  }

  @override
  Future<LoanModel> updateLoan(LoanModel loan) async {
    final dynamic data = await _api.put(
      '${ApiEndpoints.loanById}${loan.id}',
      body: _loanToJson(loan),
    );
    return _parseLoanFromJson(data);
  }

  @override
  Future<LoanModel> approveLoan({
    required String loanId,
    required String reviewerName,
    String notes = '',
  }) async {
    final dynamic data = await _api.post(
      '${ApiEndpoints.loanById}$loanId/approve',
      body: {
        'reviewer_name': reviewerName,
        'notes': notes,
      },
    );
    return _parseLoanFromJson(data);
  }

  @override
  Future<LoanModel> rejectLoan({
    required String loanId,
    required String reviewerName,
    required String reason,
  }) async {
    final dynamic data = await _api.post(
      '${ApiEndpoints.loanById}$loanId/reject',
      body: {
        'reviewer_name': reviewerName,
        'reason': reason,
      },
    );
    return _parseLoanFromJson(data);
  }

  @override
  Future<LoanModel> disburseLoan({
    required String loanId,
    required DisbursementMethod method,
    required String referenceNumber,
  }) async {
    final dynamic data = await _api.post(
      '${ApiEndpoints.loanById}$loanId/disburse',
      body: {
        'method': method.name,
        'reference_number': referenceNumber,
      },
    );
    return _parseLoanFromJson(data);
  }

  @override
  Future<LoanModel> recordPayment({
    required String loanId,
    required double amount,
    required DisbursementMethod method,
    required String recordedBy,
    String notes = '',
  }) async {
    final dynamic data = await _api.post(
      '${ApiEndpoints.loanById}$loanId/record-payment',
      body: {
        'amount': amount,
        'method': method.name,
        'recorded_by': recordedBy,
        'notes': notes,
      },
    );
    return _parseLoanFromJson(data);
  }

  @override
  Future<LoanModel> settleLoan({
    required String loanId,
    required double settlementAmount,
    required DisbursementMethod method,
    required String settledBy,
  }) async {
    final dynamic data = await _api.post(
      '${ApiEndpoints.loanById}$loanId/settlement',
      body: {
        'settlement_amount': settlementAmount,
        'method': method.name,
        'settled_by': settledBy,
      },
    );
    return _parseLoanFromJson(data);
  }

  @override
  Future<LoanModel> renewLoan({
    required String loanId,
    required double newPrincipal,
    required double newRate,
    required int extendedMonths,
    required String officerName,
  }) async {
    final dynamic data = await _api.post(
      '${ApiEndpoints.loanById}$loanId/renew',
      body: {
        'new_principal': newPrincipal,
        'new_rate': newRate,
        'extended_months': extendedMonths,
        'officer_name': officerName,
      },
    );
    return _parseLoanFromJson(data);
  }

  @override
  Future<LoanModel> releaseCollateral({
    required String loanId,
    required String verifiedByStaff,
    String notes = '',
  }) async {
    final dynamic data = await _api.post(
      '${ApiEndpoints.loanById}$loanId/release-collateral',
      body: {
        'verified_by_staff': verifiedByStaff,
        'notes': notes,
      },
    );
    return _parseLoanFromJson(data);
  }

  List<LoanModel> _parseLoansFromJson(List data) {
    return data.map((json) => _parseLoanFromJson(json as Map<String, dynamic>)).toList();
  }

  LoanModel _parseLoanFromJson(Map<String, dynamic> json) {
    return LoanModel(
      id: json['id'] as String,
      customerId: json['customer_id'] as String? ?? '',
      customerName: json['customer_name'] as String? ?? '',
      customerKycStatus: json['customer_kyc_status'] as String? ?? 'Verified',
      pledgeId: json['pledge_id'] as String? ?? '',
      collateralOrnaments: const [],
      pledgeDate: DateTime.tryParse(json['pledge_date'] as String? ?? '') ?? DateTime.now(),
      maturityDate: DateTime.tryParse(json['maturity_date'] as String? ?? '') ?? DateTime.now(),
      principalAmount: (json['principal_amount'] as num?)?.toDouble() ?? 0.0,
      outstandingPrincipal: (json['outstanding_principal'] as num?)?.toDouble() ?? 0.0,
      interestRatePercentage: (json['interest_rate_percentage'] as num?)?.toDouble() ?? (json['interest_rate'] as num?)?.toDouble() ?? 0.0,
      accruedInterest: (json['accrued_interest'] as num?)?.toDouble() ?? 0.0,
      nextDueDate: DateTime.tryParse(json['next_due_date'] as String? ?? '') ?? DateTime.now(),
      collateralTotalValue: (json['collateral_total_value'] as num?)?.toDouble() ?? 0.0,
      collateralNetWeightGrams: (json['collateral_net_weight_grams'] as num?)?.toDouble() ?? 0.0,
      status: LoanStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => LoanStatus.active,
      ),
      riskStatus: LoanRiskStatus.values.firstWhere(
        (e) => e.name == json['risk_status'],
        orElse: () => LoanRiskStatus.low,
      ),
      branch: json['branch'] as String? ?? 'Main Branch',
      loanOfficer: json['loan_officer'] as String? ?? 'Admin',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> _loanToJson(LoanModel loan) {
    return {
      'id': loan.id,
      'customer_id': loan.customerId,
      'customer_name': loan.customerName,
      'pledge_id': loan.pledgeId,
      'principal_amount': loan.principalAmount,
      'interest_rate_percentage': loan.interestRatePercentage,
      'pledge_date': loan.pledgeDate.toIso8601String(),
      'maturity_date': loan.maturityDate.toIso8601String(),
      'next_due_date': loan.nextDueDate.toIso8601String(),
      'status': loan.status.name,
      'outstanding_principal': loan.outstandingPrincipal,
      'accrued_interest': loan.accruedInterest,
      'processing_fee': loan.processingFee,
    };
  }
}
