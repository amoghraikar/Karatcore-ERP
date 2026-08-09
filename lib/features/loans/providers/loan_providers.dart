import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/loan_model.dart';
import '../repository/loan_repository.dart';
import '../repository/mock_loan_repository.dart';
import '../repository/mock_pledge_repository.dart';
import '../repository/pledge_repository.dart';
import '../services/loan_calculation_service.dart';

final loanRepositoryProvider = Provider<ILoanRepository>((ref) {
  return MockLoanRepository();
});

final pledgeRepositoryProvider = Provider<IPledgeRepository>((ref) {
  return MockPledgeRepository();
});

final loanCalculationServiceProvider = Provider<ILoanCalculationService>((ref) {
  return MockLoanCalculationService();
});

final loanSearchQueryProvider = StateProvider<String>((ref) => '');

final loanFilterProvider = StateProvider<LoanFilterParams>((ref) => const LoanFilterParams());

final loanSortProvider = StateProvider<LoanSortOption>((ref) => LoanSortOption.newest);

final loanMetricsProvider = FutureProvider<LoanDashboardMetrics>((ref) async {
  final repo = ref.watch(loanRepositoryProvider);
  return repo.getDashboardMetrics();
});

class LoanListNotifier extends StateNotifier<AsyncValue<List<LoanModel>>> {
  LoanListNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadLoans();
  }

  final Ref ref;

  Future<void> loadLoans() async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(loanRepositoryProvider);
      final query = ref.read(loanSearchQueryProvider);
      final filters = ref.read(loanFilterProvider);
      final sort = ref.read(loanSortProvider);

      final list = await repo.getLoans(
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
    ref.read(loanSearchQueryProvider.notifier).state = query;
    await loadLoans();
  }

  Future<void> updateFilters(LoanFilterParams filters) async {
    ref.read(loanFilterProvider.notifier).state = filters;
    await loadLoans();
  }

  Future<void> clearFilters() async {
    ref.read(loanFilterProvider.notifier).state = const LoanFilterParams();
    await loadLoans();
  }

  Future<void> updateSort(LoanSortOption sort) async {
    ref.read(loanSortProvider.notifier).state = sort;
    await loadLoans();
  }

  Future<void> recordPayment({
    required String loanId,
    required double amount,
    required DisbursementMethod method,
    required String recordedBy,
    String notes = '',
  }) async {
    final repo = ref.read(loanRepositoryProvider);
    await repo.recordPayment(
      loanId: loanId,
      amount: amount,
      method: method,
      recordedBy: recordedBy,
      notes: notes,
    );
    await loadLoans();
    ref.invalidate(loanMetricsProvider);
    ref.invalidate(loanDetailProvider(loanId));
  }

  Future<void> settleLoan({
    required String loanId,
    required double settlementAmount,
    required DisbursementMethod method,
    required String settledBy,
  }) async {
    final repo = ref.read(loanRepositoryProvider);
    await repo.settleLoan(
      loanId: loanId,
      settlementAmount: settlementAmount,
      method: method,
      settledBy: settledBy,
    );
    await loadLoans();
    ref.invalidate(loanMetricsProvider);
    ref.invalidate(loanDetailProvider(loanId));
  }

  Future<void> releaseCollateral({
    required String loanId,
    required String verifiedByStaff,
    String notes = '',
  }) async {
    final repo = ref.read(loanRepositoryProvider);
    await repo.releaseCollateral(
      loanId: loanId,
      verifiedByStaff: verifiedByStaff,
      notes: notes,
    );
    await loadLoans();
    ref.invalidate(loanMetricsProvider);
    ref.invalidate(loanDetailProvider(loanId));
  }
}

final loanListProvider = StateNotifierProvider<LoanListNotifier, AsyncValue<List<LoanModel>>>((ref) {
  return LoanListNotifier(ref);
});

final loanDetailProvider = FutureProvider.family<LoanModel?, String>((ref, id) async {
  final repo = ref.watch(loanRepositoryProvider);
  return repo.getLoanById(id);
});

final customerLoansProvider = FutureProvider.family<List<LoanModel>, String>((ref, customerId) async {
  final repo = ref.watch(loanRepositoryProvider);
  return repo.getLoansByCustomerId(customerId);
});
