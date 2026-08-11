/// Abstract service preparing KaratCore ERP for Customer Data Isolation.
/// Customer access will be strictly restricted to records belonging to that customer.
abstract class ICustomerDataIsolationService {
  /// Checks whether an authenticated customer is allowed to access a given target customer ID.
  bool canCustomerAccessRecord({
    required String? authenticatedCustomerId,
    required String targetCustomerId,
  });

  /// Filters a list of customer-owned entities so that only records belonging to
  /// [authenticatedCustomerId] are returned.
  List<T> filterCustomerScope<T>({
    required String? authenticatedCustomerId,
    required List<T> items,
    required String Function(T item) getCustomerId,
  });
}

class CustomerDataIsolationService implements ICustomerDataIsolationService {
  const CustomerDataIsolationService();

  @override
  bool canCustomerAccessRecord({
    required String? authenticatedCustomerId,
    required String targetCustomerId,
  }) {
    if (authenticatedCustomerId == null || authenticatedCustomerId.isEmpty) {
      return false;
    }
    return authenticatedCustomerId == targetCustomerId;
  }

  @override
  List<T> filterCustomerScope<T>({
    required String? authenticatedCustomerId,
    required List<T> items,
    required String Function(T item) getCustomerId,
  }) {
    if (authenticatedCustomerId == null || authenticatedCustomerId.isEmpty) {
      return [];
    }
    return items
        .where((item) => getCustomerId(item) == authenticatedCustomerId)
        .toList();
  }
}
