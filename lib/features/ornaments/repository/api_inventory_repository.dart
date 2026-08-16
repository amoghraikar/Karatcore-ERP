import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/ornament_model.dart';
import 'inventory_repository.dart';

class ApiInventoryRepository implements IInventoryRepository {
  ApiInventoryRepository(this._api);

  final ApiClient _api;

  @override
  Future<InventoryDashboardMetrics> getDashboardMetrics() async {
    try {
      final dynamic data = await _api.get('${ApiEndpoints.loans}/inventory/metrics');
      return InventoryDashboardMetrics(
        totalOrnamentsCount: (data['total_ornaments_count'] as int?) ?? 0,
        totalGoldWeightGrams: (data['total_gold_weight_grams'] as num?)?.toDouble() ?? 0.0,
        totalSilverWeightGrams: (data['total_silver_weight_grams'] as num?)?.toDouble() ?? 0.0,
        totalGrossWeightGrams: (data['total_gross_weight_grams'] as num?)?.toDouble() ?? 0.0,
        totalNetMetalWeightGrams: (data['total_net_metal_weight_grams'] as num?)?.toDouble() ?? 0.0,
        availableStockCount: (data['available_stock_count'] as int?) ?? 0,
        pledgedStockCount: (data['pledged_stock_count'] as int?) ?? 0,
        soldReleasedCount: (data['sold_released_count'] as int?) ?? 0,
        totalEstimatedValue: (data['total_estimated_value'] as num?)?.toDouble() ?? 0.0,
        attentionItemsCount: (data['attention_items_count'] as int?) ?? 0,
      );
    } catch (_) {
      return const InventoryDashboardMetrics(
        totalOrnamentsCount: 0,
        totalGoldWeightGrams: 0.0,
        totalSilverWeightGrams: 0.0,
        totalGrossWeightGrams: 0.0,
        totalNetMetalWeightGrams: 0.0,
        availableStockCount: 0,
        pledgedStockCount: 0,
        soldReleasedCount: 0,
        totalEstimatedValue: 0.0,
        attentionItemsCount: 0,
      );
    }
  }

  @override
  Future<List<OrnamentModel>> getOrnaments({
    String? searchQuery,
    InventoryFilterParams? filters,
    InventorySortOption? sortOption,
  }) async {
    try {
      final dynamic data = await _api.get(
        '${ApiEndpoints.loans}/ornaments?search=${Uri.encodeComponent(searchQuery ?? '')}',
      );
      if (data is List) {
        return _parseOrnamentsFromJson(data);
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<OrnamentModel?> getOrnamentById(String id) async {
    try {
      final dynamic data = await _api.get('${ApiEndpoints.loans}/ornaments/$id');
      return _parseOrnamentFromJson(data);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<OrnamentModel>> getOrnamentsByCustomerId(String customerId) async {
    try {
      final dynamic data = await _api.get('${ApiEndpoints.loans}/ornaments/customer/$customerId');
      if (data is List) {
        return _parseOrnamentsFromJson(data);
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<OrnamentModel> createOrnament(OrnamentModel ornament) async {
    final dynamic data = await _api.post(
      '${ApiEndpoints.loans}/ornaments',
      body: _ornamentToJson(ornament),
    );
    return _parseOrnamentFromJson(data);
  }

  @override
  Future<OrnamentModel> updateOrnament(OrnamentModel ornament) async {
    final dynamic data = await _api.put(
      '${ApiEndpoints.loans}/ornaments/${ornament.id}',
      body: _ornamentToJson(ornament),
    );
    return _parseOrnamentFromJson(data);
  }

  @override
  Future<OrnamentModel> transferOrnament({
    required String ornamentId,
    required InventoryLocationModel destinationLocation,
    required String actorName,
    required String reason,
  }) async {
    final dynamic data = await _api.post(
      '${ApiEndpoints.loans}/ornaments/$ornamentId/transfer',
      body: {
        'destination_location': _locationToJson(destinationLocation),
        'actor_name': actorName,
        'reason': reason,
      },
    );
    return _parseOrnamentFromJson(data);
  }

  @override
  Future<OrnamentModel> assignCustomerOwnership({
    required String ornamentId,
    required String customerId,
    required String customerName,
    required String kycStatus,
  }) async {
    final dynamic data = await _api.post(
      '${ApiEndpoints.loans}/ornaments/$ornamentId/assign',
      body: {
        'customer_id': customerId,
        'customer_name': customerName,
        'kyc_status': kycStatus,
      },
    );
    return _parseOrnamentFromJson(data);
  }

  @override
  Future<List<InventoryMovementModel>> getAllMovements() async {
    try {
      final dynamic data = await _api.get('${ApiEndpoints.loans}/movements');
      return _parseMovementsFromJson(data);
    } catch (_) {
      return [];
    }
  }

  // Helper methods for JSON parsing (simplified)
  List<OrnamentModel> _parseOrnamentsFromJson(List data) {
    return data.map((json) => _parseOrnamentFromJson(json as Map<String, dynamic>)).toList();
  }

  OrnamentModel _parseOrnamentFromJson(Map<String, dynamic> json) {
    final grossW = (json['gross_weight'] as num?)?.toDouble() ?? 0.0;
    final stoneW = (json['stone_weight'] as num?)?.toDouble() ?? 0.0;
    final netW = (json['net_weight'] as num?)?.toDouble() ?? (grossW - stoneW);

    return OrnamentModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Ornament',
      category: OrnamentCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => OrnamentCategory.rings,
      ),
      metalType: MetalType.values.firstWhere(
        (e) => e.name == json['metal_type'],
        orElse: () => MetalType.gold,
      ),
      purity: OrnamentPurity.values.firstWhere(
        (e) => e.name == json['purity'],
        orElse: () => OrnamentPurity.k22_916,
      ),
      weight: WeightBreakdown(
        grossWeight: grossW,
        stoneWeight: stoneW,
      ),
      valuation: ValuationBreakdown(
        metalRate: 6650.0,
        metalValue: netW * 6650.0,
        totalEstimatedValue: netW * 6650.0,
      ),
      status: OrnamentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrnamentStatus.available,
      ),
      ownershipType: OwnershipType.shopOwned,
      location: const InventoryLocationModel(
        branch: 'Main Branch',
        storageArea: 'Main Vault',
        locker: 'Locker 01',
      ),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> _ornamentToJson(OrnamentModel ornament) {
    return {
      'id': ornament.id,
      'name': ornament.name,
      'category': ornament.category.name,
      'metal_type': ornament.metalType.name,
      'purity': ornament.purity.name,
      'gross_weight': ornament.weight.grossWeight,
      'stone_weight': ornament.weight.stoneWeight,
      'net_weight': ornament.weight.netMetalWeight,
      'status': ornament.status.name,
      'branch': ornament.location.branch,
    };
  }

  Map<String, dynamic> _locationToJson(InventoryLocationModel location) {
    return {
      'branch': location.branch,
      'storageArea': location.storageArea,
      'locker': location.locker,
    };
  }

  List<InventoryMovementModel> _parseMovementsFromJson(dynamic data) {
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().map((json) => _parseMovementFromJson(json)).toList();
    }
    if (data is Map<String, dynamic>) {
      final list = data['data'] ?? data['items'] ?? data['movements'];
      if (list is List) {
        return list.whereType<Map<String, dynamic>>().map((json) => _parseMovementFromJson(json)).toList();
      }
    }
    return [];
  }

  InventoryMovementModel _parseMovementFromJson(Map<String, dynamic> json) {
    return InventoryMovementModel(
      id: json['id'] as String,
      date: DateTime.tryParse(json['movement_date'] as String? ?? '') ?? DateTime.now(),
      type: MovementType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MovementType.transferred,
      ),
      fromLocation: json['from_location'] as String? ?? 'Vault A',
      toLocation: json['to_location'] as String? ?? 'Vault B',
      actorName: json['actor_name'] as String? ?? 'Admin',
      reason: json['reason'] as String? ?? '',
      status: json['status'] as String? ?? 'Completed',
    );
  }
}
