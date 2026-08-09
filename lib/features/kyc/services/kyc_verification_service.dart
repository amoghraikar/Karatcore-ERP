import '../models/kyc_model.dart';

abstract class IKycVerificationService {
  Future<bool> checkDigitalIdentityStatus(String documentNumber, KycVerificationMethod method);

  Future<List<FieldMatchResult>> performMockFieldMatching({
    required String customerName,
    required DateTime customerDob,
    required String customerAddress,
    required KycDocumentModel document,
  });

  Future<KycRiskStatus> calculateRiskAssessment({
    required String customerId,
    required List<KycDocumentModel> documents,
    required List<FieldMatchResult> matches,
  });
}

class MockKycVerificationService implements IKycVerificationService {
  @override
  Future<bool> checkDigitalIdentityStatus(String documentNumber, KycVerificationMethod method) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (method == KycVerificationMethod.digiLocker) {
      // Return simulated success for DigiLocker placeholder
      return true;
    }
    return documentNumber.trim().isNotEmpty;
  }

  @override
  Future<List<FieldMatchResult>> performMockFieldMatching({
    required String customerName,
    required DateTime customerDob,
    required String customerAddress,
    required KycDocumentModel document,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final docName = document.nameOnDoc;
    final isExactNameMatch = customerName.toLowerCase() == docName.toLowerCase();
    final isPartialNameMatch = customerName.toLowerCase().contains(docName.toLowerCase()) ||
        docName.toLowerCase().contains(customerName.toLowerCase());

    FieldMatchStatus nameStatus = FieldMatchStatus.mismatch;
    if (isExactNameMatch) {
      nameStatus = FieldMatchStatus.match;
    } else if (isPartialNameMatch) {
      nameStatus = FieldMatchStatus.partialMatch;
    }

    final isDobMatch = customerDob.year == document.dateOfBirth.year && customerDob.month == document.dateOfBirth.month;

    return [
      FieldMatchResult(
        fieldName: 'Customer Name vs Document Name',
        customerValue: customerName,
        documentValue: document.nameOnDoc,
        status: nameStatus,
      ),
      FieldMatchResult(
        fieldName: 'Date of Birth',
        customerValue: '${customerDob.day}/${customerDob.month}/${customerDob.year}',
        documentValue: '${document.dateOfBirth.day}/${document.dateOfBirth.month}/${document.dateOfBirth.year}',
        status: isDobMatch ? FieldMatchStatus.match : FieldMatchStatus.partialMatch,
      ),
      FieldMatchResult(
        fieldName: 'Address Record Alignment',
        customerValue: customerAddress,
        documentValue: 'Address Verified on Govt Record',
        status: FieldMatchStatus.match,
      ),
    ];
  }

  @override
  Future<KycRiskStatus> calculateRiskAssessment({
    required String customerId,
    required List<KycDocumentModel> documents,
    required List<FieldMatchResult> matches,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final hasMismatch = matches.any((m) => m.status == FieldMatchStatus.mismatch);
    if (hasMismatch) {
      return KycRiskStatus.high;
    }

    final hasPartial = matches.any((m) => m.status == FieldMatchStatus.partialMatch);
    if (hasPartial) {
      return KycRiskStatus.medium;
    }

    return KycRiskStatus.low;
  }
}
