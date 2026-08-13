import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/accounting_model.dart';
import 'accounting_repository.dart';

class ApiAccountingRepository implements IAccountingRepository {
  ApiAccountingRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<AccountModel>> getAccounts({AccountType? type}) async {
    try {
      final dynamic data = await _api.get(
        type != null ? '${ApiEndpoints.accountingAccounts}?type=${type.name}' : ApiEndpoints.accountingAccounts,
      );
      if (data is List) {
        return data.map((json) => _parseAccountFromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<AccountModel?> getAccountById(String id) async {
    try {
      final dynamic data = await _api.get('${ApiEndpoints.accountingAccounts}/$id');
      return _parseAccountFromJson(data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AccountModel> createAccount(AccountModel account) async {
    final dynamic data = await _api.post(
      ApiEndpoints.accountingAccounts,
      body: _accountToJson(account),
    );
    return _parseAccountFromJson(data as Map<String, dynamic>);
  }

  @override
  Future<AccountModel> updateAccount(AccountModel account) async {
    final dynamic data = await _api.put(
      '${ApiEndpoints.accountingAccounts}/${account.id}',
      body: _accountToJson(account),
    );
    return _parseAccountFromJson(data as Map<String, dynamic>);
  }

  @override
  Future<void> archiveAccount(String id) async {
    await _api.delete('${ApiEndpoints.accountingAccounts}/$id');
  }

  @override
  Future<List<JournalEntryModel>> getJournalEntries() async {
    try {
      final dynamic data = await _api.get(ApiEndpoints.accountingJournal);
      if (data is List) {
        return data.map((json) => _parseJournalFromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<JournalEntryModel> createJournalEntry(JournalEntryModel entry) async {
    final dynamic data = await _api.post(
      ApiEndpoints.accountingJournal,
      body: {
        'date': entry.date.toIso8601String(),
        'reference': entry.reference,
        'description': entry.description,
        'created_by': entry.createdBy,
        'lines': entry.lines.map((i) => {
          'line_id': i.lineId,
          'account_id': i.accountId,
          'account_name': i.accountName,
          'debit': i.debit,
          'credit': i.credit,
          'description': i.description,
        }).toList(),
      },
    );
    return _parseJournalFromJson(data as Map<String, dynamic>);
  }

  @override
  Future<List<FinancialTransactionModel>> getTransactions({
    String? accountId,
    SourceModule? sourceModule,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final dynamic data = await _api.get(ApiEndpoints.accountingTransactions);
      if (data is List) {
        return data.map((json) => _parseTxFromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<FinancialTransactionModel?> getTransactionById(String id) async {
    try {
      final dynamic data = await _api.get('${ApiEndpoints.accountingTransactions}/$id');
      return _parseTxFromJson(data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<FinancialTransactionModel> createTransaction(FinancialTransactionModel tx) async {
    final dynamic data = await _api.post(
      ApiEndpoints.accountingTransactions,
      body: _txToJson(tx),
    );
    return _parseTxFromJson(data as Map<String, dynamic>);
  }

  @override
  Future<FinancialTransactionModel> reverseTransaction({
    required String transactionId,
    required String reason,
    required String reversedBy,
  }) async {
    final dynamic data = await _api.post(
      '${ApiEndpoints.accountingTransactions}/$transactionId/reverse',
      body: {'reason': reason, 'reversed_by': reversedBy},
    );
    return _parseTxFromJson(data as Map<String, dynamic>);
  }

  @override
  Future<List<FinancialTransactionModel>> getCashMovements() async {
    return getTransactions(sourceModule: SourceModule.expense);
  }

  @override
  Future<List<FinancialTransactionModel>> getBankMovements() async {
    return getTransactions(sourceModule: SourceModule.income);
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
    final dynamic data = await _api.post(
      '${ApiEndpoints.accountingTransactions}/transfer',
      body: {
        'from_account_id': fromAccountId,
        'to_account_id': toAccountId,
        'amount': amount,
        'reference': reference,
        'description': description,
        'created_by': createdBy,
      },
    );
    return _parseTxFromJson(data as Map<String, dynamic>);
  }

  @override
  Future<List<IncomeModel>> getIncome() async {
    try {
      final dynamic data = await _api.get('${ApiEndpoints.accountingTransactions}/income');
      if (data is List) {
        return data.map((json) => _parseIncomeFromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<IncomeModel> createIncome(IncomeModel income) async {
    final dynamic data = await _api.post(
      '${ApiEndpoints.accountingTransactions}/income',
      body: {
        'date': income.date.toIso8601String(),
        'category': income.category.name,
        'amount': income.amount,
        'payment_method': income.paymentMethod,
        'customer_id': income.customerId,
        'customer_name': income.customerName,
        'reference': income.reference,
        'description': income.description,
        'status': income.status,
      },
    );
    return _parseIncomeFromJson(data as Map<String, dynamic>);
  }

  @override
  Future<List<ExpenseModel>> getExpenses() async {
    try {
      final dynamic data = await _api.get('${ApiEndpoints.accountingTransactions}/expenses');
      if (data is List) {
        return data.map((json) => _parseExpenseFromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<ExpenseModel> createExpense(ExpenseModel expense) async {
    final dynamic data = await _api.post(
      '${ApiEndpoints.accountingTransactions}/expenses',
      body: {
        'date': expense.date.toIso8601String(),
        'category': expense.category.name,
        'amount': expense.amount,
        'payment_method': expense.paymentMethod,
        'vendor_name': expense.vendorName,
        'reference': expense.reference,
        'description': expense.description,
        'status': expense.status,
      },
    );
    return _parseExpenseFromJson(data as Map<String, dynamic>);
  }

  @override
  Future<List<ReceivableModel>> getReceivables() async => [];

  @override
  Future<List<PayableModel>> getPayables() async => [];

  @override
  Future<List<AccountingPeriodModel>> getPeriods() async {
    try {
      final dynamic data = await _api.get('${ApiEndpoints.accountingTransactions}/periods');
      if (data is List && data.isNotEmpty) {
        return data.map((json) => AccountingPeriodModel(
          id: json['id'] as String,
          name: json['name'] as String? ?? '',
          startDate: DateTime.tryParse(json['start_date'] as String? ?? '') ?? DateTime.now(),
          endDate: DateTime.tryParse(json['end_date'] as String? ?? '') ?? DateTime.now(),
          status: json['status'] as String? ?? 'Open',
        )).toList();
      }
    } catch (_) {}

    final now = DateTime.now();
    return [
      AccountingPeriodModel(
        id: 'PRD-${now.year}-${now.month.toString().padLeft(2, '0')}',
        name: 'FY ${now.year} (Active)',
        startDate: DateTime(now.year, now.month, 1),
        endDate: DateTime(now.year, now.month + 1, 0),
        status: 'Open',
      ),
    ];
  }

  @override
  Future<AccountingPeriodModel> closePeriod(String periodId) async {
    final dynamic data = await _api.post('${ApiEndpoints.accountingTransactions}/periods/$periodId/close', body: {});
    return AccountingPeriodModel(
      id: periodId,
      name: data['name'] as String? ?? 'Closed Period',
      startDate: DateTime.tryParse(data['start_date'] as String? ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(data['end_date'] as String? ?? '') ?? DateTime.now(),
      status: 'Closed',
    );
  }

  @override
  Future<List<AccountingAuditLogModel>> getAuditLogs() async => [];

  @override
  Future<AccountingDashboardMetrics> getDashboardMetrics(AccountingPeriodModel? period) async {
    try {
      final dynamic data = await _api.get(ApiEndpoints.accountingMetrics);
      return AccountingDashboardMetrics(
        cashBalance: (data['cash_balance'] as num? ?? 0.0).toDouble(),
        bankBalance: (data['bank_balance'] as num? ?? 0.0).toDouble(),
        totalIncome: (data['total_income'] as num? ?? 0.0).toDouble(),
        totalExpenses: (data['total_expenses'] as num? ?? 0.0).toDouble(),
        netProfit: (data['net_profit'] as num? ?? 0.0).toDouble(),
        receivablesTotal: (data['receivables_total'] as num? ?? 0.0).toDouble(),
        payablesTotal: (data['payables_total'] as num? ?? 0.0).toDouble(),
        loanOutstandingTotal: (data['loan_outstanding_total'] as num? ?? 0.0).toDouble(),
        interestIncomeTotal: (data['interest_income_total'] as num? ?? 0.0).toDouble(),
        inventoryValueTotal: (data['inventory_value_total'] as num? ?? 0.0).toDouble(),
      );
    } catch (_) {
      return const AccountingDashboardMetrics(
        cashBalance: 0.0,
        bankBalance: 0.0,
        totalIncome: 0.0,
        totalExpenses: 0.0,
        netProfit: 0.0,
        receivablesTotal: 0.0,
        payablesTotal: 0.0,
        loanOutstandingTotal: 0.0,
        interestIncomeTotal: 0.0,
        inventoryValueTotal: 0.0,
      );
    }
  }

  AccountModel _parseAccountFromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      type: AccountType.values.firstWhere((e) => e.name == json['type'], orElse: () => AccountType.asset),
      category: AccountCategory.values.firstWhere((e) => e.name == json['category'], orElse: () => AccountCategory.cash),
      openingBalance: (json['opening_balance'] as num? ?? 0.0).toDouble(),
      currentBalance: (json['current_balance'] as num? ?? 0.0).toDouble(),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> _accountToJson(AccountModel a) => {
    'name': a.name,
    'type': a.type.name,
    'category': a.category.name,
    'opening_balance': a.openingBalance,
    'current_balance': a.currentBalance,
  };

  JournalEntryModel _parseJournalFromJson(Map<String, dynamic> json) {
    return JournalEntryModel(
      id: json['id'] as String,
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      reference: json['reference'] as String? ?? '',
      description: json['description'] as String? ?? '',
      lines: (json['lines'] as List? ?? []).map((i) => JournalLineModel(
        lineId: i['line_id'] as String? ?? '',
        accountId: i['account_id'] as String? ?? '',
        accountName: i['account_name'] as String? ?? '',
        debit: (i['debit'] as num? ?? 0.0).toDouble(),
        credit: (i['credit'] as num? ?? 0.0).toDouble(),
        description: i['description'] as String? ?? '',
      )).toList(),
      createdBy: json['created_by'] as String? ?? '',
    );
  }

  FinancialTransactionModel _parseTxFromJson(Map<String, dynamic> json) {
    return FinancialTransactionModel(
      id: json['id'] as String,
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      type: json['type'] as String? ?? 'Receipt',
      reference: json['reference'] as String? ?? '',
      description: json['description'] as String? ?? '',
      debitAccountId: json['debit_account_id'] as String? ?? '',
      debitAccountName: json['debit_account_name'] as String? ?? '',
      creditAccountId: json['credit_account_id'] as String? ?? '',
      creditAccountName: json['credit_account_name'] as String? ?? '',
      amount: (json['amount'] as num? ?? 0.0).toDouble(),
      sourceModule: SourceModule.values.firstWhere((e) => e.name == json['source_module'], orElse: () => SourceModule.loan),
      sourceId: json['source_id'] as String? ?? '',
      createdBy: json['created_by'] as String? ?? '',
      status: json['status'] as String? ?? 'Posted',
      isReversed: json['is_reversed'] as bool? ?? false,
      reversalTransactionId: json['reversal_transaction_id'] as String?,
    );
  }

  Map<String, dynamic> _txToJson(FinancialTransactionModel tx) => {
    'type': tx.type,
    'reference': tx.reference,
    'description': tx.description,
    'debit_account_id': tx.debitAccountId,
    'credit_account_id': tx.creditAccountId,
    'amount': tx.amount,
    'source_module': tx.sourceModule.name,
    'source_id': tx.sourceId,
    'created_by': tx.createdBy,
  };

  IncomeModel _parseIncomeFromJson(Map<String, dynamic> json) {
    return IncomeModel(
      id: json['id'] as String,
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      category: AccountCategory.values.firstWhere((e) => e.name == json['category'], orElse: () => AccountCategory.interestIncome),
      amount: (json['amount'] as num? ?? 0.0).toDouble(),
      paymentMethod: json['payment_method'] as String? ?? 'Cash',
      customerId: json['customer_id'] as String? ?? '',
      customerName: json['customer_name'] as String? ?? '',
      reference: json['reference'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'Received',
    );
  }

  ExpenseModel _parseExpenseFromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as String,
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      category: AccountCategory.values.firstWhere((e) => e.name == json['category'], orElse: () => AccountCategory.rent),
      amount: (json['amount'] as num? ?? 0.0).toDouble(),
      paymentMethod: json['payment_method'] as String? ?? 'Cash',
      vendorName: json['vendor_name'] as String? ?? '',
      reference: json['reference'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'Paid',
    );
  }
}
