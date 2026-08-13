import '../models/ornament_model.dart';

abstract class IValuationService {
  double getStandardMetalRatePerGram(MetalType metal, OrnamentPurity purity);

  ValuationBreakdown calculateValuation({
    required MetalType metal,
    required OrnamentPurity purity,
    required double netMetalWeightGrams,
    double makingCharges = 0.0,
    double stoneValue = 0.0,
    double otherCharges = 0.0,
  });
}

class ValuationService implements IValuationService {
  @override
  double getStandardMetalRatePerGram(MetalType metal, OrnamentPurity purity) {
    if (metal == MetalType.gold) {
      const base24KRate = 7250.0; // INR / gram for 24K
      return base24KRate * purity.purityRatio;
    } else if (metal == MetalType.silver) {
      const baseSilverRate = 88.0; // INR / gram for Fine Silver
      return baseSilverRate * purity.purityRatio;
    } else if (metal == MetalType.platinum) {
      return 3200.0;
    }
    return 1000.0;
  }

  @override
  ValuationBreakdown calculateValuation({
    required MetalType metal,
    required OrnamentPurity purity,
    required double netMetalWeightGrams,
    double makingCharges = 0.0,
    double stoneValue = 0.0,
    double otherCharges = 0.0,
  }) {
    final rate = getStandardMetalRatePerGram(metal, purity);
    final metalVal = netMetalWeightGrams * rate;
    final total = metalVal + makingCharges + stoneValue + otherCharges;

    return ValuationBreakdown(
      metalRate: rate,
      metalValue: metalVal,
      makingCharges: makingCharges,
      stoneValue: stoneValue,
      otherCharges: otherCharges,
      totalEstimatedValue: total,
    );
  }
}
