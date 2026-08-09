import '../../ornaments/models/ornament_model.dart';
import '../models/loan_model.dart';
import '../services/loan_calculation_service.dart';
import 'loan_repository.dart';

class MockLoanRepository implements ILoanRepository {
  MockLoanRepository() {
    _seedData();
  }

  final List<LoanModel> _loans = [];
  final ILoanCalculationService _calcService = MockLoanCalculationService();

  void _seedData() {
    if (_loans.isNotEmpty) return;

    final now = DateTime.now();

    final customers = [
      {'id': 'KC-CUS-000101', 'name': 'Rahul Kumar Sharma', 'kyc': 'Verified', 'risk': 'Low'},
      {'id': 'KC-CUS-000102', 'name': 'Sunita Verma', 'kyc': 'Verified', 'risk': 'Low'},
      {'id': 'KC-CUS-000103', 'name': 'Vikramaditya Singh Rathore', 'kyc': 'Verified', 'risk': 'Medium'},
      {'id': 'KC-CUS-000104', 'name': 'Priya Patel', 'kyc': 'Verified', 'risk': 'Low'},
      {'id': 'KC-CUS-000105', 'name': 'Amitabh Banerjee', 'kyc': 'Pending', 'risk': 'High'},
    ];

    final branches = ['Main Branch (Store 01)', 'North Extension Branch', 'South Jeweller Hub'];
    final officers = ['Arjun Mehta (Manager)', 'Anil Gupta (Admin)', 'Kavita Roy (Officer)'];

    final statuses = [
      LoanStatus.active,
      LoanStatus.dueSoon,
      LoanStatus.overdue,
      LoanStatus.partiallyRepaid,
      LoanStatus.pendingApproval,
      LoanStatus.closed,
    ];

    for (int i = 1; i <= 30; i++) {
      final loanId = 'KC-LN-${(9480 + i).toString()}';
      final pledgeId = 'KC-PLG-${(100 + i).toString()}';
      final cust = customers[(i - 1) % customers.length];
      final status = statuses[(i - 1) % statuses.length];
      final branch = branches[(i - 1) % branches.length];
      final officer = officers[(i - 1) % officers.length];

      final isSilver = (i % 6 == 0);
      final metal = isSilver ? MetalType.silver : MetalType.gold;
      final gross = 25.0 + (i * 5.0);
      final net = gross * 0.92;
      final valPerG = isSilver ? 88.0 : 6650.0;
      final collateralVal = net * valPerG;

      final principal = collateralVal * 0.72; // LTV 72%
      final rate = isSilver ? 14.5 : 11.5;
      final daysAgo = i * 15;
      final pledgeDate = now.subtract(Duration(days: daysAgo));
      final maturityDate = pledgeDate.add(const Duration(days: 365));

      final accrued = status == LoanStatus.closed ? 0.0 : (principal * (rate / 100.0) * (daysAgo / 365.0));
      final outstandingPrinc = status == LoanStatus.closed ? 0.0 : principal;

      final ornament = OrnamentModel(
        id: 'KC-ORN-PLG-$i',
        name: '${metal.label} Collateral Asset #$i',
        category: OrnamentCategory.necklaces,
        metalType: metal,
        purity: isSilver ? OrnamentPurity.silver925 : OrnamentPurity.k22_916,
        weight: WeightBreakdown(grossWeight: gross, stoneWeight: gross - net),
        valuation: ValuationBreakdown(
          metalRate: valPerG,
          metalValue: collateralVal,
          totalEstimatedValue: collateralVal,
        ),
        status: status == LoanStatus.closed ? OrnamentStatus.released : OrnamentStatus.pledged,
        ownershipType: OwnershipType.pledged,
        ownerCustomerId: cust['id'],
        ownerCustomerName: cust['name'],
        pledgeLoanId: loanId,
        location: const InventoryLocationModel(
          branch: 'Main Branch (Store 01)',
          storageArea: 'Central Vault',
          locker: 'Locker #01',
        ),
        createdAt: pledgeDate,
        updatedAt: now,
      );

      final payments = <LoanPaymentModel>[];
      if (status == LoanStatus.partiallyRepaid || status == LoanStatus.closed || i % 2 == 0) {
        payments.add(
          LoanPaymentModel(
            id: 'PAY-$i-1',
            loanId: loanId,
            amount: 5000.0 + (i * 200.0),
            paymentDate: now.subtract(Duration(days: daysAgo ~/ 2)),
            method: DisbursementMethod.upi,
            principalComponent: 2000.0,
            interestComponent: 3000.0 + (i * 200.0),
            receiptNumber: 'KC-RCP-${(200 + i).toString().padLeft(6, '0')}',
            recordedBy: officer,
            notes: 'Regular interest & partial principal payment.',
          ),
        );
      }

      final schedule = List.generate(12, (idx) {
        final due = pledgeDate.add(Duration(days: (idx + 1) * 30));
        final instDue = principal * (rate / 100.0) / 12.0;
        return LoanScheduleItem(
          installmentNumber: idx + 1,
          dueDate: due,
          principalComponent: 0.0,
          interestComponent: instDue,
          totalDue: instDue,
          paidAmount: due.isBefore(now) ? instDue : 0.0,
          remainingAmount: due.isBefore(now) ? 0.0 : instDue,
          status: due.isBefore(now) ? 'Paid' : 'Upcoming',
        );
      });

      final loan = LoanModel(
        id: loanId,
        customerId: cust['id']!,
        customerName: cust['name']!,
        customerKycStatus: cust['kyc']!,
        customerRisk: cust['risk']!,
        pledgeId: pledgeId,
        collateralOrnaments: [ornament],
        pledgeDate: pledgeDate,
        disbursedDate: pledgeDate,
        maturityDate: maturityDate,
        principalAmount: principal,
        outstandingPrincipal: outstandingPrinc,
        interestRatePercentage: rate,
        accruedInterest: accrued,
        interestPaid: payments.fold(0.0, (sum, p) => sum + p.interestComponent),
        principalPaid: payments.fold(0.0, (sum, p) => sum + p.principalComponent),
        nextDueDate: now.add(Duration(days: (i % 14) + 1)),
        collateralTotalValue: collateralVal,
        collateralNetWeightGrams: net,
        status: status,
        riskStatus: cust['risk'] == 'High' ? LoanRiskStatus.high : (status == LoanStatus.overdue ? LoanRiskStatus.medium : LoanRiskStatus.low),
        branch: branch,
        loanOfficer: officer,
        payments: payments,
        schedule: schedule,
        documents: [
          LoanDocumentModel(
            id: 'DOC-LN-$i-1',
            name: 'Pledge Agreement & Sanction Letter',
            type: 'Loan Agreement',
            uploadDate: pledgeDate,
            uploadedBy: officer,
          ),
          LoanDocumentModel(
            id: 'DOC-LN-$i-2',
            name: 'Pledge Receipt #${(100 + i)}',
            type: 'Pledge Receipt',
            uploadDate: pledgeDate,
            uploadedBy: officer,
          ),
        ],
        activities: [
          LoanActivityModel(
            id: 'ACT-$i-1',
            timestamp: pledgeDate,
            actorName: officer,
            role: 'Loan Officer',
            action: 'Loan Disbursed',
            description: 'Disbursed ₹${principal.toStringAsFixed(0)} via Bank Transfer.',
          ),
        ],
        auditLogs: [
          LoanAuditModel(
            id: 'AUD-$i-1',
            timestamp: pledgeDate,
            actorName: officer,
            action: 'Loan Creation',
            description: 'Created loan $loanId for customer ${cust['name']}.',
            previousState: 'Draft',
            newState: status.label,
          ),
        ],
        createdAt: pledgeDate,
        updatedAt: now,
      );

      _loans.add(loan);
    }
  }

  @override
  Future<LoanDashboardMetrics> getDashboardMetrics() async {
    await Future.delayed(const Duration(milliseconds: 200));

    int active = 0;
    double outPrinc = 0.0;
    double interestDue = 0.0;
    double interestColl = 0.0;
    int overdue = 0;
    int dueSoon = 0;
    int closedMo = 0;
    double colVal = 0.0;
    double colWt = 0.0;

    for (final l in _loans) {
      colVal += l.collateralTotalValue;
      colWt += l.collateralNetWeightGrams;

      if (l.status == LoanStatus.active || l.status == LoanStatus.partiallyRepaid || l.status == LoanStatus.dueSoon || l.status == LoanStatus.overdue) {
        active++;
        outPrinc += l.outstandingPrincipal;
        interestDue += l.accruedInterest;
      }
      if (l.status == LoanStatus.overdue) overdue++;
      if (l.status == LoanStatus.dueSoon) dueSoon++;
      if (l.status == LoanStatus.closed) closedMo++;

      interestColl += l.interestPaid;
    }

    return LoanDashboardMetrics(
      activeLoansCount: active,
      totalOutstandingPrincipal: outPrinc,
      totalInterestDue: interestDue,
      totalInterestCollected: interestColl,
      overdueLoansCount: overdue,
      loansDueSoonCount: dueSoon,
      loansClosedThisMonthCount: closedMo,
      totalCollateralValue: colVal,
      totalPledgedWeightGrams: colWt,
    );
  }

  @override
  Future<List<LoanModel>> getLoans({
    String? searchQuery,
    LoanFilterParams? filters,
    LoanSortOption? sortOption,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    Iterable<LoanModel> result = List.of(_loans);

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      result = result.where((l) {
        return l.id.toLowerCase().contains(q) ||
            l.customerName.toLowerCase().contains(q) ||
            l.customerId.toLowerCase().contains(q) ||
            l.pledgeId.toLowerCase().contains(q) ||
            l.collateralOrnaments.any((o) => o.id.toLowerCase().contains(q) || o.name.toLowerCase().contains(q));
      });
    }

    if (filters != null) {
      if (filters.status != null) {
        result = result.where((l) => l.status == filters.status);
      }
      if (filters.riskStatus != null) {
        result = result.where((l) => l.riskStatus == filters.riskStatus);
      }
      if (filters.branch != null && filters.branch!.isNotEmpty) {
        result = result.where((l) => l.branch == filters.branch);
      }
      if (filters.minAmount != null) {
        result = result.where((l) => l.principalAmount >= filters.minAmount!);
      }
      if (filters.maxAmount != null) {
        result = result.where((l) => l.principalAmount <= filters.maxAmount!);
      }
    }

    final list = result.toList();
    final sort = sortOption ?? LoanSortOption.newest;

    switch (sort) {
      case LoanSortOption.newest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case LoanSortOption.oldest:
        list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case LoanSortOption.principalHighToLow:
        list.sort((a, b) => b.principalAmount.compareTo(a.principalAmount));
        break;
      case LoanSortOption.interestDueHighToLow:
        list.sort((a, b) => b.accruedInterest.compareTo(a.accruedInterest));
        break;
      case LoanSortOption.nextDueSoonest:
        list.sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
        break;
      case LoanSortOption.statusPriority:
        list.sort((a, b) => a.status.index.compareTo(b.status.index));
        break;
    }

    return list;
  }

  @override
  Future<LoanModel?> getLoanById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _loans.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<LoanModel>> getLoansByCustomerId(String customerId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _loans.where((l) => l.customerId == customerId).toList();
  }

  @override
  Future<LoanModel> createLoan(LoanModel loan) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _loans.insert(0, loan);
    return loan;
  }

  @override
  Future<LoanModel> updateLoan(LoanModel loan) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _loans.indexWhere((l) => l.id == loan.id);
    if (index != -1) {
      _loans[index] = loan;
      return loan;
    }
    throw Exception('Loan not found');
  }

  @override
  Future<LoanModel> approveLoan({
    required String loanId,
    required String reviewerName,
    String notes = '',
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _loans.indexWhere((l) => l.id == loanId);
    if (index != -1) {
      final existing = _loans[index];
      final now = DateTime.now();

      final updated = existing.copyWith(
        status: LoanStatus.approved,
        activities: List.from(existing.activities)
          ..insert(
            0,
            LoanActivityModel(
              id: 'ACT-${now.millisecondsSinceEpoch}',
              timestamp: now,
              actorName: reviewerName,
              role: 'Branch Manager',
              action: 'Loan Approved',
              description: 'Loan proposal approved. Notes: $notes',
            ),
          ),
        updatedAt: now,
      );

      _loans[index] = updated;
      return updated;
    }
    throw Exception('Loan not found');
  }

  @override
  Future<LoanModel> rejectLoan({
    required String loanId,
    required String reviewerName,
    required String reason,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _loans.indexWhere((l) => l.id == loanId);
    if (index != -1) {
      final existing = _loans[index];
      final now = DateTime.now();

      final updated = existing.copyWith(
        status: LoanStatus.cancelled,
        activities: List.from(existing.activities)
          ..insert(
            0,
            LoanActivityModel(
              id: 'ACT-${now.millisecondsSinceEpoch}',
              timestamp: now,
              actorName: reviewerName,
              role: 'Branch Manager',
              action: 'Loan Rejected',
              description: 'Loan request rejected. Reason: $reason',
            ),
          ),
        updatedAt: now,
      );

      _loans[index] = updated;
      return updated;
    }
    throw Exception('Loan not found');
  }

  @override
  Future<LoanModel> disburseLoan({
    required String loanId,
    required DisbursementMethod method,
    required String referenceNumber,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _loans.indexWhere((l) => l.id == loanId);
    if (index != -1) {
      final existing = _loans[index];
      final now = DateTime.now();

      final updated = existing.copyWith(
        status: LoanStatus.active,
        disbursedDate: now,
        disbursementMethod: method,
        disbursementReference: referenceNumber,
        activities: List.from(existing.activities)
          ..insert(
            0,
            LoanActivityModel(
              id: 'ACT-${now.millisecondsSinceEpoch}',
              timestamp: now,
              actorName: 'Disbursement Officer',
              role: 'Cashier',
              action: 'Funds Disbursed',
              description: 'Disbursed ₹${existing.principalAmount} via ${method.label}. Ref: $referenceNumber',
            ),
          ),
        updatedAt: now,
      );

      _loans[index] = updated;
      return updated;
    }
    throw Exception('Loan not found');
  }

  @override
  Future<LoanModel> recordPayment({
    required String loanId,
    required double amount,
    required DisbursementMethod method,
    required String recordedBy,
    String notes = '',
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _loans.indexWhere((l) => l.id == loanId);
    if (index != -1) {
      final existing = _loans[index];
      final now = DateTime.now();

      final alloc = _calcService.calculatePaymentAllocation(
        totalPayment: amount,
        outstandingInterest: existing.accruedInterest,
        outstandingPrincipal: existing.outstandingPrincipal,
      );

      final intComp = alloc['interestComponent'] ?? 0.0;
      final princComp = alloc['principalComponent'] ?? 0.0;

      final newAccrued = existing.accruedInterest - intComp;
      final newOutstandingPrinc = existing.outstandingPrincipal - princComp;

      final newStatus = newOutstandingPrinc <= 0 && newAccrued <= 0 ? LoanStatus.closed : (princComp > 0 ? LoanStatus.partiallyRepaid : LoanStatus.active);

      final payment = LoanPaymentModel(
        id: 'PAY-${now.millisecondsSinceEpoch}',
        loanId: loanId,
        amount: amount,
        paymentDate: now,
        method: method,
        principalComponent: princComp,
        interestComponent: intComp,
        receiptNumber: 'KC-RCP-${now.millisecondsSinceEpoch.toString().substring(6)}',
        recordedBy: recordedBy,
        notes: notes,
      );

      final updatedPayments = List<LoanPaymentModel>.from(existing.payments)..insert(0, payment);

      final updated = existing.copyWith(
        status: newStatus,
        outstandingPrincipal: newOutstandingPrinc > 0 ? newOutstandingPrinc : 0.0,
        accruedInterest: newAccrued > 0 ? newAccrued : 0.0,
        interestPaid: existing.interestPaid + intComp,
        principalPaid: existing.principalPaid + princComp,
        payments: updatedPayments,
        activities: List.from(existing.activities)
          ..insert(
            0,
            LoanActivityModel(
              id: 'ACT-${now.millisecondsSinceEpoch}',
              timestamp: now,
              actorName: recordedBy,
              role: 'Teller / Staff',
              action: 'Payment Received',
              description: 'Payment of ₹$amount received. (Interest: ₹$intComp, Principal: ₹$princComp). Receipt: ${payment.receiptNumber}',
            ),
          ),
        updatedAt: now,
      );

      _loans[index] = updated;
      return updated;
    }
    throw Exception('Loan not found');
  }

  @override
  Future<LoanModel> settleLoan({
    required String loanId,
    required double settlementAmount,
    required DisbursementMethod method,
    required String settledBy,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _loans.indexWhere((l) => l.id == loanId);
    if (index != -1) {
      final existing = _loans[index];
      final now = DateTime.now();

      final updated = existing.copyWith(
        status: LoanStatus.closed,
        outstandingPrincipal: 0.0,
        accruedInterest: 0.0,
        principalPaid: existing.principalAmount,
        activities: List.from(existing.activities)
          ..insert(
            0,
            LoanActivityModel(
              id: 'ACT-${now.millisecondsSinceEpoch}',
              timestamp: now,
              actorName: settledBy,
              role: 'Branch Manager',
              action: 'Full Settlement & Loan Closure',
              description: 'Loan settled in full with payment of ₹$settlementAmount via ${method.label}. Collateral marked for release.',
            ),
          ),
        updatedAt: now,
      );

      _loans[index] = updated;
      return updated;
    }
    throw Exception('Loan not found');
  }

  @override
  Future<LoanModel> renewLoan({
    required String loanId,
    required double newPrincipal,
    required double newRate,
    required int extendedMonths,
    required String officerName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _loans.indexWhere((l) => l.id == loanId);
    if (index != -1) {
      final existing = _loans[index];
      final now = DateTime.now();

      final updated = existing.copyWith(
        principalAmount: newPrincipal,
        outstandingPrincipal: newPrincipal,
        interestRatePercentage: newRate,
        maturityDate: existing.maturityDate.add(Duration(days: extendedMonths * 30)),
        status: LoanStatus.active,
        activities: List.from(existing.activities)
          ..insert(
            0,
            LoanActivityModel(
              id: 'ACT-${now.millisecondsSinceEpoch}',
              timestamp: now,
              actorName: officerName,
              role: 'Loan Officer',
              action: 'Loan Renewed',
              description: 'Renewed loan for $extendedMonths months at $newRate% interest rate.',
            ),
          ),
        updatedAt: now,
      );

      _loans[index] = updated;
      return updated;
    }
    throw Exception('Loan not found');
  }

  @override
  Future<LoanModel> releaseCollateral({
    required String loanId,
    required String verifiedByStaff,
    String notes = '',
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _loans.indexWhere((l) => l.id == loanId);
    if (index != -1) {
      final existing = _loans[index];
      final now = DateTime.now();

      final updatedOrnaments = existing.collateralOrnaments.map((o) {
        return o.copyWith(status: OrnamentStatus.available);
      }).toList();

      final updated = existing.copyWith(
        collateralOrnaments: updatedOrnaments,
        activities: List.from(existing.activities)
          ..insert(
            0,
            LoanActivityModel(
              id: 'ACT-${now.millisecondsSinceEpoch}',
              timestamp: now,
              actorName: verifiedByStaff,
              role: 'Vault Officer',
              action: 'Collateral Released to Customer',
              description: 'Pledged ornaments handed over to customer after identity verification. Notes: $notes',
            ),
          ),
        updatedAt: now,
      );

      _loans[index] = updated;
      return updated;
    }
    throw Exception('Loan not found');
  }
}
