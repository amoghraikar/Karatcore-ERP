import '../models/kyc_model.dart';
import 'kyc_repository.dart';

class MockKycRepository implements IKycRepository {
  MockKycRepository() {
    _seedData();
  }

  final List<KycRecordModel> _records = [];

  void _seedData() {
    if (_records.isNotEmpty) return;

    final now = DateTime.now();

    _records.addAll([
      KycRecordModel(
        id: 'KYC-REC-001',
        customerId: 'KC-CUS-000101',
        customerName: 'Rahul Kumar Sharma',
        customerMobile: '+91 98201 12345',
        customerEmail: 'rahul.sharma@example.com',
        status: KycStatus.verified,
        level: KycVerificationLevel.standard,
        riskStatus: KycRiskStatus.low,
        method: KycVerificationMethod.aadhaarDoc,
        submittedAt: now.subtract(const Duration(days: 120)),
        verifiedAt: now.subtract(const Duration(days: 119)),
        reviewerName: 'Arjun Mehta (Manager)',
        reviewerNotes: 'Verified original Aadhaar and PAN card at Store 01. High-trust customer.',
        consent: KycConsentModel(givenAt: now.subtract(const Duration(days: 120))),
        documents: [
          KycDocumentModel(
            id: 'DOC-101',
            type: 'Aadhaar Card',
            documentNumber: '998877668821',
            nameOnDoc: 'Rahul Kumar Sharma',
            dateOfBirth: DateTime(1985, 4, 12),
            uploadDate: now.subtract(const Duration(days: 120)),
            uploadedBy: 'Rahul Sharma',
            status: 'Approved',
            isMasked: true,
          ),
          KycDocumentModel(
            id: 'DOC-102',
            type: 'PAN Card',
            documentNumber: 'ABCPS1234F',
            nameOnDoc: 'Rahul K Sharma',
            dateOfBirth: DateTime(1985, 4, 12),
            uploadDate: now.subtract(const Duration(days: 120)),
            uploadedBy: 'Rahul Sharma',
            status: 'Approved',
            isMasked: true,
          ),
        ],
        fieldMatches: [
          const FieldMatchResult(fieldName: 'Name Match', customerValue: 'Rahul Kumar Sharma', documentValue: 'Rahul Kumar Sharma', status: FieldMatchStatus.match),
          const FieldMatchResult(fieldName: 'Date of Birth', customerValue: '12/4/1985', documentValue: '12/4/1985', status: FieldMatchStatus.match),
          const FieldMatchResult(fieldName: 'Address Verification', customerValue: 'Royal Palms, MG Road, Mumbai', documentValue: 'Royal Palms, MG Road, Mumbai', status: FieldMatchStatus.match),
        ],
        auditLogs: [
          KycAuditLog(id: 'AUD-1', timestamp: now.subtract(const Duration(days: 120)), actorName: 'Rahul Sharma', actorRole: 'Customer', action: 'Consent Recorded', description: 'Customer accepted privacy policy and identity collection terms.', affectedRecord: 'KYC-REC-001'),
          KycAuditLog(id: 'AUD-2', timestamp: now.subtract(const Duration(days: 120)), actorName: 'Rahul Sharma', actorRole: 'Customer', action: 'Document Uploaded', description: 'Aadhaar Card front and back uploaded.', affectedRecord: 'KYC-REC-001'),
          KycAuditLog(id: 'AUD-3', timestamp: now.subtract(const Duration(days: 119)), actorName: 'Arjun Mehta', actorRole: 'Manager', action: 'KYC Approved', description: 'Verified status granted at Level 2 Standard.', affectedRecord: 'KYC-REC-001'),
        ],
      ),
      KycRecordModel(
        id: 'KYC-REC-002',
        customerId: 'KC-CUS-000102',
        customerName: 'Sunita Verma',
        customerMobile: '+91 97110 54321',
        customerEmail: 'sunita.verma@domain.in',
        status: KycStatus.verified,
        level: KycVerificationLevel.standard,
        riskStatus: KycRiskStatus.low,
        method: KycVerificationMethod.panDoc,
        submittedAt: now.subtract(const Duration(days: 90)),
        verifiedAt: now.subtract(const Duration(days: 89)),
        reviewerName: 'Anil Gupta (Admin)',
        reviewerNotes: 'PAN card verified against Tax ITD database.',
        consent: KycConsentModel(givenAt: now.subtract(const Duration(days: 90))),
        documents: [
          KycDocumentModel(
            id: 'DOC-201',
            type: 'PAN Card',
            documentNumber: 'XYZPV9876K',
            nameOnDoc: 'Sunita Verma',
            dateOfBirth: DateTime(1990, 8, 24),
            uploadDate: now.subtract(const Duration(days: 90)),
            uploadedBy: 'Sunita Verma',
            status: 'Approved',
            isMasked: true,
          ),
        ],
        fieldMatches: [
          const FieldMatchResult(fieldName: 'Name Match', customerValue: 'Sunita Verma', documentValue: 'Sunita Verma', status: FieldMatchStatus.match),
          const FieldMatchResult(fieldName: 'DOB Match', customerValue: '24/8/1990', documentValue: '24/8/1990', status: FieldMatchStatus.match),
        ],
        auditLogs: [
          KycAuditLog(id: 'AUD-201', timestamp: now.subtract(const Duration(days: 90)), actorName: 'Sunita Verma', actorRole: 'Customer', action: 'Submitted for Review', description: 'PAN verification submitted.', affectedRecord: 'KYC-REC-002'),
          KycAuditLog(id: 'AUD-202', timestamp: now.subtract(const Duration(days: 89)), actorName: 'Anil Gupta', actorRole: 'Admin', action: 'KYC Approved', description: 'Verification completed.', affectedRecord: 'KYC-REC-002'),
        ],
      ),
      KycRecordModel(
        id: 'KYC-REC-003',
        customerId: 'KC-CUS-000104',
        customerName: 'Priya Patel',
        customerMobile: '+91 98980 11223',
        customerEmail: 'priya.patel94@gmail.com',
        status: KycStatus.underReview,
        level: KycVerificationLevel.standard,
        riskStatus: KycRiskStatus.medium,
        method: KycVerificationMethod.aadhaarDoc,
        submittedAt: now.subtract(const Duration(hours: 4)),
        reviewerName: 'Priya Nair (Reviewer)',
        reviewerNotes: 'Document clear. Reviewing name spelling alignment.',
        consent: KycConsentModel(givenAt: now.subtract(const Duration(hours: 5))),
        documents: [
          KycDocumentModel(
            id: 'DOC-401',
            type: 'Aadhaar Card',
            documentNumber: '554433221190',
            nameOnDoc: 'Priya D Patel',
            dateOfBirth: DateTime(1994, 2, 14),
            uploadDate: now.subtract(const Duration(hours: 4)),
            uploadedBy: 'Priya Patel',
            status: 'Pending',
            isMasked: true,
          ),
        ],
        fieldMatches: [
          const FieldMatchResult(fieldName: 'Customer Name', customerValue: 'Priya Patel', documentValue: 'Priya D Patel', status: FieldMatchStatus.partialMatch),
          const FieldMatchResult(fieldName: 'Date of Birth', customerValue: '14/2/1994', documentValue: '14/2/1994', status: FieldMatchStatus.match),
        ],
        auditLogs: [
          KycAuditLog(id: 'AUD-401', timestamp: now.subtract(const Duration(hours: 5)), actorName: 'Priya Patel', actorRole: 'Customer', action: 'Consent Recorded', description: 'Consent provided.', affectedRecord: 'KYC-REC-003'),
          KycAuditLog(id: 'AUD-402', timestamp: now.subtract(const Duration(hours: 4)), actorName: 'Priya Patel', actorRole: 'Customer', action: 'Submitted for Review', description: 'Aadhaar document submitted.', affectedRecord: 'KYC-REC-003'),
          KycAuditLog(id: 'AUD-403', timestamp: now.subtract(const Duration(hours: 1)), actorName: 'Priya Nair', actorRole: 'Reviewer', action: 'Review Started', description: 'Reviewer opened record for audit.', affectedRecord: 'KYC-REC-003'),
        ],
      ),
      KycRecordModel(
        id: 'KYC-REC-004',
        customerId: 'KC-CUS-000114',
        customerName: 'Pooja Nambiar',
        customerMobile: '+91 94470 11998',
        customerEmail: 'pooja.nambiar@cochinport.in',
        status: KycStatus.rejected,
        level: KycVerificationLevel.basic,
        riskStatus: KycRiskStatus.high,
        method: KycVerificationMethod.panDoc,
        submittedAt: now.subtract(const Duration(days: 15)),
        reviewerName: 'Compliance Officer (Admin)',
        rejectionReason: 'Information Mismatch',
        reviewerNotes: 'PAN card name mismatch. Identity check failed.',
        consent: KycConsentModel(givenAt: now.subtract(const Duration(days: 15))),
        documents: [
          KycDocumentModel(
            id: 'DOC-999',
            type: 'PAN Card',
            documentNumber: 'PJNM5678Y',
            nameOnDoc: 'Pooja K Nambiar',
            dateOfBirth: DateTime(1991, 3, 29),
            uploadDate: now.subtract(const Duration(days: 15)),
            uploadedBy: 'Pooja Nambiar',
            status: 'Rejected',
            isMasked: true,
          ),
        ],
        fieldMatches: [
          const FieldMatchResult(fieldName: 'Name Check', customerValue: 'Pooja Nambiar', documentValue: 'Pooja K Nambiar', status: FieldMatchStatus.mismatch),
        ],
        auditLogs: [
          KycAuditLog(id: 'AUD-991', timestamp: now.subtract(const Duration(days: 15)), actorName: 'Pooja Nambiar', actorRole: 'Customer', action: 'Submitted', description: 'Submitted PAN.', affectedRecord: 'KYC-REC-004'),
          KycAuditLog(id: 'AUD-992', timestamp: now.subtract(const Duration(days: 15)), actorName: 'Compliance Officer', actorRole: 'Admin', action: 'KYC Rejected', description: 'Rejected due to name mismatch.', affectedRecord: 'KYC-REC-004'),
        ],
      ),
      KycRecordModel(
        id: 'KYC-REC-005',
        customerId: 'KC-CUS-000110',
        customerName: 'Sneha Kulkarni',
        customerMobile: '+91 98220 33445',
        customerEmail: 'sneha.k@punedesign.co',
        status: KycStatus.reverificationRequired,
        level: KycVerificationLevel.basic,
        riskStatus: KycRiskStatus.medium,
        method: KycVerificationMethod.manual,
        submittedAt: now.subtract(const Duration(days: 45)),
        reviewerName: 'Deepak Patel',
        reviewerNotes: 'Address proof outdated (>3 months old). Requested fresh utility bill or Aadhaar.',
        consent: KycConsentModel(givenAt: now.subtract(const Duration(days: 45))),
        documents: [
          KycDocumentModel(
            id: 'DOC-501',
            type: 'Voter ID',
            documentNumber: 'XYZ1234567',
            nameOnDoc: 'Sneha Kulkarni',
            dateOfBirth: DateTime(1989, 10, 8),
            uploadDate: now.subtract(const Duration(days: 45)),
            uploadedBy: 'Sneha Kulkarni',
            status: 'Reverification Requested',
            isMasked: true,
          ),
        ],
        fieldMatches: [
          const FieldMatchResult(fieldName: 'Address Record', customerValue: 'Shivaji Nagar, Pune', documentValue: 'Old Address, Nagpur', status: FieldMatchStatus.mismatch),
        ],
        auditLogs: [
          KycAuditLog(id: 'AUD-501', timestamp: now.subtract(const Duration(days: 45)), actorName: 'Deepak Patel', actorRole: 'Manager', action: 'Reverification Requested', description: 'Updated address proof requested from customer.', affectedRecord: 'KYC-REC-005'),
        ],
      ),
      KycRecordModel(
        id: 'KYC-REC-006',
        customerId: 'KC-CUS-000103',
        customerName: 'Vikramaditya Singh Rathore',
        customerMobile: '+91 99887 66554',
        customerEmail: 'v.rathore@heritagejewels.co.in',
        status: KycStatus.verified,
        level: KycVerificationLevel.enhanced,
        riskStatus: KycRiskStatus.medium,
        method: KycVerificationMethod.otherGovtId,
        submittedAt: now.subtract(const Duration(days: 300)),
        verifiedAt: now.subtract(const Duration(days: 298)),
        reviewerName: 'Arjun Mehta',
        reviewerNotes: 'Enhanced Level 3 verified for high-value business pledges.',
        documents: [
          KycDocumentModel(
            id: 'DOC-301',
            type: 'GST & Passport',
            documentNumber: 'Z9876543',
            nameOnDoc: 'Vikramaditya Singh',
            dateOfBirth: DateTime(1978, 11, 30),
            uploadDate: now.subtract(const Duration(days: 300)),
            uploadedBy: 'Vikramaditya Singh',
            status: 'Approved',
            isMasked: true,
          ),
        ],
      ),
      KycRecordModel(
        id: 'KYC-REC-007',
        customerId: 'KC-CUS-000118',
        customerName: 'Divya Bhatt',
        customerMobile: '+91 98370 22110',
        customerEmail: 'divya.bhatt@rajpurtech.com',
        status: KycStatus.submitted,
        level: KycVerificationLevel.basic,
        riskStatus: KycRiskStatus.low,
        method: KycVerificationMethod.digiLocker,
        submittedAt: now.subtract(const Duration(hours: 2)),
        documents: [
          KycDocumentModel(
            id: 'DOC-601',
            type: 'DigiLocker Identity',
            documentNumber: 'DL-99881122',
            nameOnDoc: 'Divya Bhatt',
            dateOfBirth: DateTime(1993, 1, 15),
            uploadDate: now.subtract(const Duration(hours: 2)),
            uploadedBy: 'Divya Bhatt',
            status: 'Submitted',
            isMasked: true,
          ),
        ],
      ),
      KycRecordModel(
        id: 'KYC-REC-008',
        customerId: 'KC-CUS-000105',
        customerName: 'Amitabh Banerjee',
        customerMobile: '+91 98300 44556',
        customerEmail: 'amitabh.banerjee@kolkatabiz.net',
        status: KycStatus.expired,
        level: KycVerificationLevel.standard,
        riskStatus: KycRiskStatus.low,
        method: KycVerificationMethod.aadhaarDoc,
        submittedAt: now.subtract(const Duration(days: 730)),
        verifiedAt: now.subtract(const Duration(days: 729)),
        reviewerName: 'Anil Gupta',
        reviewerNotes: 'Validity expired after 2 years. Annual review due.',
      ),
    ]);
  }

  @override
  Future<KycDashboardMetrics> getDashboardMetrics() async {
    await Future.delayed(const Duration(milliseconds: 200));

    final total = _records.length;
    final verified = _records.where((r) => r.status == KycStatus.verified).length;
    final pending = _records.where((r) => r.status == KycStatus.submitted || r.status == KycStatus.underReview).length;
    final rejected = _records.where((r) => r.status == KycStatus.rejected).length;
    final expired = _records.where((r) => r.status == KycStatus.expired).length;
    final reverification = _records.where((r) => r.status == KycStatus.reverificationRequired).length;
    final highRisk = _records.where((r) => r.riskStatus == KycRiskStatus.high).length;
    final rate = total > 0 ? (verified / total) * 100.0 : 0.0;

    return KycDashboardMetrics(
      totalRequiringKyc: total,
      verifiedCount: verified,
      pendingReviewCount: pending,
      rejectedCount: rejected,
      expiredCount: expired,
      reverificationCount: reverification,
      highRiskCount: highRisk,
      completionRatePercent: rate,
    );
  }

  @override
  Future<List<KycRecordModel>> getKycQueue({
    String? searchQuery,
    KycFilterParams? filters,
    KycSortOption? sortOption,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    Iterable<KycRecordModel> result = List.of(_records);

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      result = result.where((r) {
        return r.customerName.toLowerCase().contains(q) ||
            r.customerId.toLowerCase().contains(q) ||
            r.id.toLowerCase().contains(q) ||
            r.customerMobile.contains(q) ||
            r.customerEmail.toLowerCase().contains(q);
      });
    }

    if (filters != null) {
      if (filters.status != null) {
        result = result.where((r) => r.status == filters.status);
      }
      if (filters.level != null) {
        result = result.where((r) => r.level == filters.level);
      }
      if (filters.riskStatus != null) {
        result = result.where((r) => r.riskStatus == filters.riskStatus);
      }
      if (filters.method != null) {
        result = result.where((r) => r.method == filters.method);
      }
    }

    final list = result.toList();
    final sort = sortOption ?? KycSortOption.submittedNewest;

    switch (sort) {
      case KycSortOption.submittedNewest:
        list.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
        break;
      case KycSortOption.submittedOldest:
        list.sort((a, b) => a.submittedAt.compareTo(b.submittedAt));
        break;
      case KycSortOption.customerName:
        list.sort((a, b) => a.customerName.compareTo(b.customerName));
        break;
      case KycSortOption.riskHighToLow:
        list.sort((a, b) => b.riskStatus.index.compareTo(a.riskStatus.index));
        break;
      case KycSortOption.statusPriority:
        list.sort((a, b) => a.status.index.compareTo(b.status.index));
        break;
    }

    return list;
  }

  @override
  Future<KycRecordModel?> getKycRecordByCustomerId(String customerId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _records.firstWhere((r) => r.customerId == customerId);
    } catch (_) {
      // Create a default Not Started record if none exists
      return KycRecordModel(
        id: 'KYC-NEW-${DateTime.now().millisecondsSinceEpoch}',
        customerId: customerId,
        customerName: 'Customer $customerId',
        customerMobile: '+91 98000 00000',
        customerEmail: 'customer@karatcore.com',
        status: KycStatus.notStarted,
        level: KycVerificationLevel.basic,
        riskStatus: KycRiskStatus.reviewRequired,
        method: KycVerificationMethod.manual,
        submittedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<KycRecordModel> startKycWorkflow({
    required String customerId,
    required String customerName,
    required String customerMobile,
    required String customerEmail,
    required KycVerificationMethod method,
    required KycConsentModel consent,
    required List<KycDocumentModel> documents,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _records.indexWhere((r) => r.customerId == customerId);

    final now = DateTime.now();
    final newLogs = [
      KycAuditLog(id: 'AUD-${now.millisecondsSinceEpoch}-1', timestamp: now, actorName: customerName, actorRole: 'Customer', action: 'Consent Recorded', description: 'Customer accepted identity terms version ${consent.version}.', affectedRecord: customerId),
      KycAuditLog(id: 'AUD-${now.millisecondsSinceEpoch}-2', timestamp: now, actorName: customerName, actorRole: 'Customer', action: 'Submitted for Review', description: 'KYC documents submitted via ${method.label}.', affectedRecord: customerId),
    ];

    final record = KycRecordModel(
      id: 'KYC-REC-${100 + _records.length + 1}',
      customerId: customerId,
      customerName: customerName,
      customerMobile: customerMobile,
      customerEmail: customerEmail,
      status: KycStatus.submitted,
      level: KycVerificationLevel.standard,
      riskStatus: KycRiskStatus.low,
      method: method,
      submittedAt: now,
      consent: consent,
      documents: documents,
      auditLogs: newLogs,
    );

    if (index != -1) {
      _records[index] = record;
    } else {
      _records.insert(0, record);
    }
    return record;
  }

  @override
  Future<KycRecordModel> approveKyc({
    required String customerId,
    required String reviewerName,
    required String reviewerNotes,
    KycVerificationLevel level = KycVerificationLevel.standard,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _records.indexWhere((r) => r.customerId == customerId);
    if (index != -1) {
      final existing = _records[index];
      final now = DateTime.now();
      final updatedLogs = List<KycAuditLog>.from(existing.auditLogs);
      updatedLogs.insert(0, KycAuditLog(id: 'AUD-${now.millisecondsSinceEpoch}', timestamp: now, actorName: reviewerName, actorRole: 'Compliance Officer', action: 'KYC Approved', description: 'Approved at ${level.label}. Notes: $reviewerNotes', affectedRecord: customerId));

      final updated = existing.copyWith(
        status: KycStatus.verified,
        level: level,
        verifiedAt: now,
        reviewerName: reviewerName,
        reviewerNotes: reviewerNotes,
        auditLogs: updatedLogs,
      );
      _records[index] = updated;
      return updated;
    }
    throw Exception('KYC record not found');
  }

  @override
  Future<KycRecordModel> rejectKyc({
    required String customerId,
    required String reviewerName,
    required String reasonCategory,
    required String reviewerNotes,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _records.indexWhere((r) => r.customerId == customerId);
    if (index != -1) {
      final existing = _records[index];
      final now = DateTime.now();
      final updatedLogs = List<KycAuditLog>.from(existing.auditLogs);
      updatedLogs.insert(0, KycAuditLog(id: 'AUD-${now.millisecondsSinceEpoch}', timestamp: now, actorName: reviewerName, actorRole: 'Compliance Officer', action: 'KYC Rejected', description: 'Reason: $reasonCategory. Notes: $reviewerNotes', affectedRecord: customerId));

      final updated = existing.copyWith(
        status: KycStatus.rejected,
        reviewerName: reviewerName,
        rejectionReason: reasonCategory,
        reviewerNotes: reviewerNotes,
        auditLogs: updatedLogs,
      );
      _records[index] = updated;
      return updated;
    }
    throw Exception('KYC record not found');
  }

  @override
  Future<KycRecordModel> requestReverification({
    required String customerId,
    required String reviewerName,
    required String reason,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _records.indexWhere((r) => r.customerId == customerId);
    if (index != -1) {
      final existing = _records[index];
      final now = DateTime.now();
      final updatedLogs = List<KycAuditLog>.from(existing.auditLogs);
      updatedLogs.insert(0, KycAuditLog(id: 'AUD-${now.millisecondsSinceEpoch}', timestamp: now, actorName: reviewerName, actorRole: 'Compliance Officer', action: 'Reverification Requested', description: 'Reverification requested: $reason', affectedRecord: customerId));

      final updated = existing.copyWith(
        status: KycStatus.reverificationRequired,
        reviewerName: reviewerName,
        reviewerNotes: reason,
        auditLogs: updatedLogs,
      );
      _records[index] = updated;
      return updated;
    }
    throw Exception('KYC record not found');
  }

  @override
  Future<KycRecordModel> toggleDocumentMasking({
    required String customerId,
    required String documentId,
  }) async {
    final index = _records.indexWhere((r) => r.customerId == customerId);
    if (index != -1) {
      final existing = _records[index];
      final updatedDocs = existing.documents.map((doc) {
        if (doc.id == documentId) {
          return doc.copyWith(isMasked: !doc.isMasked);
        }
        return doc;
      }).toList();

      final updated = existing.copyWith(documents: updatedDocs);
      _records[index] = updated;
      return updated;
    }
    throw Exception('KYC record not found');
  }
}
