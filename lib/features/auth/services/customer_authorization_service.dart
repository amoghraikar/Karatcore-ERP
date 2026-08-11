import '../models/customer_session_model.dart';

abstract class ICustomerAuthorizationService {
  bool canAccessCustomerArea(CustomerSession? session);

  bool canAccessCustomerRecord({
    required String? authenticatedCustomerId,
    required String targetCustomerId,
  });

  bool canAccessResource({
    required String? authenticatedCustomerId,
    required String resourceCustomerId,
  });
}

class CustomerAuthorizationService implements ICustomerAuthorizationService {
  const CustomerAuthorizationService();

  @override
  bool canAccessCustomerArea(CustomerSession? session) {
    return session != null && session.authenticated && session.customerId.isNotEmpty;
  }

  @override
  bool canAccessCustomerRecord({
    required String? authenticatedCustomerId,
    required String targetCustomerId,
  }) {
    if (authenticatedCustomerId == null || authenticatedCustomerId.isEmpty) {
      return false;
    }
    return authenticatedCustomerId == targetCustomerId;
  }

  @override
  bool canAccessResource({
    required String? authenticatedCustomerId,
    required String resourceCustomerId,
  }) {
    if (authenticatedCustomerId == null || authenticatedCustomerId.isEmpty) {
      return false;
    }
    return authenticatedCustomerId == resourceCustomerId;
  }
}
