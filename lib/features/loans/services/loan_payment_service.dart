import '../models/loan_model.dart';

abstract class IPaymentService {
  Future<LoanPaymentModel> recordPayment({
    required String loanId,
    required double amount,
    required DisbursementMethod method,
    required String recordedBy,
    String notes = '',
  });
}

abstract class ISettlementService {
  Future<LoanModel> settleLoan({
    required String loanId,
    required double settlementAmount,
    required DisbursementMethod method,
    required String settledBy,
  });
}

abstract class IReleaseService {
  Future<PledgeModel> releaseCollateral({
    required String pledgeId,
    required String loanId,
    required String customerId,
    required String verifiedByStaff,
    String notes = '',
  });
}
