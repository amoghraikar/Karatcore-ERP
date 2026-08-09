import '../models/accounting_model.dart';

class AccountingDashboardMetrics {
  const AccountingDashboardMetrics({
    required this.cashBalance,
    required this.bankBalance,
    required this.totalIncome,
    required this.totalExpenses,
    required this.netProfit,
    required this.receivablesTotal,
    required this.payablesTotal,
    required this.loanOutstandingTotal,
    required this.interestIncomeTotal,
    required this.inventoryValueTotal,
  });

  final double cashBalance;
  final double bankBalance;
  final double totalIncome;
  final double totalExpenses;
  final double netProfit;
  final double receivablesTotal;
  final double payablesTotal;
  final double loanOutstandingTotal;
  final double interestIncomeTotal;
  final double inventoryValueTotal;
}

abstract class IAccountingRepository {
  Future<List<AccountModel>> getAccounts({AccountType? type});
  Future<AccountModel?> getAccountById(String id);
  Future<AccountModel> createAccount(AccountModel account);
  Future<AccountModel> updateAccount(AccountModel account);
  Future<void> archiveAccount(String id);

  Future<List<JournalEntryModel>> getJournalEntries();
  Future<JournalEntryModel> createJournalEntry(JournalEntryModel entry);

  Future<List<FinancialTransactionModel>> getTransactions({
    String? accountId,
    SourceModule? sourceModule,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<FinancialTransactionModel?> getTransactionById(String id);
  Future<FinancialTransactionModel> createTransaction(FinancialTransactionModel tx);
  Future<FinancialTransactionModel> reverseTransaction({
    required String transactionId,
    required String reason,
    required String reversedBy,
  });

  Future<List<FinancialTransactionModel>> getCashMovements();
  Future<List<FinancialTransactionModel>> getBankMovements();
  Future<FinancialTransactionModel> transferCashBank({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    required String reference,
    required String description,
    required String createdBy,
  });

  Future<List<IncomeModel>> getIncome();
  Future<IncomeModel> createIncome(IncomeModel income);

  Future<List<ExpenseModel>> getExpenses();
  Future<ExpenseModel> createExpense(ExpenseModel expense);

  Future<List<ReceivableModel>> getReceivables();
  Future<List<PayableModel>> getPayables();

  Future<List<AccountingPeriodModel>> getPeriods();
  Future<AccountingPeriodModel> closePeriod(String periodId);

  Future<List<AccountingAuditLogModel>> getAuditLogs();
  Future<AccountingDashboardMetrics> getDashboardMetrics(AccountingPeriodModel? period);
}
