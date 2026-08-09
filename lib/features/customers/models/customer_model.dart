import 'package:flutter/material.dart';

enum CustomerKycStatus {
  verified('Verified', Icons.verified_rounded, Color(0xFF059669)),
  pending('Pending', Icons.hourglass_top_rounded, Color(0xFFD97706)),
  rejected('Rejected', Icons.cancel_rounded, Color(0xFFDC2626)),
  incomplete('Incomplete', Icons.help_outline_rounded, Color(0xFF6B7280));

  const CustomerKycStatus(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color color;
}

enum CustomerStatus {
  active('Active', Icons.check_circle_rounded, Color(0xFF059669)),
  inactive('Inactive', Icons.remove_circle_outline_rounded, Color(0xFF6B7280)),
  archived('Archived', Icons.archive_rounded, Color(0xFF4B5563)),
  blocked('Blocked', Icons.block_rounded, Color(0xFFDC2626));

  const CustomerStatus(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color color;
}

enum CustomerRiskLevel {
  low('Low Risk', Icons.shield_outlined, Color(0xFF059669)),
  medium('Medium Risk', Icons.warning_amber_rounded, Color(0xFFD97706)),
  high('High Risk', Icons.gpp_bad_rounded, Color(0xFFDC2626));

  const CustomerRiskLevel(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color color;
}

enum CustomerType {
  individual('Individual', Icons.person_rounded),
  business('Business', Icons.business_rounded);

  const CustomerType(this.label, this.icon);
  final String label;
  final IconData icon;
}

class CustomerNote {
  const CustomerNote({
    required this.id,
    required this.content,
    required this.authorName,
    required this.createdAt,
    this.isPinned = false,
  });

  final String id;
  final String content;
  final String authorName;
  final DateTime createdAt;
  final bool isPinned;

  CustomerNote copyWith({
    String? id,
    String? content,
    String? authorName,
    DateTime? createdAt,
    bool? isPinned,
  }) {
    return CustomerNote(
      id: id ?? this.id,
      content: content ?? this.content,
      authorName: authorName ?? this.authorName,
      createdAt: createdAt ?? this.createdAt,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}

class CustomerLoanSummary {
  const CustomerLoanSummary({
    required this.loanId,
    required this.pledgeDate,
    required this.principalAmount,
    required this.interestRatePercent,
    required this.outstandingAmount,
    required this.status,
    required this.dueDate,
  });

  final String loanId;
  final DateTime pledgeDate;
  final double principalAmount;
  final double interestRatePercent;
  final double outstandingAmount;
  final String status; // Active, Closed, Overdue
  final DateTime dueDate;
}

class CustomerOrnamentSummary {
  const CustomerOrnamentSummary({
    required this.ornamentId,
    required this.type,
    required this.metal,
    required this.purity,
    required this.grossWeightGrams,
    required this.netWeightGrams,
    required this.status,
    this.imageUrl,
  });

  final String ornamentId;
  final String type; // Necklace, Ring, Bangle, Chain
  final String metal; // Gold, Silver, Platinum
  final String purity; // 22K, 24K, 18K
  final double grossWeightGrams;
  final double netWeightGrams;
  final String status; // Pledged, Released, In Vault
  final String? imageUrl;
}

class CustomerPaymentSummary {
  const CustomerPaymentSummary({
    required this.receiptNo,
    required this.date,
    required this.amount,
    required this.paymentMethod,
    required this.loanId,
    required this.status,
  });

  final String receiptNo;
  final DateTime date;
  final double amount;
  final String paymentMethod; // UPI, Cash, Bank Transfer, Card
  final String loanId;
  final String status; // Success, Pending, Failed
}

class CustomerDocument {
  const CustomerDocument({
    required this.id,
    required this.name,
    required this.documentType,
    required this.uploadDate,
    required this.status,
    required this.isVerified,
    this.fileSize = '1.2 MB',
  });

  final String id;
  final String name;
  final String documentType; // KYC, Identity, Address Proof, Ownership Proof, Loan Agreement, Payment Receipt, Other
  final DateTime uploadDate;
  final String status;
  final bool isVerified;
  final String fileSize;
}

class CustomerActivityItem {
  const CustomerActivityItem({
    required this.id,
    required this.timestamp,
    required this.actor,
    required this.eventType,
    required this.description,
    required this.icon,
  });

  final String id;
  final DateTime timestamp;
  final String actor;
  final String eventType;
  final String description;
  final IconData icon;
}

class CustomerModel {
  const CustomerModel({
    required this.id,
    required this.firstName,
    this.middleName = '',
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    required this.customerType,
    required this.mobile,
    this.alternateMobile = '',
    required this.email,
    required this.addressLine,
    required this.city,
    required this.state,
    required this.pincode,
    this.country = 'India',
    required this.occupation,
    required this.annualIncome,
    required this.kycStatus,
    required this.customerStatus,
    required this.riskStatus,
    this.tags = const [],
    this.avatarUrl,
    required this.createdAt,
    required this.lastActivityAt,
    this.panNumberPlaceholder = '',
    this.aadhaarNumberPlaceholder = '',
    this.activeLoansCount = 0,
    this.totalOutstandingAmount = 0.0,
    this.totalInterestPaid = 0.0,
    this.totalRepaidAmount = 0.0,
    this.closedLoansCount = 0,
    this.notes = const [],
    this.loans = const [],
    this.ornaments = const [],
    this.payments = const [],
    this.documents = const [],
    this.activities = const [],
  });

  final String id;
  final String firstName;
  final String middleName;
  final String lastName;
  final DateTime dateOfBirth;
  final String gender;
  final CustomerType customerType;
  final String mobile;
  final String alternateMobile;
  final String email;
  final String addressLine;
  final String city;
  final String state;
  final String pincode;
  final String country;
  final String occupation;
  final String annualIncome;
  final CustomerKycStatus kycStatus;
  final CustomerStatus customerStatus;
  final CustomerRiskLevel riskStatus;
  final List<String> tags;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime lastActivityAt;
  final String panNumberPlaceholder;
  final String aadhaarNumberPlaceholder;
  final int activeLoansCount;
  final double totalOutstandingAmount;
  final double totalInterestPaid;
  final double totalRepaidAmount;
  final int closedLoansCount;
  final List<CustomerNote> notes;
  final List<CustomerLoanSummary> loans;
  final List<CustomerOrnamentSummary> ornaments;
  final List<CustomerPaymentSummary> payments;
  final List<CustomerDocument> documents;
  final List<CustomerActivityItem> activities;

  String get fullName => middleName.isEmpty ? '$firstName $lastName' : '$firstName $middleName $lastName';

  String get initials {
    final first = firstName.isNotEmpty ? firstName[0] : '';
    final last = lastName.isNotEmpty ? lastName[0] : '';
    return '$first$last'.toUpperCase();
  }

  CustomerModel copyWith({
    String? id,
    String? firstName,
    String? middleName,
    String? lastName,
    DateTime? dateOfBirth,
    String? gender,
    CustomerType? customerType,
    String? mobile,
    String? alternateMobile,
    String? email,
    String? addressLine,
    String? city,
    String? state,
    String? pincode,
    String? country,
    String? occupation,
    String? annualIncome,
    CustomerKycStatus? kycStatus,
    CustomerStatus? customerStatus,
    CustomerRiskLevel? riskStatus,
    List<String>? tags,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? lastActivityAt,
    String? panNumberPlaceholder,
    String? aadhaarNumberPlaceholder,
    int? activeLoansCount,
    double? totalOutstandingAmount,
    double? totalInterestPaid,
    double? totalRepaidAmount,
    int? closedLoansCount,
    List<CustomerNote>? notes,
    List<CustomerLoanSummary>? loans,
    List<CustomerOrnamentSummary>? ornaments,
    List<CustomerPaymentSummary>? payments,
    List<CustomerDocument>? documents,
    List<CustomerActivityItem>? activities,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      customerType: customerType ?? this.customerType,
      mobile: mobile ?? this.mobile,
      alternateMobile: alternateMobile ?? this.alternateMobile,
      email: email ?? this.email,
      addressLine: addressLine ?? this.addressLine,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      country: country ?? this.country,
      occupation: occupation ?? this.occupation,
      annualIncome: annualIncome ?? this.annualIncome,
      kycStatus: kycStatus ?? this.kycStatus,
      customerStatus: customerStatus ?? this.customerStatus,
      riskStatus: riskStatus ?? this.riskStatus,
      tags: tags ?? this.tags,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      panNumberPlaceholder: panNumberPlaceholder ?? this.panNumberPlaceholder,
      aadhaarNumberPlaceholder: aadhaarNumberPlaceholder ?? this.aadhaarNumberPlaceholder,
      activeLoansCount: activeLoansCount ?? this.activeLoansCount,
      totalOutstandingAmount: totalOutstandingAmount ?? this.totalOutstandingAmount,
      totalInterestPaid: totalInterestPaid ?? this.totalInterestPaid,
      totalRepaidAmount: totalRepaidAmount ?? this.totalRepaidAmount,
      closedLoansCount: closedLoansCount ?? this.closedLoansCount,
      notes: notes ?? this.notes,
      loans: loans ?? this.loans,
      ornaments: ornaments ?? this.ornaments,
      payments: payments ?? this.payments,
      documents: documents ?? this.documents,
      activities: activities ?? this.activities,
    );
  }
}
