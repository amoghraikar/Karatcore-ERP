import 'package:flutter/material.dart';
import '../../ornaments/models/ornament_model.dart';

enum LoanStatus {
  draft('Draft', Icons.edit_note_rounded, Color(0xFF6B7280), 'Initial loan proposal draft.'),
  pendingApproval('Pending Approval', Icons.hourglass_top_rounded, Color(0xFFD97706), 'Awaiting manager approval review.'),
  approved('Approved', Icons.check_circle_outline_rounded, Color(0xFF0D9488), 'Approved for disbursement.'),
  active('Active', Icons.monetization_on_rounded, Color(0xFF2563EB), 'Disbursed and active gold loan.'),
  dueSoon('Due Soon', Icons.schedule_rounded, Color(0xFFF59E0B), 'Payment installment due within 7 days.'),
  overdue('Overdue', Icons.warning_amber_rounded, Color(0xFFDC2626), 'Payment past due date.'),
  partiallyRepaid('Partially Repaid', Icons.pie_chart_outline_rounded, Color(0xFF8B5CF6), 'Partial principal or interest repaid.'),
  closed('Closed', Icons.lock_clock_rounded, Color(0xFF059669), 'Loan fully settled and closed.'),
  cancelled('Cancelled', Icons.cancel_rounded, Color(0xFF9CA3AF), 'Cancelled loan request.'),
  writtenOff('Written Off', Icons.report_problem_rounded, Color(0xFF7F1D1D), 'Written off loan asset.');

  const LoanStatus(this.label, this.icon, this.color, this.description);
  final String label;
  final IconData icon;
  final Color color;
  final String description;
}

enum LoanRiskStatus {
  low('Low Risk', Icons.shield_rounded, Color(0xFF059669)),
  medium('Medium Risk', Icons.info_outline_rounded, Color(0xFFD97706)),
  high('High Risk', Icons.warning_amber_rounded, Color(0xFFDC2626)),
  reviewRequired('Review Required', Icons.find_in_page_rounded, Color(0xFF7C3AED));

  const LoanRiskStatus(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color color;
}

enum InterestType {
  simple('Simple Interest', 'Calculated strictly on outstanding principal.'),
  compound('Compound Interest', 'Compounded at configured frequency.'),
  flatRate('Flat Rate', 'Fixed percentage over loan tenure.');

  const InterestType(this.label, this.description);
  final String label;
  final String description;
}

enum PaymentFrequency {
  monthly('Monthly', 'Installments due every month.'),
  biweekly('Bi-Weekly', 'Installments due every 14 days.'),
  daily('Daily Accrual', 'Interest calculated daily.'),
  bullet('Bullet / Lump Sum', 'Principal and interest due at maturity.');

  const PaymentFrequency(this.label, this.description);
  final String label;
  final String description;
}

enum DisbursementMethod {
  cash('Cash', Icons.payments_rounded),
  bankTransfer('Bank Transfer / NEFT / RTGS', Icons.account_balance_rounded),
  upi('UPI / IMPS', Icons.qr_code_scanner_rounded),
  other('Other Method', Icons.more_horiz_rounded);

  const DisbursementMethod(this.label, this.icon);
  final String label;
  final IconData icon;
}

enum PaymentType {
  principalOnly('Principal Repayment'),
  interestOnly('Interest Payment'),
  mixed('Principal & Interest'),
  fullSettlement('Full Settlement');

  const PaymentType(this.label);
  final String label;
}

enum PledgeStatus {
  draft('Draft Pledge'),
  active('Active Pledge'),
  released('Released Collateral'),
  cancelled('Cancelled Pledge');

  const PledgeStatus(this.label);
  final String label;
}

class PledgeModel {
  const PledgeModel({
    required this.id,
    required this.loanId,
    required this.customerId,
    required this.customerName,
    required this.ornaments,
    required this.pledgeDate,
    required this.branch,
    required this.totalValuation,
    required this.status,
    this.releaseDate,
    required this.officerName,
    this.history = const [],
  });

  final String id;
  final String loanId;
  final String customerId;
  final String customerName;
  final List<OrnamentModel> ornaments;
  final DateTime pledgeDate;
  final String branch;
  final double totalValuation;
  final PledgeStatus status;
  final DateTime? releaseDate;
  final String officerName;
  final List<String> history;
}

class LoanPaymentModel {
  const LoanPaymentModel({
    required this.id,
    required this.loanId,
    required this.amount,
    required this.paymentDate,
    required this.method,
    required this.principalComponent,
    required this.interestComponent,
    this.feesComponent = 0.0,
    required this.receiptNumber,
    required this.recordedBy,
    this.notes = '',
  });

  final String id;
  final String loanId;
  final double amount;
  final DateTime paymentDate;
  final DisbursementMethod method;
  final double principalComponent;
  final double interestComponent;
  final double feesComponent;
  final String receiptNumber; // e.g. KC-RCP-000245
  final String recordedBy;
  final String notes;
}

class LoanScheduleItem {
  const LoanScheduleItem({
    required this.installmentNumber,
    required this.dueDate,
    required this.principalComponent,
    required this.interestComponent,
    required this.totalDue,
    required this.paidAmount,
    required this.remainingAmount,
    required this.status, // Upcoming, Due, Partially Paid, Paid, Overdue
  });

  final int installmentNumber;
  final DateTime dueDate;
  final double principalComponent;
  final double interestComponent;
  final double totalDue;
  final double paidAmount;
  final double remainingAmount;
  final String status;
}

class LoanDocumentModel {
  const LoanDocumentModel({
    required this.id,
    required this.name,
    required this.type, // Loan Agreement, Pledge Receipt, Valuation Doc, Payment Receipt, Release Receipt
    required this.uploadDate,
    required this.uploadedBy,
    this.url = '',
  });

  final String id;
  final String name;
  final String type;
  final DateTime uploadDate;
  final String uploadedBy;
  final String url;
}

class LoanActivityModel {
  const LoanActivityModel({
    required this.id,
    required this.timestamp,
    required this.actorName,
    required this.role,
    required this.action,
    required this.description,
  });

  final String id;
  final DateTime timestamp;
  final String actorName;
  final String role;
  final String action;
  final String description;
}

class LoanAuditModel {
  const LoanAuditModel({
    required this.id,
    required this.timestamp,
    required this.actorName,
    required this.action,
    required this.description,
    required this.previousState,
    required this.newState,
  });

  final String id;
  final DateTime timestamp;
  final String actorName;
  final String action;
  final String description;
  final String previousState;
  final String newState;
}

class LoanModel {
  const LoanModel({
    required this.id, // KC-LN-000101
    required this.customerId,
    required this.customerName,
    required this.customerKycStatus,
    this.customerRisk = 'Low',
    required this.pledgeId,
    required this.collateralOrnaments,
    required this.pledgeDate,
    this.disbursedDate,
    required this.maturityDate,
    required this.principalAmount,
    required this.outstandingPrincipal,
    required this.interestRatePercentage, // annual %
    required this.accruedInterest,
    this.interestPaid = 0.0,
    this.principalPaid = 0.0,
    this.processingFee = 500.0,
    required this.nextDueDate,
    required this.collateralTotalValue,
    required this.collateralNetWeightGrams,
    required this.status,
    required this.riskStatus,
    required this.branch,
    required this.loanOfficer,
    this.disbursementMethod = DisbursementMethod.bankTransfer,
    this.disbursementReference = 'NEFT-88492019',
    this.payments = const [],
    this.schedule = const [],
    this.documents = const [],
    this.activities = const [],
    this.auditLogs = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String customerId;
  final String customerName;
  final String customerKycStatus;
  final String customerRisk;
  final String pledgeId;
  final List<OrnamentModel> collateralOrnaments;
  final DateTime pledgeDate;
  final DateTime? disbursedDate;
  final DateTime maturityDate;
  final double principalAmount;
  final double outstandingPrincipal;
  final double interestRatePercentage;
  final double accruedInterest;
  final double interestPaid;
  final double principalPaid;
  final double processingFee;
  final DateTime nextDueDate;
  final double collateralTotalValue;
  final double collateralNetWeightGrams;
  final LoanStatus status;
  final LoanRiskStatus riskStatus;
  final String branch;
  final String loanOfficer;
  final DisbursementMethod disbursementMethod;
  final String disbursementReference;
  final List<LoanPaymentModel> payments;
  final List<LoanScheduleItem> schedule;
  final List<LoanDocumentModel> documents;
  final List<LoanActivityModel> activities;
  final List<LoanAuditModel> auditLogs;
  final DateTime createdAt;
  final DateTime updatedAt;

  double get ltvPercentage {
    if (collateralTotalValue <= 0) return 0.0;
    return (principalAmount / collateralTotalValue) * 100.0;
  }

  double get totalOutstanding {
    return outstandingPrincipal + accruedInterest;
  }

  double get totalPaid {
    return principalPaid + interestPaid;
  }

  LoanModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerKycStatus,
    String? customerRisk,
    String? pledgeId,
    List<OrnamentModel>? collateralOrnaments,
    DateTime? pledgeDate,
    DateTime? disbursedDate,
    DateTime? maturityDate,
    double? principalAmount,
    double? outstandingPrincipal,
    double? interestRatePercentage,
    double? accruedInterest,
    double? interestPaid,
    double? principalPaid,
    double? processingFee,
    DateTime? nextDueDate,
    double? collateralTotalValue,
    double? collateralNetWeightGrams,
    LoanStatus? status,
    LoanRiskStatus? riskStatus,
    String? branch,
    String? loanOfficer,
    DisbursementMethod? disbursementMethod,
    String? disbursementReference,
    List<LoanPaymentModel>? payments,
    List<LoanScheduleItem>? schedule,
    List<LoanDocumentModel>? documents,
    List<LoanActivityModel>? activities,
    List<LoanAuditModel>? auditLogs,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LoanModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerKycStatus: customerKycStatus ?? this.customerKycStatus,
      customerRisk: customerRisk ?? this.customerRisk,
      pledgeId: pledgeId ?? this.pledgeId,
      collateralOrnaments: collateralOrnaments ?? this.collateralOrnaments,
      pledgeDate: pledgeDate ?? this.pledgeDate,
      disbursedDate: disbursedDate ?? this.disbursedDate,
      maturityDate: maturityDate ?? this.maturityDate,
      principalAmount: principalAmount ?? this.principalAmount,
      outstandingPrincipal: outstandingPrincipal ?? this.outstandingPrincipal,
      interestRatePercentage: interestRatePercentage ?? this.interestRatePercentage,
      accruedInterest: accruedInterest ?? this.accruedInterest,
      interestPaid: interestPaid ?? this.interestPaid,
      principalPaid: principalPaid ?? this.principalPaid,
      processingFee: processingFee ?? this.processingFee,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      collateralTotalValue: collateralTotalValue ?? this.collateralTotalValue,
      collateralNetWeightGrams: collateralNetWeightGrams ?? this.collateralNetWeightGrams,
      status: status ?? this.status,
      riskStatus: riskStatus ?? this.riskStatus,
      branch: branch ?? this.branch,
      loanOfficer: loanOfficer ?? this.loanOfficer,
      disbursementMethod: disbursementMethod ?? this.disbursementMethod,
      disbursementReference: disbursementReference ?? this.disbursementReference,
      payments: payments ?? this.payments,
      schedule: schedule ?? this.schedule,
      documents: documents ?? this.documents,
      activities: activities ?? this.activities,
      auditLogs: auditLogs ?? this.auditLogs,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
