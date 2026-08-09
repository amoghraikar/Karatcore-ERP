import 'package:flutter_test/flutter_test.dart';
import 'package:karatcore_erp/features/kyc/models/kyc_model.dart';
import 'package:karatcore_erp/features/kyc/repository/kyc_repository.dart';
import 'package:karatcore_erp/features/kyc/repository/mock_kyc_repository.dart';
import 'package:karatcore_erp/features/kyc/services/kyc_verification_service.dart';

void main() {
  group('KYC & Trust Layer Domain & Repository Tests', () {
    late IKycRepository repo;
    late IKycVerificationService service;

    setUp(() {
      repo = MockKycRepository();
      service = MockKycVerificationService();
    });

    test('MockKycRepository seeds 8 initial KYC records', () async {
      final queue = await repo.getKycQueue();
      expect(queue.length, greaterThanOrEqualTo(8));
    });

    test('getDashboardMetrics calculates correct metrics', () async {
      final metrics = await repo.getDashboardMetrics();
      expect(metrics.totalRequiringKyc, greaterThanOrEqualTo(8));
      expect(metrics.verifiedCount, greaterThanOrEqualTo(2));
      expect(metrics.completionRatePercent, greaterThan(0));
    });

    test('Filtering KYC Queue by KycStatus returns matching records', () async {
      final verifiedQueue = await repo.getKycQueue(
        filters: const KycFilterParams(status: KycStatus.verified),
      );
      expect(verifiedQueue.every((r) => r.status == KycStatus.verified), isTrue);
    });

    test('Searching KYC Queue by name returns matched records', () async {
      final results = await repo.getKycQueue(searchQuery: 'Rahul');
      expect(results.isNotEmpty, isTrue);
      expect(results.first.customerName, contains('Rahul'));
    });

    test('MockKycVerificationService field matching identifies exact and partial matches', () async {
      final matches = await service.performMockFieldMatching(
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

    test('approveKyc updates status to verified and adds audit log', () async {
      final updated = await repo.approveKyc(
        customerId: 'KC-CUS-000104',
        reviewerName: 'Test Auditor',
        reviewerNotes: 'Approved in unit test',
      );

      expect(updated.status, equals(KycStatus.verified));
      expect(updated.reviewerName, equals('Test Auditor'));
      expect(updated.auditLogs.first.action, equals('KYC Approved'));
    });

    test('rejectKyc updates status to rejected with reason category', () async {
      final rejected = await repo.rejectKyc(
        customerId: 'KC-CUS-000101',
        reviewerName: 'Test Auditor',
        reasonCategory: 'Invalid Document',
        reviewerNotes: 'Document blur in unit test',
      );

      expect(rejected.status, equals(KycStatus.rejected));
      expect(rejected.rejectionReason, equals('Invalid Document'));
    });

    test('toggleDocumentMasking flips isMasked flag', () async {
      final record = await repo.getKycRecordByCustomerId('KC-CUS-000101');
      expect(record, isNotNull);
      final doc = record!.documents.first;
      final initialMasked = doc.isMasked;

      final updated = await repo.toggleDocumentMasking(
        customerId: 'KC-CUS-000101',
        documentId: doc.id,
      );

      expect(updated.documents.first.isMasked, equals(!initialMasked));
    });
  });
}
