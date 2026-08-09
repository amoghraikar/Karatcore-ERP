import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/accounting_model.dart';
import '../repository/accounting_repository.dart';
import '../repository/mock_accounting_repository.dart';
import '../services/accounting_calculation_service.dart';
import '../services/accounting_integration_service.dart';

final accountingRepositoryProvider = Provider<IAccountingRepository>((ref) {
  return MockAccountingRepository();
});

final accountingCalculationServiceProvider = Provider<IAccountingCalculationService>((ref) {
  return MockAccountingCalculationService();
});

final accountingIntegrationServiceProvider = Provider<IAccountingIntegrationService>((ref) {
  final repo = ref.watch(accountingRepositoryProvider);
  return MockAccountingIntegrationService(repo);
});

// Accounting Period State
final selectedAccountingPeriodProvider = StateProvider<AccountingPeriodModel?>((ref) => null);

final accountingPeriodsProvider = FutureProvider<List<AccountingPeriodModel>>((ref) async {
  final repo = ref.watch(accountingRepositoryProvider);
  return await repo.getPeriods();
});

// Dashboard Metrics Provider
final accountingDashboardMetricsProvider = FutureProvider<AccountingDashboardMetrics>((ref) async {
  final repo = ref.watch(accountingRepositoryProvider);
  final selectedPeriod = ref.watch(selectedAccountingPeriodProvider);
  return await repo.getDashboardMetrics(selectedPeriod);
});

// Accounts Providers
final chartOfAccountsProvider = FutureProvider.family<List<AccountModel>, AccountType?>((ref, type) async {
  final repo = ref.watch(accountingRepositoryProvider);
  return await repo.getAccounts(type: type);
});

final accountDetailProvider = FutureProvider.family<AccountModel?, String>((ref, id) async {
  final repo = ref.watch(accountingRepositoryProvider);
  return await repo.getAccountById(id);
});

// Journal Entries Provider
class JournalEntriesNotifier extends AsyncNotifier<List<JournalEntryModel>> {
  @override
  Future<List<JournalEntryModel>> build() async {
    final repo = ref.read(accountingRepositoryProvider);
    return await repo.getJournalEntries();
  }

  Future<void> addJournalEntry(JournalEntryModel entry) async {
    final repo = ref.read(accountingRepositoryProvider);
    await repo.createJournalEntry(entry);
    ref.invalidateSelf();
    ref.invalidate(chartOfAccountsProvider);
    ref.invalidate(accountingDashboardMetricsProvider);
  }
}

final journalEntriesProvider = AsyncNotifierProvider<JournalEntriesNotifier, List<JournalEntryModel>>(() {
  return JournalEntriesNotifier();
});

// Financial Transactions Notifier & Provider
class FinancialTransactionsNotifier extends AsyncNotifier<List<FinancialTransactionModel>> {
  @override
  Future<List<FinancialTransactionModel>> build() async {
    final repo = ref.read(accountingRepositoryProvider);
    return await repo.getTransactions();
  }

  Future<void> addTransaction(FinancialTransactionModel tx) async {
    final repo = ref.read(accountingRepositoryProvider);
    await repo.createTransaction(tx);
    ref.invalidateSelf();
    ref.invalidate(accountingDashboardMetricsProvider);
  }

  Future<void> reverseTx(String id, String reason, String reversedBy) async {
    final repo = ref.read(accountingRepositoryProvider);
    await repo.reverseTransaction(transactionId: id, reason: reason, reversedBy: reversedBy);
    ref.invalidateSelf();
    ref.invalidate(accountingDashboardMetricsProvider);
  }
}

final financialTransactionsProvider = AsyncNotifierProvider<FinancialTransactionsNotifier, List<FinancialTransactionModel>>(() {
  return FinancialTransactionsNotifier();
});

final transactionDetailProvider = FutureProvider.family<FinancialTransactionModel?, String>((ref, id) async {
  final repo = ref.watch(accountingRepositoryProvider);
  return await repo.getTransactionById(id);
});

// Cash & Bank Movements Providers
final cashBookMovementsProvider = FutureProvider<List<FinancialTransactionModel>>((ref) async {
  final repo = ref.watch(accountingRepositoryProvider);
  return await repo.getCashMovements();
});

final bankBookMovementsProvider = FutureProvider<List<FinancialTransactionModel>>((ref) async {
  final repo = ref.watch(accountingRepositoryProvider);
  return await repo.getBankMovements();
});

// Income & Expenses Notifiers & Providers
class IncomeListNotifier extends AsyncNotifier<List<IncomeModel>> {
  @override
  Future<List<IncomeModel>> build() async {
    final repo = ref.read(accountingRepositoryProvider);
    return await repo.getIncome();
  }

  Future<void> addIncome(IncomeModel income) async {
    final repo = ref.read(accountingRepositoryProvider);
    await repo.createIncome(income);
    final integration = ref.read(accountingIntegrationServiceProvider);
    await integration.recordIncomeTransaction(income);

    ref.invalidateSelf();
    ref.invalidate(accountingDashboardMetricsProvider);
  }
}

final incomeListProvider = AsyncNotifierProvider<IncomeListNotifier, List<IncomeModel>>(() {
  return IncomeListNotifier();
});

class ExpenseListNotifier extends AsyncNotifier<List<ExpenseModel>> {
  @override
  Future<List<ExpenseModel>> build() async {
    final repo = ref.read(accountingRepositoryProvider);
    return await repo.getExpenses();
  }

  Future<void> addExpense(ExpenseModel expense) async {
    final repo = ref.read(accountingRepositoryProvider);
    await repo.createExpense(expense);
    final integration = ref.read(accountingIntegrationServiceProvider);
    await integration.recordExpenseTransaction(expense);

    ref.invalidateSelf();
    ref.invalidate(accountingDashboardMetricsProvider);
  }
}

final expenseListProvider = AsyncNotifierProvider<ExpenseListNotifier, List<ExpenseModel>>(() {
  return ExpenseListNotifier();
});

// Receivables & Payables Providers
final receivablesListProvider = FutureProvider<List<ReceivableModel>>((ref) async {
  final repo = ref.watch(accountingRepositoryProvider);
  return await repo.getReceivables();
});

final payablesListProvider = FutureProvider<List<PayableModel>>((ref) async {
  final repo = ref.watch(accountingRepositoryProvider);
  return await repo.getPayables();
});

// Financial Statements Providers
final trialBalanceProvider = FutureProvider<TrialBalanceResult>((ref) async {
  final repo = ref.watch(accountingRepositoryProvider);
  final calc = ref.watch(accountingCalculationServiceProvider);
  final accounts = await repo.getAccounts();
  return calc.calculateTrialBalance(accounts);
});

final profitLossProvider = FutureProvider<ProfitLossResult>((ref) async {
  final repo = ref.watch(accountingRepositoryProvider);
  final calc = ref.watch(accountingCalculationServiceProvider);
  final income = await repo.getIncome();
  final expenses = await repo.getExpenses();
  return calc.calculateProfitLoss(income, expenses);
});

final balanceSheetProvider = FutureProvider<BalanceSheetResult>((ref) async {
  final repo = ref.watch(accountingRepositoryProvider);
  final calc = ref.watch(accountingCalculationServiceProvider);
  final accounts = await repo.getAccounts();
  final pl = await ref.watch(profitLossProvider.future);
  return calc.calculateBalanceSheet(accounts, pl.netProfit);
});

final cashFlowProvider = FutureProvider<Map<String, double>>((ref) async {
  final repo = ref.watch(accountingRepositoryProvider);
  final calc = ref.watch(accountingCalculationServiceProvider);
  final txs = await repo.getTransactions();
  return calc.calculateCashFlow(txs);
});

// Audit Logs Provider
final accountingAuditLogsProvider = FutureProvider<List<AccountingAuditLogModel>>((ref) async {
  final repo = ref.watch(accountingRepositoryProvider);
  return await repo.getAuditLogs();
});
