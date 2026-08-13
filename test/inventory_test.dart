import 'package:flutter_test/flutter_test.dart';
import 'package:karatcore_erp/features/ornaments/models/ornament_model.dart';
import 'package:karatcore_erp/features/ornaments/services/barcode_service.dart';
import 'package:karatcore_erp/features/ornaments/services/valuation_service.dart';

void main() {
  group('Ornament & Inventory Domain Tests', () {
    late IValuationService valuationService;
    late IBarcodeService barcodeService;

    setUp(() {
      valuationService = ValuationService();
      barcodeService = BarcodeService();
    });

    test('WeightBreakdown calculates net metal weight correctly (Gross - Stone - Other)', () {
      const weight = WeightBreakdown(
        grossWeight: 48.5,
        stoneWeight: 2.5,
        otherWeight: 0.5,
      );
      expect(weight.netMetalWeight, equals(45.5));
    });

    test('ValuationService calculates metal value and estimated total value', () {
      final valuation = valuationService.calculateValuation(
        metal: MetalType.gold,
        purity: OrnamentPurity.k22_916,
        netMetalWeightGrams: 10.0,
        makingCharges: 2000.0,
        stoneValue: 1500.0,
      );

      expect(valuation.metalRate, greaterThan(0));
      expect(valuation.metalValue, equals(10.0 * valuation.metalRate));
      expect(valuation.totalEstimatedValue, equals(valuation.metalValue + 2000.0 + 1500.0));
    });

    test('BarcodeService generates valid barcode and QR code', () {
      final barcode = barcodeService.generateBarcode('KC-ORN-000101');
      final qr = barcodeService.generateQrCode('KC-ORN-000101');

      expect(barcode, startsWith('890'));
      expect(qr, contains('KC-ORN-000101'));
    });
  });
}
