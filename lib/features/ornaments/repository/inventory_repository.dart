import '../models/ornament_model.dart';

class InventoryFilterParams {
  const InventoryFilterParams({
    this.metalType,
    this.purity,
    this.category,
    this.status,
    this.ownershipType,
    this.branch,
    this.ownerCustomerId,
  });

  final MetalType? metalType;
  final OrnamentPurity? purity;
  final OrnamentCategory? category;
  final OrnamentStatus? status;
  final OwnershipType? ownershipType;
  final String? branch;
  final String? ownerCustomerId;

  bool get isEmpty =>
      metalType == null &&
      purity == null &&
      category == null &&
      status == null &&
      ownershipType == null &&
      branch == null &&
      ownerCustomerId == null;
}

enum InventorySortOption {
  newest('Date Added (Newest)'),
  oldest('Date Added (Oldest)'),
  nameAsc('Name (A-Z)'),
  weightHighToLow('Highest Gross Weight'),
  valueHighToLow('Highest Estimated Value'),
  statusPriority('Status Priority');

  const InventorySortOption(this.label);
  final String label;
}

class InventoryDashboardMetrics {
  const InventoryDashboardMetrics({
    required this.totalOrnamentsCount,
    required this.totalGoldWeightGrams,
    required this.totalSilverWeightGrams,
    required this.totalGrossWeightGrams,
    required this.totalNetMetalWeightGrams,
    required this.availableStockCount,
    required this.pledgedStockCount,
    required this.soldReleasedCount,
    required this.totalEstimatedValue,
    required this.attentionItemsCount,
  });

  final int totalOrnamentsCount;
  final double totalGoldWeightGrams;
  final double totalSilverWeightGrams;
  final double totalGrossWeightGrams;
  final double totalNetMetalWeightGrams;
  final int availableStockCount;
  final int pledgedStockCount;
  final int soldReleasedCount;
  final double totalEstimatedValue;
  final int attentionItemsCount;
}

abstract class IInventoryRepository {
  Future<InventoryDashboardMetrics> getDashboardMetrics();

  Future<List<OrnamentModel>> getOrnaments({
    String? searchQuery,
    InventoryFilterParams? filters,
    InventorySortOption? sortOption,
  });

  Future<OrnamentModel?> getOrnamentById(String id);

  Future<List<OrnamentModel>> getOrnamentsByCustomerId(String customerId);

  Future<OrnamentModel> createOrnament(OrnamentModel ornament);

  Future<OrnamentModel> updateOrnament(OrnamentModel ornament);

  Future<OrnamentModel> transferOrnament({
    required String ornamentId,
    required InventoryLocationModel destinationLocation,
    required String actorName,
    required String reason,
  });

  Future<OrnamentModel> assignCustomerOwnership({
    required String ornamentId,
    required String customerId,
    required String customerName,
    required String kycStatus,
  });

  Future<List<InventoryMovementModel>> getAllMovements();
}
