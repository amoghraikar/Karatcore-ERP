import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/customer_model.dart';
import '../repository/customer_repository.dart';
import '../repository/mock_customer_repository.dart';

final customerRepositoryProvider = Provider<ICustomerRepository>((ref) {
  return MockCustomerRepository();
});

final customerSearchQueryProvider = StateProvider<String>((ref) => '');

final customerFilterProvider = StateProvider<CustomerFilterParams>((ref) => const CustomerFilterParams());

final customerSortProvider = StateProvider<CustomerSortOption>((ref) => CustomerSortOption.newest);

class CustomerListNotifier extends StateNotifier<AsyncValue<List<CustomerModel>>> {
  CustomerListNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadCustomers();
  }

  final Ref ref;

  Future<void> loadCustomers() async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(customerRepositoryProvider);
      final query = ref.read(customerSearchQueryProvider);
      final filters = ref.read(customerFilterProvider);
      final sort = ref.read(customerSortProvider);

      final result = await repo.getCustomers(
        searchQuery: query,
        filters: filters,
        sortOption: sort,
      );

      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateSearch(String query) async {
    ref.read(customerSearchQueryProvider.notifier).state = query;
    await loadCustomers();
  }

  Future<void> updateFilters(CustomerFilterParams filters) async {
    ref.read(customerFilterProvider.notifier).state = filters;
    await loadCustomers();
  }

  Future<void> clearFilters() async {
    ref.read(customerFilterProvider.notifier).state = const CustomerFilterParams();
    await loadCustomers();
  }

  Future<void> updateSort(CustomerSortOption sort) async {
    ref.read(customerSortProvider.notifier).state = sort;
    await loadCustomers();
  }

  Future<CustomerModel> createCustomer(CustomerModel newCustomer) async {
    final repo = ref.read(customerRepositoryProvider);
    final created = await repo.createCustomer(newCustomer);
    await loadCustomers();
    return created;
  }

  Future<void> updateStatus(String id, CustomerStatus status) async {
    final repo = ref.read(customerRepositoryProvider);
    await repo.updateCustomerStatus(id, status);
    await loadCustomers();
  }

  Future<void> archiveCustomer(String id) async {
    final repo = ref.read(customerRepositoryProvider);
    await repo.archiveCustomer(id);
    await loadCustomers();
  }

  Future<void> restoreCustomer(String id) async {
    final repo = ref.read(customerRepositoryProvider);
    await repo.restoreCustomer(id);
    await loadCustomers();
  }

  Future<void> addNote(String customerId, String content, String author) async {
    final repo = ref.read(customerRepositoryProvider);
    await repo.addCustomerNote(customerId, content, author);
    await loadCustomers();
    ref.invalidate(customerDetailProvider(customerId));
  }

  Future<void> togglePinNote(String customerId, String noteId) async {
    final repo = ref.read(customerRepositoryProvider);
    await repo.togglePinCustomerNote(customerId, noteId);
    await loadCustomers();
    ref.invalidate(customerDetailProvider(customerId));
  }

  Future<void> deleteNote(String customerId, String noteId) async {
    final repo = ref.read(customerRepositoryProvider);
    await repo.deleteCustomerNote(customerId, noteId);
    await loadCustomers();
    ref.invalidate(customerDetailProvider(customerId));
  }
}

final customerListProvider =
    StateNotifierProvider<CustomerListNotifier, AsyncValue<List<CustomerModel>>>((ref) {
  return CustomerListNotifier(ref);
});

final customerDetailProvider = FutureProvider.family<CustomerModel?, String>((ref, id) async {
  final repo = ref.watch(customerRepositoryProvider);
  return repo.getCustomerById(id);
});
