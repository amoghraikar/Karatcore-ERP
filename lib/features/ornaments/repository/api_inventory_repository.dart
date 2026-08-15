import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/ornament_model.dart';
import 'inventory_repository.dart';

class ApiInventoryRepository implements IInventoryRepository {
  ApiInventoryRepository(this._api);

  final ApiClient _api;

  @override
  Future<InventoryDashboardMetrics> getDashboardMetrics() async {
    final dynamic data = await _api.get('${ApiEndpoints.loans}/inventory/metrics');
    return InventoryDashboardMetrics(
      totalOrnamentsCount: data['total_ornaments_count'] as int,
      totalGoldWeightGrams: (data['total_gold_weight_grams'] as num).toDouble(),
      totalSilverWeightGrams: (data['total_silver_weight_grams'] as num).toDouble(),
      totalGrossWeightGrams: (data['total_gross_weight_grams'] as num).toDouble(),
      totalNetMetalWeightGrams: (data['total_net_metal_weight_grams'] as num).toDouble(),
      availableStockCount: data['available_stock_count'] as int,
      pledgedStockCount: data['pledged_stock_count'] as int,
      soldReleasedCount: data['sold_released_count'] as int,
      totalEstimatedValue: (data['total_estimated_value'] as num).toDouble(),
      attentionItemsCount: data['attention_items_count'] as int,
    );
  }

  @override
  Future<List<OrnamentModel>> getOrnaments({
    String? searchQuery,
    InventoryFilterParams? filters,
    InventorySortOption? sortOption,
  }) async {
    final dynamic data = await _api.get(
      '${ApiEndpoints.loans}/ornaments?search=${Uri.encodeComponent(searchQuery ?? '')}',
    );
    return _parseOrnamentsFromJson(data as List);
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
    final dynamic data = await _api.get('${ApiEndpoints.loans}/ornaments/customer/$customerId');
    return _parseOrnamentsFromJson(data as List);
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
    final dynamic data = await _api.get('${ApiEndpoints.loans}/movements');
    return _parseMovementsFromJson(data as List);
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

  List<InventoryMovementModel> _parseMovementsFromJson(List data) {
    return data.map((json) => _parseMovementFromJson(json as Map<String, dynamic>)).toList();
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
