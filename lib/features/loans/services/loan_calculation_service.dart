import '../../ornaments/models/ornament_model.dart';
import '../models/loan_model.dart';

abstract class ILoanCalculationService {
  double calculateCollateralValue(List<OrnamentModel> ornaments);

  double calculateEligibleLoanAmount(double collateralValue, {double ltvPercentage = 75.0});

  double calculateInterest({
    required double principal,
    required double ratePercentage,
    required int tenureMonths,
    InterestType interestType = InterestType.simple,
  });

  Map<String, double> calculatePaymentAllocation({
    required double totalPayment,
    required double outstandingInterest,
    required double outstandingPrincipal,
  });

  double calculateSettlementAmount(LoanModel loan);
}

class MockLoanCalculationService implements ILoanCalculationService {
  @override
  double calculateCollateralValue(List<OrnamentModel> ornaments) {
    double total = 0.0;
    for (final o in ornaments) {
      total += o.valuation.totalEstimatedValue;
    }
    return total;
  }

  @override
  double calculateEligibleLoanAmount(double collateralValue, {double ltvPercentage = 75.0}) {
    return (collateralValue * ltvPercentage) / 100.0;
  }

  @override
  double calculateInterest({
    required double principal,
    required double ratePercentage,
    required int tenureMonths,
    InterestType interestType = InterestType.simple,
  }) {
    if (principal <= 0 || ratePercentage <= 0 || tenureMonths <= 0) return 0.0;

    final years = tenureMonths / 12.0;
    if (interestType == InterestType.simple || interestType == InterestType.flatRate) {
      return (principal * ratePercentage * years) / 100.0;
    } else {
      final simpleInterest = (principal * ratePercentage * years) / 100.0;
      return simpleInterest * 1.05; // slight compound increment
    }
  }

  @override
  Map<String, double> calculatePaymentAllocation({
    required double totalPayment,
    required double outstandingInterest,
    required double outstandingPrincipal,
  }) {
    double payLeft = totalPayment;
    double interestComp = 0.0;
    double principalComp = 0.0;

    // 1. Allocate to interest first
    if (payLeft > 0) {
      if (payLeft >= outstandingInterest) {
        interestComp = outstandingInterest;
        payLeft -= outstandingInterest;
      } else {
        interestComp = payLeft;
        payLeft = 0.0;
      }
    }

    // 2. Remaining goes to principal
    if (payLeft > 0) {
      if (payLeft >= outstandingPrincipal) {
        principalComp = outstandingPrincipal;
        payLeft -= outstandingPrincipal;
      } else {
        principalComp = payLeft;
        payLeft = 0.0;
      }
    }

    return {
      'interestComponent': interestComp,
      'principalComponent': principalComp,
      'excessAmount': payLeft,
    };
  }

  @override
  double calculateSettlementAmount(LoanModel loan) {
    return loan.outstandingPrincipal + loan.accruedInterest + loan.processingFee;
  }
}
