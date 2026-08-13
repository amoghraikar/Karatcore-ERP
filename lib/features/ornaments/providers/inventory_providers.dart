import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../models/ornament_model.dart';
import '../repository/api_inventory_repository.dart';
import '../repository/inventory_repository.dart';
import '../services/barcode_service.dart';
import '../services/valuation_service.dart';

final inventoryRepositoryProvider = Provider<IInventoryRepository>((ref) {
  return ApiInventoryRepository(ref.watch(apiClientProvider));
});

final valuationServiceProvider = Provider<IValuationService>((ref) {
  return ValuationService();
});

final barcodeServiceProvider = Provider<IBarcodeService>((ref) {
  return BarcodeService();
});

final inventorySearchQueryProvider = StateProvider<String>((ref) => '');

final inventoryFilterProvider = StateProvider<InventoryFilterParams>((ref) => const InventoryFilterParams());

final inventorySortProvider = StateProvider<InventorySortOption>((ref) => InventorySortOption.newest);

final inventoryMetricsProvider = FutureProvider<InventoryDashboardMetrics>((ref) async {
  final repo = ref.watch(inventoryRepositoryProvider);
  return repo.getDashboardMetrics();
});

class OrnamentListNotifier extends StateNotifier<AsyncValue<List<OrnamentModel>>> {
  OrnamentListNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadOrnaments();
  }

  final Ref ref;

  Future<void> loadOrnaments() async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(inventoryRepositoryProvider);
      final query = ref.read(inventorySearchQueryProvider);
      final filters = ref.read(inventoryFilterProvider);
      final sort = ref.read(inventorySortProvider);

      final list = await repo.getOrnaments(
        searchQuery: query,
        filters: filters,
        sortOption: sort,
      );
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateSearch(String query) async {
    ref.read(inventorySearchQueryProvider.notifier).state = query;
    await loadOrnaments();
  }

  Future<void> updateFilters(InventoryFilterParams filters) async {
    ref.read(inventoryFilterProvider.notifier).state = filters;
    await loadOrnaments();
  }

  Future<void> clearFilters() async {
    ref.read(inventoryFilterProvider.notifier).state = const InventoryFilterParams();
    await loadOrnaments();
  }

  Future<void> updateSort(InventorySortOption sort) async {
    ref.read(inventorySortProvider.notifier).state = sort;
    await loadOrnaments();
  }

  Future<void> transferOrnament({
    required String ornamentId,
    required InventoryLocationModel destination,
    required String reason,
  }) async {
    final repo = ref.read(inventoryRepositoryProvider);
    await repo.transferOrnament(
      ornamentId: ornamentId,
      destinationLocation: destination,
      actorName: 'Staff Member',
      reason: reason,
    );
    await loadOrnaments();
    ref.invalidate(inventoryMetricsProvider);
    ref.invalidate(ornamentDetailProvider(ornamentId));
  }
}

final ornamentListProvider = StateNotifierProvider<OrnamentListNotifier, AsyncValue<List<OrnamentModel>>>((ref) {
  return OrnamentListNotifier(ref);
});

final ornamentDetailProvider = FutureProvider.family<OrnamentModel?, String>((ref, id) async {
  final repo = ref.watch(inventoryRepositoryProvider);
  return repo.getOrnamentById(id);
});

final customerOrnamentsProvider = FutureProvider.family<List<OrnamentModel>, String>((ref, customerId) async {
  final repo = ref.watch(inventoryRepositoryProvider);
  return repo.getOrnamentsByCustomerId(customerId);
});

final inventoryMovementsProvider = FutureProvider<List<InventoryMovementModel>>((ref) async {
  final repo = ref.watch(inventoryRepositoryProvider);
  return repo.getAllMovements();
});
