import 'package:flutter_test/flutter_test.dart';
import 'package:karatcore_erp/features/customers/models/customer_model.dart';
import 'package:karatcore_erp/features/customers/repository/customer_repository.dart';
import 'package:karatcore_erp/features/customers/repository/mock_customer_repository.dart';

void main() {
  group('MockCustomerRepository Tests', () {
    late MockCustomerRepository repo;

    setUp(() {
      repo = MockCustomerRepository();
    });

    test('getCustomers returns initial seeded list of 20 customers', () async {
      final customers = await repo.getCustomers();
      expect(customers.length, greaterThanOrEqualTo(20));
    });

    test('searchCustomers filters by name correctly', () async {
      final results = await repo.getCustomers(searchQuery: 'Rahul');
      expect(results.any((c) => c.firstName == 'Rahul'), isTrue);
    });

    test('searchCustomers filters by customer ID correctly', () async {
      final results = await repo.getCustomers(searchQuery: 'KC-CUS-000101');
      expect(results.length, equals(1));
      expect(results.first.id, equals('KC-CUS-000101'));
    });

    test('getCustomers with KYC status filter returns matching items', () async {
      final verifiedOnly = await repo.getCustomers(
        filters: const CustomerFilterParams(kycStatus: CustomerKycStatus.verified),
      );
      expect(verifiedOnly.every((c) => c.kycStatus == CustomerKycStatus.verified), isTrue);
    });

    test('createCustomer inserts a new customer with auto-generated ID', () async {
      final newCustomer = CustomerModel(
        id: '',
        firstName: 'TestFirst',
        lastName: 'TestLast',
        dateOfBirth: DateTime(1990, 1, 1),
        gender: 'Male',
        customerType: CustomerType.individual,
        mobile: '+91 99999 88888',
        email: 'test@example.com',
        addressLine: '123 Test Street',
        city: 'TestCity',
        state: 'TestState',
        pincode: '123456',
        occupation: 'Tester',
        annualIncome: '100000',
        kycStatus: CustomerKycStatus.pending,
        customerStatus: CustomerStatus.active,
        riskStatus: CustomerRiskLevel.low,
        createdAt: DateTime.now(),
        lastActivityAt: DateTime.now(),
      );

      final created = await repo.createCustomer(newCustomer);
      expect(created.id, startsWith('KC-CUS-'));
      expect(created.firstName, equals('TestFirst'));

      final fetched = await repo.getCustomerById(created.id);
      expect(fetched, isNotNull);
      expect(fetched!.id, equals(created.id));
    });

    test('archiveCustomer updates status to archived', () async {
      final updated = await repo.archiveCustomer('KC-CUS-000101');
      expect(updated.customerStatus, equals(CustomerStatus.archived));
    });

    test('addCustomerNote appends internal note', () async {
      final updated = await repo.addCustomerNote('KC-CUS-000101', 'Test staff note content', 'Staff Agent');
      expect(updated.notes.any((n) => n.content == 'Test staff note content'), isTrue);
    });
  });
}
