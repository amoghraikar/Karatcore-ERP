import '../models/kyc_model.dart';

class KycFilterParams {
  const KycFilterParams({
    this.status,
    this.level,
    this.riskStatus,
    this.method,
  });

  final KycStatus? status;
  final KycVerificationLevel? level;
  final KycRiskStatus? riskStatus;
  final KycVerificationMethod? method;

  bool get isEmpty =>
      status == null && level == null && riskStatus == null && method == null;
}

enum KycSortOption {
  submittedNewest('Submission Date (Newest)'),
  submittedOldest('Submission Date (Oldest)'),
  customerName('Customer Name (A-Z)'),
  riskHighToLow('Highest Risk'),
  statusPriority('Status Priority');

  const KycSortOption(this.label);
  final String label;
}

class KycDashboardMetrics {
  const KycDashboardMetrics({
    required this.totalRequiringKyc,
    required this.verifiedCount,
    required this.pendingReviewCount,
    required this.rejectedCount,
    required this.expiredCount,
    required this.reverificationCount,
    required this.highRiskCount,
    required this.completionRatePercent,
  });

  final int totalRequiringKyc;
  final int verifiedCount;
  final int pendingReviewCount;
  final int rejectedCount;
  final int expiredCount;
  final int reverificationCount;
  final int highRiskCount;
  final double completionRatePercent;
}

abstract class IKycRepository {
  Future<KycDashboardMetrics> getDashboardMetrics();

  Future<List<KycRecordModel>> getKycQueue({
    String? searchQuery,
    KycFilterParams? filters,
    KycSortOption? sortOption,
  });

  Future<KycRecordModel?> getKycRecordByCustomerId(String customerId);

  Future<KycRecordModel> startKycWorkflow({
    required String customerId,
    required String customerName,
    required String customerMobile,
    required String customerEmail,
    required KycVerificationMethod method,
    required KycConsentModel consent,
    required List<KycDocumentModel> documents,
  });

  Future<KycRecordModel> approveKyc({
    required String customerId,
    required String reviewerName,
    required String reviewerNotes,
    KycVerificationLevel level = KycVerificationLevel.standard,
  });

  Future<KycRecordModel> rejectKyc({
    required String customerId,
    required String reviewerName,
    required String reasonCategory,
    required String reviewerNotes,
  });

  Future<KycRecordModel> requestReverification({
    required String customerId,
    required String reviewerName,
    required String reason,
  });

  Future<KycRecordModel> toggleDocumentMasking({
    required String customerId,
    required String documentId,
  });
}
