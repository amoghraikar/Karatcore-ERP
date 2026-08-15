import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/customer_model.dart';
import 'customer_repository.dart';

class ApiCustomerRepository implements ICustomerRepository {
  ApiCustomerRepository(this._api);

  final ApiClient _api;
  final List<CustomerModel> _localCustomers = [];

  @override
  Future<List<CustomerModel>> getCustomers({
    String? searchQuery,
    CustomerFilterParams? filters,
    CustomerSortOption? sortOption,
  }) async {
    try {
      final dynamic data = await _api.get(
        '${ApiEndpoints.customers}?search=${Uri.encodeComponent(searchQuery ?? '')}',
      );
      final remote = _parseCustomersFromJson(data as List);
      return [...remote, ..._localCustomers];
    } catch (_) {
      return List.from(_localCustomers);
    }
  }

  @override
  Future<CustomerModel?> getCustomerById(String id) async {
    try {
      final dynamic data = await _api.get('${ApiEndpoints.customerById}$id');
      return _parseCustomerFromJson(data);
    } catch (_) {
      final found = _localCustomers.where((c) => c.id == id);
      return found.isNotEmpty ? found.first : null;
    }
  }

  @override
  Future<CustomerModel> createCustomer(CustomerModel newCustomer) async {
    final generatedId = newCustomer.id.isNotEmpty
        ? newCustomer.id
        : 'KC-CUS-${(100100 + _localCustomers.length + 1).toString()}';
    final savedCust = newCustomer.copyWith(id: generatedId);

    try {
      final dynamic data = await _api.post(
        ApiEndpoints.customers,
        body: _customerToJson(savedCust),
      );
      final created = _parseCustomerFromJson(data);
      _localCustomers.add(created);
      return created;
    } catch (_) {
      _localCustomers.add(savedCust);
      return savedCust;
    }
  }

  @override
  Future<CustomerModel> updateCustomer(CustomerModel updatedCustomer) async {
    final dynamic data = await _api.put(
      '${ApiEndpoints.customerById}${updatedCustomer.id}',
      body: _customerToJson(updatedCustomer),
    );
    return _parseCustomerFromJson(data);
  }

  @override
  Future<CustomerModel> updateCustomerStatus(String id, CustomerStatus status) async {
    try {
      final dynamic data = await _api.post(
        '${ApiEndpoints.customerById}$id/status',
        body: {'status': status.name},
      );
      return _parseCustomerFromJson(data);
    } catch (_) {
      final index = _localCustomers.indexWhere((c) => c.id == id);
      if (index != -1) {
        final updated = _localCustomers[index].copyWith(customerStatus: status);
        _localCustomers[index] = updated;
        return updated;
      }
      throw Exception('Customer not found');
    }
  }

  @override
  Future<CustomerModel> updateCustomerKycStatus(String id, CustomerKycStatus status) async {
    try {
      final dynamic data = await _api.post(
        '${ApiEndpoints.customerById}$id/kyc-status',
        body: {'kyc_status': status.name},
      );
      return _parseCustomerFromJson(data);
    } catch (_) {
      final index = _localCustomers.indexWhere((c) => c.id == id);
      if (index != -1) {
        final updated = _localCustomers[index].copyWith(kycStatus: status);
        _localCustomers[index] = updated;
        return updated;
      }
      throw Exception('Customer not found');
    }
  }

  @override
  Future<CustomerModel> archiveCustomer(String id) async {
    final dynamic data = await _api.post(
      '${ApiEndpoints.customerById}$id/archive',
      body: {},
    );
    return _parseCustomerFromJson(data);
  }

  @override
  Future<CustomerModel> restoreCustomer(String id) async {
    final dynamic data = await _api.post(
      '${ApiEndpoints.customerById}$id/restore',
      body: {},
    );
    return _parseCustomerFromJson(data);
  }

  @override
  Future<CustomerModel> addCustomerNote(String customerId, String noteContent, String authorName) async {
    final dynamic data = await _api.post(
      '${ApiEndpoints.customerById}$customerId/notes',
      body: {'content': noteContent, 'authorName': authorName},
    );
    return _parseCustomerFromJson(data);
  }

  @override
  Future<CustomerModel> togglePinCustomerNote(String customerId, String noteId) async {
    final dynamic data = await _api.put(
      '${ApiEndpoints.customerById}$customerId/notes/$noteId/toggle-pin',
      body: {},
    );
    return _parseCustomerFromJson(data);
  }

  @override
  Future<CustomerModel> deleteCustomerNote(String customerId, String noteId) async {
    final dynamic data = await _api.delete(
      '${ApiEndpoints.customerById}$customerId/notes/$noteId',
    );
    return _parseCustomerFromJson(data);
  }

  List<CustomerModel> _parseCustomersFromJson(List data) {
    return data.map((json) => _parseCustomerFromJson(json as Map<String, dynamic>)).toList();
  }

  CustomerModel _parseCustomerFromJson(Map<String, dynamic> json) {
    final fullName = json['full_name'] as String? ?? '';
    final nameParts = fullName.trim().split(RegExp(r'\s+'));
    final defaultFirst = nameParts.isNotEmpty ? nameParts.first : 'Customer';
    final defaultLast = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    final rawFirst = json['first_name'] as String? ?? '';
    final rawLast = json['last_name'] as String? ?? '';

    return CustomerModel(
      id: json['id'] as String? ?? json['customer_code'] as String? ?? 'CUST-${DateTime.now().millisecondsSinceEpoch}',
      firstName: rawFirst.isNotEmpty ? rawFirst : defaultFirst,
      lastName: rawLast.isNotEmpty ? rawLast : defaultLast,
      dateOfBirth: DateTime.tryParse(json['date_of_birth'] as String? ?? '') ?? DateTime.now(),
      gender: json['gender'] as String? ?? 'Male',
      customerType: CustomerType.values.firstWhere(
        (e) => e.name.toLowerCase() == (json['customer_type'] as String? ?? '').toLowerCase(),
        orElse: () => CustomerType.individual,
      ),
      mobile: json['mobile'] as String? ?? json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      addressLine: json['address_line'] as String? ?? json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      pincode: json['pincode'] as String? ?? '',
      occupation: json['occupation'] as String? ?? '',
      annualIncome: json['annual_income'] as String? ?? '',
      kycStatus: CustomerKycStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == (json['kyc_status'] as String? ?? '').toLowerCase(),
        orElse: () => CustomerKycStatus.verified,
      ),
      customerStatus: CustomerStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == (json['customer_status'] as String? ?? json['status'] as String? ?? '').toLowerCase(),
        orElse: () => CustomerStatus.active,
      ),
      riskStatus: CustomerRiskLevel.values.firstWhere(
        (e) => e.name.toLowerCase() == (json['risk_status'] as String? ?? '').toLowerCase(),
        orElse: () => CustomerRiskLevel.low,
      ),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      lastActivityAt: DateTime.tryParse(json['last_activity_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> _customerToJson(CustomerModel customer) {
    return {
      'id': customer.id,
      'first_name': customer.firstName,
      'last_name': customer.lastName,
      'full_name': customer.fullName,
      'date_of_birth': customer.dateOfBirth.toIso8601String(),
      'gender': customer.gender,
      'mobile': customer.mobile,
      'email': customer.email,
    };
  }
}
