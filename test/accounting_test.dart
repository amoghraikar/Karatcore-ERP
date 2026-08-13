import 'package:flutter_test/flutter_test.dart';
import 'package:karatcore_erp/features/accounting/models/accounting_model.dart';
import 'package:karatcore_erp/features/accounting/services/accounting_calculation_service.dart';

void main() {
  group('Accounting & Financial Bookkeeping Unit Tests', () {
    late IAccountingCalculationService calcService;

    setUp(() {
      calcService = AccountingCalculationService();
    });

    test('Trial Balance calculation verifies debit/credit equality', () {
      final accounts = [
        AccountModel(
          id: 'ACC-101',
          name: 'Cash Desk',
          type: AccountType.asset,
          category: AccountCategory.cash,
          openingBalance: 100000,
          currentBalance: 100000,
          createdAt: DateTime.now(),
        ),
        AccountModel(
          id: 'ACC-301',
          name: 'Owner Capital',
          type: AccountType.equity,
          category: AccountCategory.ownerCapital,
          openingBalance: 100000,
          currentBalance: 100000,
          createdAt: DateTime.now(),
        ),
      ];

      final tb = calcService.calculateTrialBalance(accounts);

      expect(tb.totalDebit, equals(100000));
      expect(tb.totalCredit, equals(100000));
      expect(tb.isBalanced, isTrue);
    });

    test('Profit & Loss calculation computes Net Profit correctly (Revenue - Expenses)', () {
      final income = [
        IncomeModel(
          id: 'INC-1',
          date: DateTime.now(),
          category: AccountCategory.interestIncome,
          amount: 50000,
          paymentMethod: 'Cash',
          customerId: 'CUS-01',
          customerName: 'Test Customer',
          reference: 'REF-01',
          description: 'Loan Interest Yield',
        ),
      ];
      final expenses = [
        ExpenseModel(
          id: 'EXP-1',
          date: DateTime.now(),
          category: AccountCategory.rent,
          amount: 15000,
          paymentMethod: 'Bank',
          vendorName: 'Landlord',
          reference: 'REF-02',
          description: 'Store Rent',
        ),
      ];

      final pl = calcService.calculateProfitLoss(income, expenses);

      expect(pl.totalRevenue, equals(50000));
      expect(pl.totalExpenses, equals(15000));
      expect(pl.netProfit, equals(35000));
    });
  });
}
