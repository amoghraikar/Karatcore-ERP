import 'package:flutter_test/flutter_test.dart';
import 'package:karatcore_erp/features/ornaments/models/ornament_model.dart';
import 'package:karatcore_erp/features/ornaments/repository/inventory_repository.dart';
import 'package:karatcore_erp/features/ornaments/repository/mock_inventory_repository.dart';
import 'package:karatcore_erp/features/ornaments/services/barcode_service.dart';
import 'package:karatcore_erp/features/ornaments/services/valuation_service.dart';

void main() {
  group('Ornament & Inventory Management Domain & Repository Tests', () {
    late IInventoryRepository repo;
    late IValuationService valuationService;
    late IBarcodeService barcodeService;

    setUp(() {
      repo = MockInventoryRepository();
      valuationService = MockValuationService();
      barcodeService = MockBarcodeService();
    });

    test('MockInventoryRepository seeds 50 initial ornaments', () async {
      final list = await repo.getOrnaments();
      expect(list.length, equals(50));
    });

    test('WeightBreakdown calculates net metal weight correctly (Gross - Stone - Other)', () {
      const weight = WeightBreakdown(
        grossWeight: 48.5,
        stoneWeight: 2.5,
        otherWeight: 0.5,
      );
      expect(weight.netMetalWeight, equals(45.5));
    });

    test('MockValuationService calculates metal value and estimated total value', () {
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

    test('MockBarcodeService generates valid barcode and QR code', () {
      final barcode = barcodeService.generateBarcode('KC-ORN-000101');
      final qr = barcodeService.generateQrCode('KC-ORN-000101');

      expect(barcode, startsWith('890'));
      expect(qr, contains('KC-ORN-000101'));
    });

    test('getDashboardMetrics calculates correct total weights and count', () async {
      final metrics = await repo.getDashboardMetrics();
      expect(metrics.totalOrnamentsCount, equals(50));
      expect(metrics.totalGrossWeightGrams, greaterThan(0));
      expect(metrics.totalNetMetalWeightGrams, greaterThan(0));
    });

    test('transferOrnament updates location and appends movement log', () async {
      const newLoc = InventoryLocationModel(
        branch: 'South Jeweller Hub',
        storageArea: 'Secure Safe',
        locker: 'Locker #03',
      );

      final updated = await repo.transferOrnament(
        ornamentId: 'KC-ORN-000101',
        destinationLocation: newLoc,
        actorName: 'Unit Tester',
        reason: 'Rebalancing inventory',
      );

      expect(updated.location.branch, equals('South Jeweller Hub'));
      expect(updated.movements.first.reason, equals('Rebalancing inventory'));
    });
  });
}
