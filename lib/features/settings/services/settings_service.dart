import '../models/settings_model.dart';

abstract class ISettingsService {
  double calculateMaxLoanAmount({
    required double grossWeightGrams,
    required double stoneWeightGrams,
    required double purityPcnt,
    required FinancialSettings settings,
  });

  bool isValidGstin(String gstin);
  bool isValidBisRegistration(String bisNo);
}

class SettingsService implements ISettingsService {
  @override
  double calculateMaxLoanAmount({
    required double grossWeightGrams,
    required double stoneWeightGrams,
    required double purityPcnt,
    required FinancialSettings settings,
  }) {
    final netWeight = (grossWeightGrams - stoneWeightGrams).clamp(0.0, 1000000.0);

    double ratePerGram = settings.gold22kRatePerGram;
    if (purityPcnt >= 99.0) {
      ratePerGram = settings.gold24kRatePerGram;
    } else if (purityPcnt >= 91.6) {
      ratePerGram = settings.gold22kRatePerGram;
    } else if (purityPcnt >= 75.0) {
      ratePerGram = settings.gold18kRatePerGram;
    } else {
      ratePerGram = settings.gold18kRatePerGram * (purityPcnt / 75.0);
    }

    final totalMarketValue = netWeight * ratePerGram;
    final maxLoan = totalMarketValue * (settings.maxLtvPercentage / 100.0);
    return maxLoan;
  }

  @override
  bool isValidGstin(String gstin) {
    final pattern = RegExp(r'^\d{2}[A-Z]{5}\d{4}[A-Z]{1}[A-Z0-9]{1}Z[A-Z0-9]{1}$');
    return pattern.hasMatch(gstin.toUpperCase());
  }

  @override
  bool isValidBisRegistration(String bisNo) {
    return bisNo.trim().length >= 8;
  }
}
