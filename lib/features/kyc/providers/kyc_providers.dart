import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../models/kyc_model.dart';
import '../repository/api_kyc_repository.dart';
import '../repository/kyc_repository.dart';
import '../services/kyc_verification_service.dart';

final kycRepositoryProvider = Provider<IKycRepository>((ref) {
  return ApiKycRepository(ref.watch(apiClientProvider));
});

final kycServiceProvider = Provider<IKycVerificationService>((ref) {
  return KycVerificationService();
});

final kycSearchQueryProvider = StateProvider<String>((ref) => '');

final kycFilterProvider = StateProvider<KycFilterParams>((ref) => const KycFilterParams());

final kycSortProvider = StateProvider<KycSortOption>((ref) => KycSortOption.submittedNewest);

final kycMetricsProvider = FutureProvider<KycDashboardMetrics>((ref) async {
  final repo = ref.watch(kycRepositoryProvider);
  return repo.getDashboardMetrics();
});

class KycQueueNotifier extends StateNotifier<AsyncValue<List<KycRecordModel>>> {
  KycQueueNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadQueue();
  }

  final Ref ref;

  Future<void> loadQueue() async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(kycRepositoryProvider);
      final query = ref.read(kycSearchQueryProvider);
      final filters = ref.read(kycFilterProvider);
      final sort = ref.read(kycSortProvider);

      final queue = await repo.getKycQueue(
        searchQuery: query,
        filters: filters,
        sortOption: sort,
      );
      state = AsyncValue.data(queue);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateSearch(String query) async {
    ref.read(kycSearchQueryProvider.notifier).state = query;
    await loadQueue();
  }

  Future<void> updateFilters(KycFilterParams filters) async {
    ref.read(kycFilterProvider.notifier).state = filters;
    await loadQueue();
  }

  Future<void> clearFilters() async {
    ref.read(kycFilterProvider.notifier).state = const KycFilterParams();
    await loadQueue();
  }

  Future<void> updateSort(KycSortOption sort) async {
    ref.read(kycSortProvider.notifier).state = sort;
    await loadQueue();
  }

  Future<void> approveKyc(String customerId, String reviewerNotes, {KycVerificationLevel level = KycVerificationLevel.standard}) async {
    final repo = ref.read(kycRepositoryProvider);
    await repo.approveKyc(customerId: customerId, reviewerName: 'Current Staff', reviewerNotes: reviewerNotes, level: level);
    await loadQueue();
    ref.invalidate(kycMetricsProvider);
    ref.invalidate(kycDetailProvider(customerId));
  }

  Future<void> rejectKyc(String customerId, String reasonCategory, String reviewerNotes) async {
    final repo = ref.read(kycRepositoryProvider);
    await repo.rejectKyc(customerId: customerId, reviewerName: 'Current Staff', reasonCategory: reasonCategory, reviewerNotes: reviewerNotes);
    await loadQueue();
    ref.invalidate(kycMetricsProvider);
    ref.invalidate(kycDetailProvider(customerId));
  }

  Future<void> requestReverification(String customerId, String reason) async {
    final repo = ref.read(kycRepositoryProvider);
    await repo.requestReverification(customerId: customerId, reviewerName: 'Current Staff', reason: reason);
    await loadQueue();
    ref.invalidate(kycMetricsProvider);
    ref.invalidate(kycDetailProvider(customerId));
  }
}

final kycQueueProvider = StateNotifierProvider<KycQueueNotifier, AsyncValue<List<KycRecordModel>>>((ref) {
  return KycQueueNotifier(ref);
});

final kycDetailProvider = FutureProvider.family<KycRecordModel?, String>((ref, customerId) async {
  final repo = ref.watch(kycRepositoryProvider);
  return repo.getKycRecordByCustomerId(customerId);
});
