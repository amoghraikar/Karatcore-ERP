import '../models/accounting_model.dart';
import 'accounting_repository.dart';

class MockAccountingRepository implements IAccountingRepository {
  MockAccountingRepository() {
    _seedData();
  }

  final List<AccountModel> _accounts = [];
  final List<JournalEntryModel> _journals = [];
  final List<FinancialTransactionModel> _transactions = [];
  final List<IncomeModel> _income = [];
  final List<ExpenseModel> _expenses = [];
  final List<ReceivableModel> _receivables = [];
  final List<PayableModel> _payables = [];
  final List<AccountingPeriodModel> _periods = [];
  final List<AccountingAuditLogModel> _auditLogs = [];

  void _seedData() {
    final now = DateTime.now();

    // 1. Seed Accounts (30 Accounts)
    _accounts.addAll([
      // Assets
      AccountModel(id: 'ACC-101', name: 'Cash in Vault', type: AccountType.asset, category: AccountCategory.cash, openingBalance: 500000.0, currentBalance: 850000.0, createdAt: now),
      AccountModel(id: 'ACC-102', name: 'HDFC Bank Main Operating Account', type: AccountType.asset, category: AccountCategory.bankAccount, openingBalance: 2500000.0, currentBalance: 4200000.0, createdAt: now),
      AccountModel(id: 'ACC-103', name: 'SBI Jeweller Business Account', type: AccountType.asset, category: AccountCategory.bankAccount, openingBalance: 1200000.0, currentBalance: 1850000.0, createdAt: now),
      AccountModel(id: 'ACC-104', name: 'Inventory — Gold Bullion & Ornaments', type: AccountType.asset, category: AccountCategory.inventoryGold, openingBalance: 15000000.0, currentBalance: 18450000.0, createdAt: now),
      AccountModel(id: 'ACC-105', name: 'Inventory — Silver Articles', type: AccountType.asset, category: AccountCategory.inventorySilver, openingBalance: 2500000.0, currentBalance: 3100000.0, createdAt: now),
      AccountModel(id: 'ACC-106', name: 'Loans Receivable — Gold Pledges', type: AccountType.asset, category: AccountCategory.loansReceivable, openingBalance: 12000000.0, currentBalance: 14250000.0, createdAt: now),
      AccountModel(id: 'ACC-107', name: 'Interest Receivable — Accrued', type: AccountType.asset, category: AccountCategory.interestReceivable, openingBalance: 450000.0, currentBalance: 620000.0, createdAt: now),
      AccountModel(id: 'ACC-108', name: 'Other Trade Receivables', type: AccountType.asset, category: AccountCategory.otherReceivables, openingBalance: 180000.0, currentBalance: 240000.0, createdAt: now),

      // Liabilities
      AccountModel(id: 'ACC-201', name: 'Customer Security Deposits', type: AccountType.liability, category: AccountCategory.customerDeposits, openingBalance: 800000.0, currentBalance: 950000.0, createdAt: now),
      AccountModel(id: 'ACC-202', name: 'Trade Payables — Bullion Wholesalers', type: AccountType.liability, category: AccountCategory.payables, openingBalance: 1500000.0, currentBalance: 2100000.0, createdAt: now),
      AccountModel(id: 'ACC-203', name: 'Statutory & Tax Payables (Mock)', type: AccountType.liability, category: AccountCategory.otherLiabilities, openingBalance: 220000.0, currentBalance: 310000.0, createdAt: now),

      // Equity
      AccountModel(id: 'ACC-301', name: 'Owner Capital — KaratCore Capital', type: AccountType.equity, category: AccountCategory.ownerCapital, openingBalance: 30000000.0, currentBalance: 30000000.0, createdAt: now),
      AccountModel(id: 'ACC-302', name: 'Retained Earnings', type: AccountType.equity, category: AccountCategory.retainedEarnings, openingBalance: 2374000.0, currentBalance: 2374000.0, createdAt: now),

      // Income
      AccountModel(id: 'ACC-401', name: 'Pledge Interest Income', type: AccountType.income, category: AccountCategory.interestIncome, openingBalance: 0.0, currentBalance: 2480000.0, createdAt: now),
      AccountModel(id: 'ACC-402', name: 'Retail Jewellery Sales', type: AccountType.income, category: AccountCategory.jewellerySales, openingBalance: 0.0, currentBalance: 6850000.0, createdAt: now),
      AccountModel(id: 'ACC-403', name: 'Making & Hallmarking Charges Income', type: AccountType.income, category: AccountCategory.serviceIncome, openingBalance: 0.0, currentBalance: 340000.0, createdAt: now),
      AccountModel(id: 'ACC-404', name: 'Miscellaneous Income', type: AccountType.income, category: AccountCategory.otherIncome, openingBalance: 0.0, currentBalance: 95000.0, createdAt: now),

      // Expenses
      AccountModel(id: 'ACC-501', name: 'Store Rent & Lease', type: AccountType.expense, category: AccountCategory.rent, openingBalance: 0.0, currentBalance: 450000.0, createdAt: now),
      AccountModel(id: 'ACC-502', name: 'Staff Salaries & Wages', type: AccountType.expense, category: AccountCategory.salaries, openingBalance: 0.0, currentBalance: 920000.0, createdAt: now),
      AccountModel(id: 'ACC-503', name: 'Electricity & Utilities', type: AccountType.expense, category: AccountCategory.utilities, openingBalance: 0.0, currentBalance: 85000.0, createdAt: now),
      AccountModel(id: 'ACC-504', name: 'Vault Security & Maintenance', type: AccountType.expense, category: AccountCategory.maintenance, openingBalance: 0.0, currentBalance: 64000.0, createdAt: now),
      AccountModel(id: 'ACC-505', name: 'Armored Transport Services', type: AccountType.expense, category: AccountCategory.transportation, openingBalance: 0.0, currentBalance: 42000.0, createdAt: now),
      AccountModel(id: 'ACC-506', name: 'Local Marketing & Signage', type: AccountType.expense, category: AccountCategory.marketing, openingBalance: 0.0, currentBalance: 120000.0, createdAt: now),
      AccountModel(id: 'ACC-507', name: 'POS & Bank Processing Charges', type: AccountType.expense, category: AccountCategory.bankCharges, openingBalance: 0.0, currentBalance: 28000.0, createdAt: now),
      AccountModel(id: 'ACC-508', name: 'Office Stationery & Printing', type: AccountType.expense, category: AccountCategory.officeSupplies, openingBalance: 0.0, currentBalance: 18000.0, createdAt: now),
      AccountModel(id: 'ACC-509', name: 'Comprehensive Jewellery Insurance', type: AccountType.expense, category: AccountCategory.insurance, openingBalance: 0.0, currentBalance: 180000.0, createdAt: now),
      AccountModel(id: 'ACC-510', name: 'General Administrative Expenses', type: AccountType.expense, category: AccountCategory.otherExpenses, openingBalance: 0.0, currentBalance: 32000.0, createdAt: now),
    ]);

    // 2. Seed Periods
    _periods.addAll([
      AccountingPeriodModel(id: 'PRD-2026-FY', name: 'April 2026 – March 2027 (FY 2026-27)', startDate: DateTime(2026, 4, 1), endDate: DateTime(2027, 3, 31), status: 'Open'),
      AccountingPeriodModel(id: 'PRD-2026-05', name: 'May 2026', startDate: DateTime(2026, 5, 1), endDate: DateTime(2026, 5, 31), status: 'Closed'),
      AccountingPeriodModel(id: 'PRD-2026-06', name: 'June 2026', startDate: DateTime(2026, 6, 1), endDate: DateTime(2026, 6, 30), status: 'Closed'),
      AccountingPeriodModel(id: 'PRD-2026-07', name: 'July 2026', startDate: DateTime(2026, 7, 1), endDate: DateTime(2026, 7, 31), status: 'Open'),
      AccountingPeriodModel(id: 'PRD-2026-08', name: 'August 2026 (Current)', startDate: DateTime(2026, 8, 1), endDate: DateTime(2026, 8, 31), status: 'Open'),
    ]);

    // 3. Seed Income Records (15 items)
    for (int i = 1; i <= 15; i++) {
      _income.add(
        IncomeModel(
          id: 'INC-${1000 + i}',
          date: now.subtract(Duration(days: i * 2)),
          category: i % 2 == 0 ? AccountCategory.interestIncome : AccountCategory.jewellerySales,
          amount: (i * 12500.0) + 15000.0,
          paymentMethod: i % 3 == 0 ? 'Cash' : 'UPI / Bank Transfer',
          customerId: 'KC-CUS-00010${(i % 5) + 1}',
          customerName: 'Customer ${(i % 5) + 1}',
          reference: 'REC-${9000 + i}',
          description: i % 2 == 0 ? 'Gold loan interest repayment received' : 'Gold Bangle Retail Sale Invoice',
        ),
      );
    }

    // 4. Seed Expense Records (15 items)
    final expenseCats = [AccountCategory.rent, AccountCategory.salaries, AccountCategory.utilities, AccountCategory.marketing, AccountCategory.insurance];
    for (int i = 1; i <= 15; i++) {
      _expenses.add(
        ExpenseModel(
          id: 'EXP-${2000 + i}',
          date: now.subtract(Duration(days: i * 3)),
          category: expenseCats[i % expenseCats.length],
          amount: (i * 8500.0) + 5000.0,
          paymentMethod: i % 2 == 0 ? 'HDFC Bank NetBanking' : 'Cash',
          vendorName: 'Vendor Vendor-0${(i % 4) + 1}',
          reference: 'INV-${7000 + i}',
          description: 'Monthly business operational expense payment',
        ),
      );
    }

    // 5. Seed Receivables & Payables
    for (int i = 1; i <= 10; i++) {
      _receivables.add(
        ReceivableModel(
          id: 'REC-${3000 + i}',
          customerId: 'KC-CUS-00010${(i % 5) + 1}',
          customerName: 'Customer ${(i % 5) + 1}',
          reference: 'KC-LN-948$i',
          amountDue: (i * 15000.0) + 20000.0,
          dueDate: now.add(Duration(days: i * 4)),
          ageDays: i * 3,
          status: i < 4 ? 'Current' : (i < 7 ? 'Due Soon' : 'Overdue'),
          relatedLoanId: 'KC-LN-948$i',
        ),
      );

      _payables.add(
        PayableModel(
          id: 'PAY-${4000 + i}',
          vendorName: 'Bullion Merchant Pvt Ltd 0${(i % 3) + 1}',
          reference: 'BILL-${8000 + i}',
          amountDue: (i * 45000.0) + 50000.0,
          dueDate: now.add(Duration(days: i * 5)),
          ageDays: i * 4,
          status: i < 5 ? 'Current' : 'Due Soon',
          category: AccountCategory.payables,
        ),
      );
    }

    // 6. Seed Financial Transactions (100+ items)
    for (int i = 1; i <= 100; i++) {
      final isLoan = i % 4 == 0;
      final isPayment = i % 4 == 1;
      final isExpense = i % 4 == 2;

      _transactions.add(
        FinancialTransactionModel(
          id: 'KC-TX-${10000 + i}',
          date: now.subtract(Duration(days: i ~/ 2)),
          type: isLoan ? 'Loan Disbursement' : (isPayment ? 'Repayment' : 'Expense'),
          reference: isLoan ? 'KC-LN-948${(i % 30) + 1}' : 'TX-REF-$i',
          description: isLoan ? 'Gold Loan principal disbursement to Customer' : 'Financial ledger entry #$i',
          debitAccountId: isLoan ? 'ACC-106' : (isExpense ? 'ACC-501' : 'ACC-101'),
          debitAccountName: isLoan ? 'Loans Receivable — Gold Pledges' : (isExpense ? 'Store Rent & Lease' : 'Cash in Vault'),
          creditAccountId: isLoan ? 'ACC-102' : 'ACC-401',
          creditAccountName: isLoan ? 'HDFC Bank Main Operating Account' : 'Pledge Interest Income',
          amount: (i * 2500.0) + 10000.0,
          sourceModule: isLoan ? SourceModule.loan : (isPayment ? SourceModule.payment : SourceModule.expense),
          sourceId: isLoan ? 'KC-LN-948${(i % 30) + 1}' : 'SRC-$i',
          createdBy: i % 2 == 0 ? 'Arjun Mehta' : 'Priya Sharma',
        ),
      );
    }

    // 7. Seed Journal Entries (10 items)
    for (int i = 1; i <= 10; i++) {
      final amt = i * 25000.0;
      _journals.add(
        JournalEntryModel(
          id: 'JNL-${5000 + i}',
          date: now.subtract(Duration(days: i * 3)),
          reference: 'JV-2026-${100 + i}',
          description: 'Quarterly adjustment entry for accrued interest & depreciation',
          lines: [
            JournalLineModel(lineId: 'L-1', accountId: 'ACC-107', accountName: 'Interest Receivable — Accrued', debit: amt, credit: 0.0, description: 'Accrued interest debit'),
            JournalLineModel(lineId: 'L-2', accountId: 'ACC-401', accountName: 'Pledge Interest Income', debit: 0.0, credit: amt, description: 'Interest income credit'),
          ],
          notes: 'Approved by Chief Accountant',
          createdBy: 'Chief Accountant',
        ),
      );
    }

    // 8. Seed Audit Logs
    _auditLogs.addAll([
      AccountingAuditLogModel(id: 'AUD-101', timestamp: now.subtract(const Duration(hours: 2)), action: 'Journal Created', description: 'Created Manual Journal Entry JNL-5010', actorName: 'Arjun Mehta', role: 'Chief Accountant'),
      AccountingAuditLogModel(id: 'AUD-102', timestamp: now.subtract(const Duration(hours: 5)), action: 'Expense Recorded', description: 'Posted store electricity expense EXP-2005 ₹14,500', actorName: 'Priya Sharma', role: 'Teller Staff'),
      AccountingAuditLogModel(id: 'AUD-103', timestamp: now.subtract(const Duration(days: 1)), action: 'Period Closed', description: 'Closed Accounting Period June 2026', actorName: 'System Admin', role: 'Administrator'),
    ]);
  }

  @override
  Future<List<AccountModel>> getAccounts({AccountType? type}) async {
    if (type == null) return List.unmodifiable(_accounts);
    return _accounts.where((a) => a.type == type).toList();
  }

  @override
  Future<AccountModel?> getAccountById(String id) async {
    final matches = _accounts.where((a) => a.id == id);
    return matches.isNotEmpty ? matches.first : null;
  }

  @override
  Future<AccountModel> createAccount(AccountModel account) async {
    _accounts.add(account);
    _auditLogs.insert(0, AccountingAuditLogModel(id: 'AUD-${_auditLogs.length + 100}', timestamp: DateTime.now(), action: 'Account Created', description: 'Created Chart of Accounts entry ${account.id} (${account.name})', actorName: 'Manager', role: 'Accountant'));
    return account;
  }

  @override
  Future<AccountModel> updateAccount(AccountModel account) async {
    final idx = _accounts.indexWhere((a) => a.id == account.id);
    if (idx != -1) {
      _accounts[idx] = account;
    }
    return account;
  }

  @override
  Future<void> archiveAccount(String id) async {
    final idx = _accounts.indexWhere((a) => a.id == id);
    if (idx != -1) {
      _accounts[idx] = _accounts[idx].copyWith(status: 'Archived');
    }
  }

  @override
  Future<List<JournalEntryModel>> getJournalEntries() async {
    return List.unmodifiable(_journals);
  }

  @override
  Future<JournalEntryModel> createJournalEntry(JournalEntryModel entry) async {
    _journals.insert(0, entry);
    _auditLogs.insert(0, AccountingAuditLogModel(id: 'AUD-${_auditLogs.length + 100}', timestamp: DateTime.now(), action: 'Journal Created', description: 'Created Journal Entry ${entry.id} (${entry.reference})', actorName: entry.createdBy, role: 'Accountant'));
    return entry;
  }

  @override
  Future<List<FinancialTransactionModel>> getTransactions({
    String? accountId,
    SourceModule? sourceModule,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var result = List<FinancialTransactionModel>.from(_transactions);

    if (accountId != null && accountId.isNotEmpty) {
      result = result.where((t) => t.debitAccountId == accountId || t.creditAccountId == accountId).toList();
    }
    if (sourceModule != null) {
      result = result.where((t) => t.sourceModule == sourceModule).toList();
    }
    if (startDate != null) {
      result = result.where((t) => t.date.isAfter(startDate.subtract(const Duration(seconds: 1)))).toList();
    }
    if (endDate != null) {
      result = result.where((t) => t.date.isBefore(endDate.add(const Duration(days: 1)))).toList();
    }

    return result;
  }

  @override
  Future<FinancialTransactionModel?> getTransactionById(String id) async {
    final matches = _transactions.where((t) => t.id == id);
    return matches.isNotEmpty ? matches.first : null;
  }

  @override
  Future<FinancialTransactionModel> createTransaction(FinancialTransactionModel tx) async {
    _transactions.insert(0, tx);
    _auditLogs.insert(0, AccountingAuditLogModel(id: 'AUD-${_auditLogs.length + 100}', timestamp: DateTime.now(), action: 'Transaction Posted', description: 'Posted Financial Transaction ${tx.id} ₹${tx.amount.toStringAsFixed(0)}', actorName: tx.createdBy, role: 'Accountant'));
    return tx;
  }

  @override
  Future<FinancialTransactionModel> reverseTransaction({
    required String transactionId,
    required String reason,
    required String reversedBy,
  }) async {
    final idx = _transactions.indexWhere((t) => t.id == transactionId);
    if (idx == -1) throw Exception('Transaction not found');

    final orig = _transactions[idx];
    final now = DateTime.now();
    final revId = 'REV-${orig.id}';

    // Create reversing transaction with swapped Debit and Credit
    final revTx = FinancialTransactionModel(
      id: revId,
      date: now,
      type: 'Transaction Reversal',
      reference: 'REV-${orig.reference}',
      description: 'REVERSAL of ${orig.id}: $reason',
      debitAccountId: orig.creditAccountId,
      debitAccountName: orig.creditAccountName,
      creditAccountId: orig.debitAccountId,
      creditAccountName: orig.debitAccountName,
      amount: orig.amount,
      sourceModule: orig.sourceModule,
      sourceId: orig.sourceId,
      createdBy: reversedBy,
      status: 'Reversed',
    );

    _transactions[idx] = FinancialTransactionModel(
      id: orig.id,
      date: orig.date,
      type: orig.type,
      reference: orig.reference,
      description: orig.description,
      debitAccountId: orig.debitAccountId,
      debitAccountName: orig.debitAccountName,
      creditAccountId: orig.creditAccountId,
      creditAccountName: orig.creditAccountName,
      amount: orig.amount,
      sourceModule: orig.sourceModule,
      sourceId: orig.sourceId,
      createdBy: orig.createdBy,
      status: 'Reversed',
      isReversed: true,
      reversalTransactionId: revId,
    );

    _transactions.insert(0, revTx);
    _auditLogs.insert(0, AccountingAuditLogModel(id: 'AUD-${_auditLogs.length + 100}', timestamp: now, action: 'Transaction Reversed', description: 'Reversed transaction ${orig.id} — Reason: $reason', actorName: reversedBy, role: 'Manager'));

    return revTx;
  }

  @override
  Future<List<FinancialTransactionModel>> getCashMovements() async {
    return _transactions.where((t) => t.debitAccountId == 'ACC-101' || t.creditAccountId == 'ACC-101').toList();
  }

  @override
  Future<List<FinancialTransactionModel>> getBankMovements() async {
    return _transactions.where((t) => t.debitAccountId == 'ACC-102' || t.creditAccountId == 'ACC-102' || t.debitAccountId == 'ACC-103' || t.creditAccountId == 'ACC-103').toList();
  }

  @override
  Future<FinancialTransactionModel> transferCashBank({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    required String reference,
    required String description,
    required String createdBy,
  }) async {
    final now = DateTime.now();
    final fromAcc = await getAccountById(fromAccountId);
    final toAcc = await getAccountById(toAccountId);

    final tx = FinancialTransactionModel(
      id: 'KC-TX-${now.millisecondsSinceEpoch.toString().substring(5)}',
      date: now,
      type: 'Cash / Bank Transfer',
      reference: reference,
      description: description,
      debitAccountId: toAccountId,
      debitAccountName: toAcc?.name ?? 'Target Account',
      creditAccountId: fromAccountId,
      creditAccountName: fromAcc?.name ?? 'Source Account',
      amount: amount,
      sourceModule: SourceModule.manualEntry,
      sourceId: reference,
      createdBy: createdBy,
    );

    return await createTransaction(tx);
  }

  @override
  Future<List<IncomeModel>> getIncome() async => List.unmodifiable(_income);

  @override
  Future<IncomeModel> createIncome(IncomeModel income) async {
    _income.insert(0, income);
    _auditLogs.insert(0, AccountingAuditLogModel(id: 'AUD-${_auditLogs.length + 100}', timestamp: DateTime.now(), action: 'Income Created', description: 'Recorded income ${income.id} ₹${income.amount.toStringAsFixed(0)}', actorName: 'Cashier', role: 'Staff'));
    return income;
  }

  @override
  Future<List<ExpenseModel>> getExpenses() async => List.unmodifiable(_expenses);

  @override
  Future<ExpenseModel> createExpense(ExpenseModel expense) async {
    _expenses.insert(0, expense);
    _auditLogs.insert(0, AccountingAuditLogModel(id: 'AUD-${_auditLogs.length + 100}', timestamp: DateTime.now(), action: 'Expense Created', description: 'Recorded expense ${expense.id} ₹${expense.amount.toStringAsFixed(0)}', actorName: 'Accountant', role: 'Staff'));
    return expense;
  }

  @override
  Future<List<ReceivableModel>> getReceivables() async => List.unmodifiable(_receivables);

  @override
  Future<List<PayableModel>> getPayables() async => List.unmodifiable(_payables);

  @override
  Future<List<AccountingPeriodModel>> getPeriods() async => List.unmodifiable(_periods);

  @override
  Future<AccountingPeriodModel> closePeriod(String periodId) async {
    final idx = _periods.indexWhere((p) => p.id == periodId);
    if (idx != -1) {
      final p = _periods[idx];
      _periods[idx] = AccountingPeriodModel(id: p.id, name: p.name, startDate: p.startDate, endDate: p.endDate, status: 'Closed');
      _auditLogs.insert(0, AccountingAuditLogModel(id: 'AUD-${_auditLogs.length + 100}', timestamp: DateTime.now(), action: 'Period Closed', description: 'Closed Accounting Period ${p.name}', actorName: 'Manager', role: 'Administrator'));
      return _periods[idx];
    }
    throw Exception('Period not found');
  }

  @override
  Future<List<AccountingAuditLogModel>> getAuditLogs() async => List.unmodifiable(_auditLogs);

  @override
  Future<AccountingDashboardMetrics> getDashboardMetrics(AccountingPeriodModel? period) async {
    final cashAcc = _accounts.firstWhere((a) => a.id == 'ACC-101', orElse: () => _accounts.first);
    final bankAcc = _accounts.firstWhere((a) => a.id == 'ACC-102', orElse: () => _accounts.first);
    final goldAcc = _accounts.firstWhere((a) => a.id == 'ACC-104', orElse: () => _accounts.first);

    final totalInc = _income.fold(0.0, (sum, i) => sum + i.amount);
    final totalExp = _expenses.fold(0.0, (sum, e) => sum + e.amount);
    final netProf = totalInc - totalExp;

    final recTotal = _receivables.fold(0.0, (sum, r) => sum + r.amountDue);
    final payTotal = _payables.fold(0.0, (sum, p) => sum + p.amountDue);

    return AccountingDashboardMetrics(
      cashBalance: cashAcc.currentBalance,
      bankBalance: bankAcc.currentBalance,
      totalIncome: totalInc,
      totalExpenses: totalExp,
      netProfit: netProf,
      receivablesTotal: recTotal,
      payablesTotal: payTotal,
      loanOutstandingTotal: 14250000.0,
      interestIncomeTotal: 2480000.0,
      inventoryValueTotal: goldAcc.currentBalance,
    );
  }
}
