import 'package:flutter/material.dart';

enum KycStatus {
  notStarted('Not Started', Icons.circle_outlined, Color(0xFF6B7280), 'No identity verification initiated yet.'),
  inProgress('In Progress', Icons.hourglass_top_rounded, Color(0xFFD97706), 'Customer is currently completing verification steps.'),
  submitted('Submitted', Icons.send_rounded, Color(0xFF2563EB), 'KYC documents submitted and awaiting staff review.'),
  underReview('Under Review', Icons.rate_review_rounded, Color(0xFF8B5CF6), 'Compliance reviewer is actively verifying documents.'),
  verified('Verified', Icons.verified_rounded, Color(0xFF059669), 'Identity and documents successfully verified.'),
  rejected('Rejected', Icons.cancel_rounded, Color(0xFFDC2626), 'KYC verification failed or rejected by reviewer.'),
  expired('Expired', Icons.history_toggle_off_rounded, Color(0xFFEA580C), 'Verification validity period has expired.'),
  reverificationRequired('Reverification Required', Icons.published_with_changes_rounded, Color(0xFFD97706), 'Updated identity or address proof requested.'),
  suspended('Suspended', Icons.block_rounded, Color(0xFF991B1B), 'Account compliance suspended due to risk flag.');

  const KycStatus(this.label, this.icon, this.color, this.description);
  final String label;
  final IconData icon;
  final Color color;
  final String description;
}

enum KycVerificationLevel {
  basic('Basic Level 1', 'Primary phone & identity confirmation'),
  standard('Standard Level 2', 'Aadhaar / PAN government identity verification'),
  enhanced('Enhanced Level 3', 'High-value bullion & store pledge audit compliance');

  const KycVerificationLevel(this.label, this.description);
  final String label;
  final String description;
}

enum KycRiskStatus {
  low('Low Risk', Icons.shield_outlined, Color(0xFF059669)),
  medium('Medium Risk', Icons.warning_amber_rounded, Color(0xFFD97706)),
  high('High Risk', Icons.gpp_bad_rounded, Color(0xFFDC2626)),
  reviewRequired('Review Required', Icons.help_outline_rounded, Color(0xFF8B5CF6));

  const KycRiskStatus(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color color;
}

enum KycVerificationMethod {
  digiLocker('DigiLocker Digital KYC', Icons.cloud_done_rounded, 'Instant paperless digital verification (Placeholder)'),
  aadhaarDoc('Aadhaar Physical Card', Icons.badge_rounded, 'Front & back upload with masked UIDAI number'),
  panDoc('PAN Card Verification', Icons.credit_card_rounded, 'Income tax identity verification'),
  otherGovtId('Other Government ID', Icons.assignment_ind_rounded, 'Passport / Voter ID / Driving License'),
  manual('Manual Physical Verification', Icons.fact_check_rounded, 'In-store physical document verification');

  const KycVerificationMethod(this.label, this.icon, this.description);
  final String label;
  final IconData icon;
  final String description;
}

enum FieldMatchStatus {
  match('Match', Icons.check_circle_rounded, Color(0xFF059669)),
  partialMatch('Partial Match', Icons.error_outline_rounded, Color(0xFFD97706)),
  mismatch('Mismatch', Icons.cancel_rounded, Color(0xFFDC2626)),
  notAvailable('N/A', Icons.remove_circle_outline_rounded, Color(0xFF6B7280));

  const FieldMatchStatus(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color color;
}

class FieldMatchResult {
  const FieldMatchResult({
    required this.fieldName,
    required this.customerValue,
    required this.documentValue,
    required this.status,
  });

  final String fieldName;
  final String customerValue;
  final String documentValue;
  final FieldMatchStatus status;
}

class KycDocumentModel {
  const KycDocumentModel({
    required this.id,
    required this.type,
    required this.documentNumber,
    required this.nameOnDoc,
    required this.dateOfBirth,
    this.issueDate,
    this.expiryDate,
    required this.uploadDate,
    required this.uploadedBy,
    required this.status,
    this.fileSize = '1.4 MB',
    this.frontUrl,
    this.backUrl,
    this.isMasked = true,
  });

  final String id;
  final String type; // Aadhaar, PAN, Passport, Driving License
  String get name => type;
  final String documentNumber;
  final String nameOnDoc;
  final DateTime dateOfBirth;
  final DateTime? issueDate;
  final DateTime? expiryDate;
  final DateTime uploadDate;
  final String uploadedBy;
  final String status; // Approved, Pending, Rejected
  final String fileSize;
  final String? frontUrl;
  final String? backUrl;
  final bool isMasked;

  String get maskedDocumentNumber {
    if (!isMasked || documentNumber.length <= 4) return documentNumber;
    final visiblePart = documentNumber.substring(documentNumber.length - 4);
    return 'XXXX-XXXX-$visiblePart';
  }

  KycDocumentModel copyWith({
    String? id,
    String? type,
    String? documentNumber,
    String? nameOnDoc,
    DateTime? dateOfBirth,
    DateTime? issueDate,
    DateTime? expiryDate,
    DateTime? uploadDate,
    String? uploadedBy,
    String? status,
    String? fileSize,
    String? frontUrl,
    String? backUrl,
    bool? isMasked,
  }) {
    return KycDocumentModel(
      id: id ?? this.id,
      type: type ?? this.type,
      documentNumber: documentNumber ?? this.documentNumber,
      nameOnDoc: nameOnDoc ?? this.nameOnDoc,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      issueDate: issueDate ?? this.issueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      uploadDate: uploadDate ?? this.uploadDate,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      status: status ?? this.status,
      fileSize: fileSize ?? this.fileSize,
      frontUrl: frontUrl ?? this.frontUrl,
      backUrl: backUrl ?? this.backUrl,
      isMasked: isMasked ?? this.isMasked,
    );
  }
}

class KycConsentModel {
  const KycConsentModel({
    required this.givenAt,
    this.version = 'v2.4-2026',
    this.ipAddress = '192.168.1.1',
    this.acceptedTerms = true,
    this.acceptedPrivacy = true,
  });

  final DateTime givenAt;
  final String version;
  final String ipAddress;
  final bool acceptedTerms;
  final bool acceptedPrivacy;
}

class KycAuditLog {
  const KycAuditLog({
    required this.id,
    required this.timestamp,
    required this.actorName,
    required this.actorRole,
    required this.action,
    required this.description,
    required this.affectedRecord,
    this.ipPlaceholder = '192.168.1.45',
    this.devicePlaceholder = 'KaratCore ERP Terminal #01',
  });

  final String id;
  final DateTime timestamp;
  final String actorName;
  final String actorRole;
  final String action;
  final String description;
  final String affectedRecord;
  final String ipPlaceholder;
  final String devicePlaceholder;
}

class KycRecordModel {
  const KycRecordModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerMobile,
    required this.customerEmail,
    required this.status,
    required this.level,
    required this.riskStatus,
    required this.method,
    required this.submittedAt,
    this.verifiedAt,
    this.reviewerName,
    this.rejectionReason,
    this.reviewerNotes,
    this.consent,
    this.documents = const [],
    this.fieldMatches = const [],
    this.auditLogs = const [],
  });

  final String id;
  final String customerId;
  final String customerName;
  final String customerMobile;
  final String customerEmail;
  final KycStatus status;
  final KycVerificationLevel level;
  final KycRiskStatus riskStatus;
  final KycVerificationMethod method;
  final DateTime submittedAt;
  final DateTime? verifiedAt;
  final String? reviewerName;
  final String? rejectionReason;
  final String? reviewerNotes;
  final KycConsentModel? consent;
  final List<KycDocumentModel> documents;
  final List<FieldMatchResult> fieldMatches;
  final List<KycAuditLog> auditLogs;

  KycRecordModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerMobile,
    String? customerEmail,
    KycStatus? status,
    KycVerificationLevel? level,
    KycRiskStatus? riskStatus,
    KycVerificationMethod? method,
    DateTime? submittedAt,
    DateTime? verifiedAt,
    String? reviewerName,
    String? rejectionReason,
    String? reviewerNotes,
    KycConsentModel? consent,
    List<KycDocumentModel>? documents,
    List<FieldMatchResult>? fieldMatches,
    List<KycAuditLog>? auditLogs,
  }) {
    return KycRecordModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerMobile: customerMobile ?? this.customerMobile,
      customerEmail: customerEmail ?? this.customerEmail,
      status: status ?? this.status,
      level: level ?? this.level,
      riskStatus: riskStatus ?? this.riskStatus,
      method: method ?? this.method,
      submittedAt: submittedAt ?? this.submittedAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      reviewerName: reviewerName ?? this.reviewerName,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      reviewerNotes: reviewerNotes ?? this.reviewerNotes,
      consent: consent ?? this.consent,
      documents: documents ?? this.documents,
      fieldMatches: fieldMatches ?? this.fieldMatches,
      auditLogs: auditLogs ?? this.auditLogs,
    );
  }
}
