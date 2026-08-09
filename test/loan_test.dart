import 'package:flutter_test/flutter_test.dart';
import 'package:karatcore_erp/features/loans/models/loan_model.dart';
import 'package:karatcore_erp/features/loans/repository/loan_repository.dart';
import 'package:karatcore_erp/features/loans/repository/mock_loan_repository.dart';
import 'package:karatcore_erp/features/loans/services/loan_calculation_service.dart';

void main() {
  group('Pledge & Gold/Silver Loan Management Tests', () {
    late ILoanRepository repo;
    late ILoanCalculationService calcService;

    setUp(() {
      repo = MockLoanRepository();
      calcService = MockLoanCalculationService();
    });

    test('MockLoanRepository seeds 30 initial loans', () async {
      final loans = await repo.getLoans();
      expect(loans.length, equals(30));
    });

    test('getDashboardMetrics returns active loans count and collateral values', () async {
      final metrics = await repo.getDashboardMetrics();
      expect(metrics.activeLoansCount, greaterThan(0));
      expect(metrics.totalCollateralValue, greaterThan(0));
      expect(metrics.totalOutstandingPrincipal, greaterThan(0));
    });

    test('MockLoanCalculationService calculates simple interest correctly', () {
      final interest = calcService.calculateInterest(
        principal: 100000.0,
        ratePercentage: 12.0,
        tenureMonths: 12,
        interestType: InterestType.simple,
      );
      expect(interest, equals(12000.0));
    });

    test('MockLoanCalculationService allocates payments to interest first then principal', () {
      final alloc = calcService.calculatePaymentAllocation(
        totalPayment: 5000.0,
        outstandingInterest: 2000.0,
        outstandingPrincipal: 100000.0,
      );

      expect(alloc['interestComponent'], equals(2000.0));
      expect(alloc['principalComponent'], equals(3000.0));
      expect(alloc['excessAmount'], equals(0.0));
    });

    test('recordPayment updates outstanding principal, accrued interest, and logs payment', () async {
      final updated = await repo.recordPayment(
        loanId: 'KC-LN-9481',
        amount: 5000.0,
        method: DisbursementMethod.upi,
        recordedBy: 'Unit Tester',
        notes: 'Test Payment',
      );

      expect(updated.payments.first.amount, equals(5000.0));
      expect(updated.payments.first.receiptNumber, startsWith('KC-RCP-'));
    });

    test('settleLoan transitions loan status to closed and clears outstanding balance', () async {
      final settled = await repo.settleLoan(
        loanId: 'KC-LN-9481',
        settlementAmount: 150000.0,
        method: DisbursementMethod.bankTransfer,
        settledBy: 'Test Manager',
      );

      expect(settled.status, equals(LoanStatus.closed));
      expect(settled.outstandingPrincipal, equals(0.0));
      expect(settled.accruedInterest, equals(0.0));
    });

    test('releaseCollateral updates ornament status to available', () async {
      final released = await repo.releaseCollateral(
        loanId: 'KC-LN-9481',
        verifiedByStaff: 'Vault Officer',
        notes: 'Release Verified',
      );

      expect(released.collateralOrnaments.first.status.label, equals('Available'));
    });
  });
}
