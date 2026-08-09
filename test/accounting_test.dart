import 'package:flutter_test/flutter_test.dart';
import 'package:karatcore_erp/features/accounting/models/accounting_model.dart';
import 'package:karatcore_erp/features/accounting/repository/accounting_repository.dart';
import 'package:karatcore_erp/features/accounting/repository/mock_accounting_repository.dart';
import 'package:karatcore_erp/features/accounting/services/accounting_calculation_service.dart';

void main() {
  group('Accounting & Financial Bookkeeping Unit Tests', () {
    late IAccountingRepository repo;
    late IAccountingCalculationService calcService;

    setUp(() {
      repo = MockAccountingRepository();
      calcService = MockAccountingCalculationService();
    });

    test('MockAccountingRepository seeds 25+ accounts and 100+ transactions', () async {
      final accounts = await repo.getAccounts();
      final txs = await repo.getTransactions();
      final journals = await repo.getJournalEntries();

      expect(accounts.length, greaterThanOrEqualTo(25));
      expect(txs.length, greaterThanOrEqualTo(100));
      expect(journals.length, greaterThanOrEqualTo(10));
    });

    test('Trial Balance calculation verifies debit/credit equality', () async {
      final accounts = await repo.getAccounts();
      final tb = calcService.calculateTrialBalance(accounts);

      expect(tb.totalDebit, greaterThan(0));
      expect(tb.totalCredit, greaterThan(0));
      expect(tb.isBalanced, isTrue);
    });

    test('Profit & Loss calculation computes Net Profit correctly (Revenue - Expenses)', () async {
      final income = await repo.getIncome();
      final expenses = await repo.getExpenses();
      final pl = calcService.calculateProfitLoss(income, expenses);

      expect(pl.totalRevenue, greaterThan(0));
      expect(pl.totalExpenses, greaterThan(0));
      expect(pl.netProfit, equals(pl.totalRevenue - pl.totalExpenses));
    });

    test('Balance Sheet equality holds (Assets == Liabilities + Equity)', () async {
      final accounts = await repo.getAccounts();
      final incomeTotal = accounts.where((a) => a.type == AccountType.income).fold(0.0, (sum, a) => sum + a.currentBalance);
      final expenseTotal = accounts.where((a) => a.type == AccountType.expense).fold(0.0, (sum, a) => sum + a.currentBalance);
      final netProfit = incomeTotal - expenseTotal;
      final bs = calcService.calculateBalanceSheet(accounts, netProfit);

      expect(bs.totalAssets, greaterThan(0));
      expect(bs.totalLiabilities, greaterThan(0));
      expect(bs.totalEquity, greaterThan(0));
      expect(bs.isBalanced, isTrue);
    });

    test('Journal entry validation rejects unbalanced double-entries', () {
      const line1 = JournalLineModel(lineId: '1', accountId: 'ACC-101', accountName: 'Cash', debit: 500.0, credit: 0.0, description: 'Debit');
      const line2 = JournalLineModel(lineId: '2', accountId: 'ACC-401', accountName: 'Income', debit: 0.0, credit: 400.0, description: 'Credit');

      final entry = JournalEntryModel(
        id: 'JNL-TEST',
        date: DateTime.now(),
        reference: 'REF-001',
        description: 'Test',
        lines: [line1, line2],
        createdBy: 'Tester',
      );

      expect(entry.isBalanced, isFalse);
    });

    test('Transaction Reversal creates reversing transaction with swapped accounts', () async {
      final txs = await repo.getTransactions();
      final target = txs.first;

      final rev = await repo.reverseTransaction(
        transactionId: target.id,
        reason: 'Duplicate entry correction',
        reversedBy: 'Manager',
      );

      expect(rev.status, equals('Reversed'));
      expect(rev.debitAccountId, equals(target.creditAccountId));
      expect(rev.creditAccountId, equals(target.debitAccountId));
    });

    test('Period closure locks accounting period', () async {
      final closed = await repo.closePeriod('PRD-2026-07');
      expect(closed.status, equals('Closed'));
      expect(closed.isClosed, isTrue);
    });
  });
}
