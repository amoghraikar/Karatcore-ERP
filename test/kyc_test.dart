import 'package:flutter_test/flutter_test.dart';
import 'package:karatcore_erp/features/kyc/models/kyc_model.dart';
import 'package:karatcore_erp/features/kyc/services/kyc_verification_service.dart';

void main() {
  group('KYC & Trust Layer Domain & Service Tests', () {
    late IKycVerificationService service;

    setUp(() {
      service = KycVerificationService();
    });

    test('KycVerificationService field matching identifies exact and partial matches', () async {
      final matches = await service.performFieldMatching(
        customerName: 'Rahul Kumar Sharma',
        customerDob: DateTime(1985, 4, 12),
        customerAddress: 'Mumbai',
        document: KycDocumentModel(
          id: 'DOC-1',
          type: 'Aadhaar',
          documentNumber: '998877665544',
          nameOnDoc: 'Rahul Kumar Sharma',
          dateOfBirth: DateTime(1985, 4, 12),
          uploadDate: DateTime.now(),
          uploadedBy: 'Test',
          status: 'Approved',
        ),
      );

      expect(matches.length, equals(3));
      expect(matches.first.status, equals(FieldMatchStatus.match));
    });
  });
}
