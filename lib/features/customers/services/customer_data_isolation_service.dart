enum AccessorType { owner, customer }

class CustomerDataScope {
  const CustomerDataScope({
    required this.accessorType,
    this.authenticatedCustomerId,
  });

  final AccessorType accessorType;
  final String? authenticatedCustomerId;

  bool get isOwner => accessorType == AccessorType.owner;
  bool get isCustomer => accessorType == AccessorType.customer;

  /// Validates whether the accessor has privilege to read or modify a record belonging to [recordOwnerCustomerId].
  ///
  /// - Store Owner: Can access all customer records.
  /// - Customer: Can access ONLY records matching their own [authenticatedCustomerId].
  bool canAccessRecord({required String recordOwnerCustomerId}) {
    if (isOwner) return true;
    if (isCustomer && authenticatedCustomerId != null) {
      return authenticatedCustomerId == recordOwnerCustomerId;
    }
    return false;
  }

  /// Filters a list of items belonging to customers based on data isolation rules.
  List<T> filterAccessibleRecords<T>({
    required List<T> records,
    required String Function(T item) getRecordCustomerId,
  }) {
    if (isOwner) return records;
    if (isCustomer && authenticatedCustomerId != null) {
      return records.where((item) => getRecordCustomerId(item) == authenticatedCustomerId).toList();
    }
    return [];
  }
}

abstract class ICustomerDataIsolationService {
  bool isRecordAccessPermitted({
    required CustomerDataScope scope,
    required String recordOwnerCustomerId,
  });

  List<T> filterListForScope<T>({
    required CustomerDataScope scope,
    required List<T> records,
    required String Function(T item) getRecordCustomerId,
  });
}

class CustomerDataIsolationService implements ICustomerDataIsolationService {
  const CustomerDataIsolationService();

  @override
  bool isRecordAccessPermitted({
    required CustomerDataScope scope,
    required String recordOwnerCustomerId,
  }) {
    return scope.canAccessRecord(recordOwnerCustomerId: recordOwnerCustomerId);
  }

  @override
  List<T> filterListForScope<T>({
    required CustomerDataScope scope,
    required List<T> records,
    required String Function(T item) getRecordCustomerId,
  }) {
    return scope.filterAccessibleRecords(records: records, getRecordCustomerId: getRecordCustomerId);
  }
}
