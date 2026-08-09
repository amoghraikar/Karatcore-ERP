import '../models/ornament_model.dart';
import 'inventory_repository.dart';

class MockInventoryRepository implements IInventoryRepository {
  MockInventoryRepository() {
    _seedData();
  }

  final List<OrnamentModel> _ornaments = [];

  void _seedData() {
    if (_ornaments.isNotEmpty) return;

    final now = DateTime.now();

    const categories = OrnamentCategory.values;
    const purities = [
      OrnamentPurity.k22_916,
      OrnamentPurity.k24_999,
      OrnamentPurity.k18_750,
      OrnamentPurity.silver925,
      OrnamentPurity.k22_916,
    ];
    final statuses = [
      OrnamentStatus.available,
      OrnamentStatus.pledged,
      OrnamentStatus.reserved,
      OrnamentStatus.available,
      OrnamentStatus.released,
      OrnamentStatus.sold,
    ];
    final branches = ['Main Branch (Store 01)', 'North Extension Branch', 'South Jeweller Hub'];
    final lockers = ['Locker #01 (Main Safe)', 'Locker #02 (Display Vault)', 'Locker #03 (Loan Reserve)'];

    final customers = [
      {'id': 'KC-CUS-000101', 'name': 'Rahul Kumar Sharma'},
      {'id': 'KC-CUS-000102', 'name': 'Sunita Verma'},
      {'id': 'KC-CUS-000103', 'name': 'Vikramaditya Singh Rathore'},
      {'id': 'KC-CUS-000104', 'name': 'Priya Patel'},
      {'id': 'KC-CUS-000105', 'name': 'Amitabh Banerjee'},
    ];

    for (int i = 1; i <= 50; i++) {
      final id = 'KC-ORN-${(100 + i).toString().padLeft(6, '0')}';
      final category = categories[(i - 1) % categories.length];
      final isSilver = (i % 7 == 0);
      final metal = isSilver ? MetalType.silver : MetalType.gold;
      final purity = isSilver
          ? OrnamentPurity.silver925
          : purities[(i - 1) % purities.length];

      final status = statuses[(i - 1) % statuses.length];
      final gross = 10.0 + (i * 2.5) % 150.0;
      final stone = (i % 3 == 0) ? 1.5 + (i % 5) * 0.5 : 0.0;
      final other = (i % 5 == 0) ? 0.8 : 0.0;
      final weight = WeightBreakdown(grossWeight: gross, stoneWeight: stone, otherWeight: other);

      final metalRate = isSilver ? 88.0 : (7250.0 * purity.purityRatio);
      final metalVal = weight.netMetalWeight * metalRate;
      final making = metalVal * 0.08;
      final stoneVal = stone * 2500.0;
      final valuation = ValuationBreakdown(
        metalRate: metalRate,
        metalValue: metalVal,
        makingCharges: making,
        stoneValue: stoneVal,
        otherCharges: 250.0,
        totalEstimatedValue: metalVal + making + stoneVal + 250.0,
      );

      final cust = customers[(i - 1) % customers.length];
      final isPledgedOrCustomer = status == OrnamentStatus.pledged || status == OrnamentStatus.reserved || i % 4 == 0;
      final ownerType = isPledgedOrCustomer
          ? (status == OrnamentStatus.pledged ? OwnershipType.pledged : OwnershipType.customerOwned)
          : OwnershipType.shopOwned;

      final branch = branches[(i - 1) % branches.length];
      final locker = lockers[(i - 1) % lockers.length];
      final location = InventoryLocationModel(
        branch: branch,
        storageArea: 'Central Vault Security',
        locker: locker,
        shelf: 'Shelf ${(i % 4) + 1}',
        tray: 'Tray #${(i % 8) + 1}',
      );

      final ornament = OrnamentModel(
        id: id,
        name: '${metal.label} ${purity.label} ${category.label} #${i.toString().padLeft(3, '0')}',
        category: category,
        subcategory: 'Classic Heritage',
        description: 'Authentic hallmarked ${purity.label} ${metal.label} ${category.label.toLowerCase()} with high-precision craftsmanship.',
        metalType: metal,
        purity: purity,
        weight: weight,
        valuation: valuation,
        status: status,
        ownershipType: ownerType,
        ownerCustomerId: isPledgedOrCustomer ? cust['id'] : null,
        ownerCustomerName: isPledgedOrCustomer ? cust['name'] : null,
        ownerKycStatus: 'Verified',
        pledgeLoanId: status == OrnamentStatus.pledged ? 'GL-948${(i % 9) + 1}' : null,
        location: location,
        barcode: '890123456${i.toString().padLeft(4, '0')}',
        qrCode: 'QR-$id',
        imageUrl: isSilver
            ? 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908'
            : 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f',
        tags: [purity.label, metal.label, status.label],
        documents: [
          OrnamentDocumentModel(
            id: 'DOC-ORN-$i',
            name: 'BIS Hallmark Certificate #${8800 + i}',
            type: 'Hallmark Certificate',
            uploadDate: now.subtract(Duration(days: i * 3)),
            uploadedBy: 'Store Auditor',
          ),
        ],
        movements: [
          InventoryMovementModel(
            id: 'MOV-$i-1',
            date: now.subtract(Duration(days: i * 4)),
            type: MovementType.received,
            fromLocation: 'Supplier Intake / Store Receiving',
            toLocation: location.fullLocationPath,
            actorName: 'Arjun Mehta (Manager)',
            reason: 'Initial Stock Audit Intake',
            status: 'Completed',
          ),
          if (status == OrnamentStatus.pledged)
            InventoryMovementModel(
              id: 'MOV-$i-2',
              date: now.subtract(Duration(days: i * 2)),
              type: MovementType.pledged,
              fromLocation: 'Display Tray',
              toLocation: location.fullLocationPath,
              actorName: 'Anil Gupta (Admin)',
              reason: 'Pledged for Gold Loan #GL-948${(i % 9) + 1}',
              status: 'Active Pledge',
            ),
        ],
        auditLogs: [
          OrnamentAuditLog(
            id: 'AUD-ORN-$i',
            timestamp: now.subtract(Duration(days: i * 4)),
            actorName: 'Arjun Mehta',
            action: 'Ornament Logged',
            description: 'Created record for $id with gross weight ${weight.grossWeight}g.',
            location: location.fullLocationPath,
          ),
        ],
        createdAt: now.subtract(Duration(days: i * 5)),
        updatedAt: now.subtract(Duration(days: i)),
      );

      _ornaments.add(ornament);
    }
  }

  @override
  Future<InventoryDashboardMetrics> getDashboardMetrics() async {
    await Future.delayed(const Duration(milliseconds: 200));

    final totalCount = _ornaments.length;
    double goldWt = 0.0;
    double silverWt = 0.0;
    double totalGross = 0.0;
    double totalNet = 0.0;
    double totalVal = 0.0;
    int avail = 0;
    int pledged = 0;
    int sold = 0;
    int attention = 0;

    for (final o in _ornaments) {
      totalGross += o.weight.grossWeight;
      totalNet += o.weight.netMetalWeight;
      totalVal += o.valuation.totalEstimatedValue;

      if (o.metalType == MetalType.gold) {
        goldWt += o.weight.netMetalWeight;
      } else if (o.metalType == MetalType.silver) {
        silverWt += o.weight.netMetalWeight;
      }

      if (o.status == OrnamentStatus.available) avail++;
      if (o.status == OrnamentStatus.pledged) pledged++;
      if (o.status == OrnamentStatus.sold || o.status == OrnamentStatus.released) sold++;
      if (o.status == OrnamentStatus.damaged || o.status == OrnamentStatus.reserved) attention++;
    }

    return InventoryDashboardMetrics(
      totalOrnamentsCount: totalCount,
      totalGoldWeightGrams: goldWt,
      totalSilverWeightGrams: silverWt,
      totalGrossWeightGrams: totalGross,
      totalNetMetalWeightGrams: totalNet,
      availableStockCount: avail,
      pledgedStockCount: pledged,
      soldReleasedCount: sold,
      totalEstimatedValue: totalVal,
      attentionItemsCount: attention,
    );
  }

  @override
  Future<List<OrnamentModel>> getOrnaments({
    String? searchQuery,
    InventoryFilterParams? filters,
    InventorySortOption? sortOption,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    Iterable<OrnamentModel> result = List.of(_ornaments);

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      result = result.where((o) {
        return o.name.toLowerCase().contains(q) ||
            o.id.toLowerCase().contains(q) ||
            o.barcode.toLowerCase().contains(q) ||
            o.qrCode.toLowerCase().contains(q) ||
            (o.ownerCustomerId != null && o.ownerCustomerId!.toLowerCase().contains(q)) ||
            (o.ownerCustomerName != null && o.ownerCustomerName!.toLowerCase().contains(q)) ||
            o.category.label.toLowerCase().contains(q) ||
            o.metalType.label.toLowerCase().contains(q) ||
            o.location.branch.toLowerCase().contains(q);
      });
    }

    if (filters != null) {
      if (filters.metalType != null) {
        result = result.where((o) => o.metalType == filters.metalType);
      }
      if (filters.purity != null) {
        result = result.where((o) => o.purity == filters.purity);
      }
      if (filters.category != null) {
        result = result.where((o) => o.category == filters.category);
      }
      if (filters.status != null) {
        result = result.where((o) => o.status == filters.status);
      }
      if (filters.ownershipType != null) {
        result = result.where((o) => o.ownershipType == filters.ownershipType);
      }
      if (filters.branch != null && filters.branch!.isNotEmpty) {
        result = result.where((o) => o.location.branch == filters.branch);
      }
      if (filters.ownerCustomerId != null && filters.ownerCustomerId!.isNotEmpty) {
        result = result.where((o) => o.ownerCustomerId == filters.ownerCustomerId);
      }
    }

    final list = result.toList();
    final sort = sortOption ?? InventorySortOption.newest;

    switch (sort) {
      case InventorySortOption.newest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case InventorySortOption.oldest:
        list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case InventorySortOption.nameAsc:
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
      case InventorySortOption.weightHighToLow:
        list.sort((a, b) => b.weight.grossWeight.compareTo(a.weight.grossWeight));
        break;
      case InventorySortOption.valueHighToLow:
        list.sort((a, b) => b.valuation.totalEstimatedValue.compareTo(a.valuation.totalEstimatedValue));
        break;
      case InventorySortOption.statusPriority:
        list.sort((a, b) => a.status.index.compareTo(b.status.index));
        break;
    }

    return list;
  }

  @override
  Future<OrnamentModel?> getOrnamentById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _ornaments.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<OrnamentModel>> getOrnamentsByCustomerId(String customerId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _ornaments.where((o) => o.ownerCustomerId == customerId).toList();
  }

  @override
  Future<OrnamentModel> createOrnament(OrnamentModel ornament) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _ornaments.insert(0, ornament);
    return ornament;
  }

  @override
  Future<OrnamentModel> updateOrnament(OrnamentModel ornament) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _ornaments.indexWhere((o) => o.id == ornament.id);
    if (index != -1) {
      _ornaments[index] = ornament;
      return ornament;
    }
    throw Exception('Ornament not found');
  }

  @override
  Future<OrnamentModel> transferOrnament({
    required String ornamentId,
    required InventoryLocationModel destinationLocation,
    required String actorName,
    required String reason,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _ornaments.indexWhere((o) => o.id == ornamentId);
    if (index != -1) {
      final existing = _ornaments[index];
      final now = DateTime.now();

      final movement = InventoryMovementModel(
        id: 'MOV-${now.millisecondsSinceEpoch}',
        date: now,
        type: MovementType.transferred,
        fromLocation: existing.location.fullLocationPath,
        toLocation: destinationLocation.fullLocationPath,
        actorName: actorName,
        reason: reason,
        status: 'Completed',
      );

      final audit = OrnamentAuditLog(
        id: 'AUD-${now.millisecondsSinceEpoch}',
        timestamp: now,
        actorName: actorName,
        action: 'Vault Transfer',
        description: 'Transferred from ${existing.location.locker} to ${destinationLocation.locker}. Reason: $reason',
        location: destinationLocation.fullLocationPath,
      );

      final updatedMovements = List<InventoryMovementModel>.from(existing.movements)..insert(0, movement);
      final updatedAudits = List<OrnamentAuditLog>.from(existing.auditLogs)..insert(0, audit);

      final updated = existing.copyWith(
        location: destinationLocation,
        movements: updatedMovements,
        auditLogs: updatedAudits,
        updatedAt: now,
      );

      _ornaments[index] = updated;
      return updated;
    }
    throw Exception('Ornament not found');
  }

  @override
  Future<OrnamentModel> assignCustomerOwnership({
    required String ornamentId,
    required String customerId,
    required String customerName,
    required String kycStatus,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _ornaments.indexWhere((o) => o.id == ornamentId);
    if (index != -1) {
      final existing = _ornaments[index];
      final now = DateTime.now();

      final updated = existing.copyWith(
        ownershipType: OwnershipType.customerOwned,
        ownerCustomerId: customerId,
        ownerCustomerName: customerName,
        ownerKycStatus: kycStatus,
        updatedAt: now,
      );

      _ornaments[index] = updated;
      return updated;
    }
    throw Exception('Ornament not found');
  }

  @override
  Future<List<InventoryMovementModel>> getAllMovements() async {
    await Future.delayed(const Duration(milliseconds: 200));
    final List<InventoryMovementModel> all = [];
    for (final o in _ornaments) {
      all.addAll(o.movements);
    }
    all.sort((a, b) => b.date.compareTo(a.date));
    return all;
  }
}
