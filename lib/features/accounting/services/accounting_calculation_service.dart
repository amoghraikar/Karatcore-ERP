import '../models/accounting_model.dart';

class TrialBalanceResult {
  const TrialBalanceResult({
    required this.totalDebit,
    required this.totalCredit,
    required this.difference,
    required this.isBalanced,
  });

  final double totalDebit;
  final double totalCredit;
  final double difference;
  final bool isBalanced;
}

class ProfitLossResult {
  const ProfitLossResult({
    required this.totalRevenue,
    required this.interestIncome,
    required this.jewellerySales,
    required this.otherIncome,
    required this.totalExpenses,
    required this.operatingExpenses,
    required this.netProfit,
  });

  final double totalRevenue;
  final double interestIncome;
  final double jewellerySales;
  final double otherIncome;
  final double totalExpenses;
  final double operatingExpenses;
  final double netProfit;
}

class BalanceSheetResult {
  const BalanceSheetResult({
    required this.totalAssets,
    required this.totalLiabilities,
    required this.totalEquity,
    required this.isBalanced,
  });

  final double totalAssets;
  final double totalLiabilities;
  final double totalEquity;
  final bool isBalanced; // Assets == Liabilities + Equity
}

abstract class IAccountingCalculationService {
  TrialBalanceResult calculateTrialBalance(List<AccountModel> accounts);
  ProfitLossResult calculateProfitLoss(List<IncomeModel> income, List<ExpenseModel> expenses);
  BalanceSheetResult calculateBalanceSheet(List<AccountModel> accounts, double currentProfit);
  Map<String, double> calculateCashFlow(List<FinancialTransactionModel> transactions);
}

class MockAccountingCalculationService implements IAccountingCalculationService {
  @override
  TrialBalanceResult calculateTrialBalance(List<AccountModel> accounts) {
    double debitSum = 0.0;
    double creditSum = 0.0;

    for (final acc in accounts) {
      if (acc.type == AccountType.asset || acc.type == AccountType.expense) {
        debitSum += acc.currentBalance.abs();
      } else {
        creditSum += acc.currentBalance.abs();
      }
    }

    final diff = (debitSum - creditSum).abs();
    return TrialBalanceResult(
      totalDebit: debitSum,
      totalCredit: creditSum,
      difference: diff,
      isBalanced: diff < 0.01,
    );
  }

  @override
  ProfitLossResult calculateProfitLoss(List<IncomeModel> income, List<ExpenseModel> expenses) {
    double interestInc = 0.0;
    double jewellerySales = 0.0;
    double otherInc = 0.0;

    for (final inc in income) {
      if (inc.category == AccountCategory.interestIncome) {
        interestInc += inc.amount;
      } else if (inc.category == AccountCategory.jewellerySales) {
        jewellerySales += inc.amount;
      } else {
        otherInc += inc.amount;
      }
    }

    final totalRev = interestInc + jewellerySales + otherInc;
    final totalExp = expenses.fold(0.0, (sum, exp) => sum + exp.amount);

    return ProfitLossResult(
      totalRevenue: totalRev,
      interestIncome: interestInc,
      jewellerySales: jewellerySales,
      otherIncome: otherInc,
      totalExpenses: totalExp,
      operatingExpenses: totalExp,
      netProfit: totalRev - totalExp,
    );
  }

  @override
  BalanceSheetResult calculateBalanceSheet(List<AccountModel> accounts, double currentProfit) {
    double assetsSum = 0.0;
    double liabilitiesSum = 0.0;
    double equitySum = 0.0;

    for (final acc in accounts) {
      switch (acc.type) {
        case AccountType.asset:
          assetsSum += acc.currentBalance;
          break;
        case AccountType.liability:
          liabilitiesSum += acc.currentBalance;
          break;
        case AccountType.equity:
          equitySum += acc.currentBalance;
          break;
        default:
          break;
      }
    }

    // Include current period profit in total equity
    final adjustedEquity = equitySum + currentProfit;
    final isBal = (assetsSum - (liabilitiesSum + adjustedEquity)).abs() < 1.0;

    return BalanceSheetResult(
      totalAssets: assetsSum,
      totalLiabilities: liabilitiesSum,
      totalEquity: adjustedEquity,
      isBalanced: isBal,
    );
  }

  @override
  Map<String, double> calculateCashFlow(List<FinancialTransactionModel> transactions) {
    double operatingIn = 0.0;
    double operatingOut = 0.0;
    double investingIn = 0.0;
    double investingOut = 0.0;
    double financingIn = 0.0;
    double financingOut = 0.0;

    for (final tx in transactions) {
      if (tx.isReversed) continue;
      if (tx.sourceModule == SourceModule.payment || tx.sourceModule == SourceModule.income) {
        operatingIn += tx.amount;
      } else if (tx.sourceModule == SourceModule.expense) {
        operatingOut += tx.amount;
      } else if (tx.sourceModule == SourceModule.loan) {
        financingOut += tx.amount;
      } else if (tx.sourceModule == SourceModule.inventory) {
        investingOut += tx.amount;
      }
    }

    final netOperating = operatingIn - operatingOut;
    final netInvesting = investingIn - investingOut;
    final netFinancing = financingIn - financingOut;

    return {
      'operatingIn': operatingIn,
      'operatingOut': operatingOut,
      'netOperating': netOperating,
      'investingIn': investingIn,
      'investingOut': investingOut,
      'netInvesting': netInvesting,
      'financingIn': financingIn,
      'financingOut': financingOut,
      'netFinancing': netFinancing,
      'netCashFlow': netOperating + netInvesting + netFinancing,
    };
  }
}
