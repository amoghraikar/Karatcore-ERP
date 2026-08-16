import '../models/customer_model.dart';

class CustomerFilterParams {
  const CustomerFilterParams({
    this.kycStatus,
    this.customerStatus,
    this.hasActiveLoans,
    this.customerType,
    this.riskLevel,
  });

  final CustomerKycStatus? kycStatus;
  final CustomerStatus? customerStatus;
  final bool? hasActiveLoans;
  final CustomerType? customerType;
  final CustomerRiskLevel? riskLevel;

  bool get isEmpty =>
      kycStatus == null &&
      customerStatus == null &&
      hasActiveLoans == null &&
      customerType == null &&
      riskLevel == null;
}

enum CustomerSortOption {
  nameAsc('Name (A-Z)'),
  nameDesc('Name (Z-A)'),
  newest('Newest Customer'),
  oldest('Oldest Customer'),
  outstandingDesc('Highest Outstanding'),
  activeLoansDesc('Most Active Loans'),
  lastActivity('Recent Activity'),
  riskLevel('Highest Risk');

  const CustomerSortOption(this.label);
  final String label;
}

abstract class ICustomerRepository {
  Future<List<CustomerModel>> getCustomers({
    String? searchQuery,
    CustomerFilterParams? filters,
    CustomerSortOption? sortOption,
  });

  Future<CustomerModel?> getCustomerById(String id);

  Future<CustomerModel> createCustomer(CustomerModel newCustomer);

  Future<CustomerModel> updateCustomer(CustomerModel updatedCustomer);

  Future<CustomerModel> updateCustomerStatus(String id, CustomerStatus status);

  Future<CustomerModel> updateCustomerKycStatus(String id, CustomerKycStatus status, {List<CustomerDocument>? documents});

  Future<CustomerModel> archiveCustomer(String id);

  Future<CustomerModel> restoreCustomer(String id);

  Future<CustomerModel> addCustomerNote(String customerId, String noteContent, String authorName);

  Future<CustomerModel> togglePinCustomerNote(String customerId, String noteId);

  Future<CustomerModel> deleteCustomerNote(String customerId, String noteId);
}
