import 'package:flutter_test/flutter_test.dart';
import 'package:karatcore_erp/features/customers/models/customer_model.dart';

void main() {
  group('Customer Model Unit Tests', () {
    test('CustomerModel initializes properly', () {
      final customer = CustomerModel(
        id: 'KC-CUS-001',
        firstName: 'Rajesh',
        lastName: 'Sharma',
        dateOfBirth: DateTime(1985, 4, 12),
        gender: 'Male',
        customerType: CustomerType.individual,
        mobile: '+91 98200 12345',
        email: 'rajesh@example.com',
        addressLine: '12 MG Road',
        city: 'New Delhi',
        state: 'Delhi',
        pincode: '110001',
        occupation: 'Business',
        annualIncome: '1200000',
        kycStatus: CustomerKycStatus.verified,
        customerStatus: CustomerStatus.active,
        riskStatus: CustomerRiskLevel.low,
        createdAt: DateTime.now(),
        lastActivityAt: DateTime.now(),
      );

      expect(customer.fullName, equals('Rajesh Sharma'));
      expect(customer.kycStatus, equals(CustomerKycStatus.verified));
      expect(customer.customerStatus, equals(CustomerStatus.active));
    });
  });
}
