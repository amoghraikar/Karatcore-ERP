import 'package:flutter_test/flutter_test.dart';
import 'package:karatcore_erp/features/loans/models/loan_model.dart';
import 'package:karatcore_erp/features/loans/services/loan_calculation_service.dart';

void main() {
  group('Pledge & Gold/Silver Loan Calculation Tests', () {
    late ILoanCalculationService calcService;

    setUp(() {
      calcService = LoanCalculationService();
    });

    test('LoanCalculationService calculates simple interest correctly', () {
      final interest = calcService.calculateInterest(
        principal: 100000.0,
        ratePercentage: 12.0,
        tenureMonths: 12,
        interestType: InterestType.simple,
      );
      expect(interest, equals(12000.0));
    });

    test('LoanCalculationService allocates payments to interest first then principal', () {
      final alloc = calcService.calculatePaymentAllocation(
        totalPayment: 5000.0,
        outstandingInterest: 2000.0,
        outstandingPrincipal: 100000.0,
      );

      expect(alloc['interestComponent'], equals(2000.0));
      expect(alloc['principalComponent'], equals(3000.0));
      expect(alloc['excessAmount'], equals(0.0));
    });
  });
}
