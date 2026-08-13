import '../models/accounting_model.dart';
import '../repository/accounting_repository.dart';

abstract class IAccountingIntegrationService {
  Future<FinancialTransactionModel> recordLoanDisbursementTransaction({
    required String loanId,
    required String customerId,
    required String customerName,
    required double amount,
    required String paymentMethod,
  });

  Future<FinancialTransactionModel> recordLoanPaymentTransaction({
    required String loanId,
    required String customerId,
    required String customerName,
    required double totalPayment,
    required double interestComponent,
    required double principalComponent,
    required String paymentMethod,
  });

  Future<FinancialTransactionModel> recordExpenseTransaction(ExpenseModel expense);
  Future<FinancialTransactionModel> recordIncomeTransaction(IncomeModel income);
}

class AccountingIntegrationService implements IAccountingIntegrationService {
  AccountingIntegrationService(this._repository);

  final IAccountingRepository _repository;

  @override
  Future<FinancialTransactionModel> recordLoanDisbursementTransaction({
    required String loanId,
    required String customerId,
    required String customerName,
    required double amount,
    required String paymentMethod,
  }) async {
    final now = DateTime.now();
    final tx = FinancialTransactionModel(
      id: 'KC-TX-${now.millisecondsSinceEpoch.toString().substring(5)}',
      date: now,
      type: 'Loan Disbursement',
      reference: loanId,
      description: 'Gold Loan Principal Disbursement for $customerName ($customerId)',
      debitAccountId: 'ACC-105', // Loans Receivable
      debitAccountName: 'Loans Receivable — Gold',
      creditAccountId: paymentMethod.contains('Cash') ? 'ACC-101' : 'ACC-102', // Cash or Bank
      creditAccountName: paymentMethod.contains('Cash') ? 'Cash in Vault' : 'HDFC Bank Main Operating Account',
      amount: amount,
      sourceModule: SourceModule.loan,
      sourceId: loanId,
      createdBy: 'Loan Officer',
    );

    return await _repository.createTransaction(tx);
  }

  @override
  Future<FinancialTransactionModel> recordLoanPaymentTransaction({
    required String loanId,
    required String customerId,
    required String customerName,
    required double totalPayment,
    required double interestComponent,
    required double principalComponent,
    required String paymentMethod,
  }) async {
    final now = DateTime.now();
    final tx = FinancialTransactionModel(
      id: 'KC-TX-${now.millisecondsSinceEpoch.toString().substring(5)}',
      date: now,
      type: 'Loan Repayment & Interest',
      reference: 'RCP-$loanId',
      description: 'Loan Repayment from $customerName ($customerId): Interest ${interestComponent.toStringAsFixed(0)}, Principal ${principalComponent.toStringAsFixed(0)}',
      debitAccountId: paymentMethod.contains('Cash') ? 'ACC-101' : 'ACC-102',
      debitAccountName: paymentMethod.contains('Cash') ? 'Cash in Vault' : 'HDFC Bank Main Operating Account',
      creditAccountId: 'ACC-105',
      creditAccountName: 'Loans Receivable — Gold',
      amount: totalPayment,
      sourceModule: SourceModule.payment,
      sourceId: loanId,
      createdBy: 'Teller Staff',
    );

    return await _repository.createTransaction(tx);
  }

  @override
  Future<FinancialTransactionModel> recordExpenseTransaction(ExpenseModel expense) async {
    final now = DateTime.now();
    final tx = FinancialTransactionModel(
      id: 'KC-TX-${now.millisecondsSinceEpoch.toString().substring(5)}',
      date: expense.date,
      type: 'Expense Entry',
      reference: expense.reference,
      description: '${expense.category.label}: ${expense.description}',
      debitAccountId: 'ACC-501',
      debitAccountName: expense.category.label,
      creditAccountId: expense.paymentMethod.contains('Cash') ? 'ACC-101' : 'ACC-102',
      creditAccountName: expense.paymentMethod.contains('Cash') ? 'Cash in Vault' : 'HDFC Bank Main Operating Account',
      amount: expense.amount,
      sourceModule: SourceModule.expense,
      sourceId: expense.id,
      createdBy: 'Accountant',
    );

    return await _repository.createTransaction(tx);
  }

  @override
  Future<FinancialTransactionModel> recordIncomeTransaction(IncomeModel income) async {
    final now = DateTime.now();
    final tx = FinancialTransactionModel(
      id: 'KC-TX-${now.millisecondsSinceEpoch.toString().substring(5)}',
      date: income.date,
      type: 'Income Entry',
      reference: income.reference,
      description: '${income.category.label}: ${income.description}',
      debitAccountId: income.paymentMethod.contains('Cash') ? 'ACC-101' : 'ACC-102',
      debitAccountName: income.paymentMethod.contains('Cash') ? 'Cash in Vault' : 'HDFC Bank Main Operating Account',
      creditAccountId: 'ACC-401',
      creditAccountName: income.category.label,
      amount: income.amount,
      sourceModule: SourceModule.income,
      sourceId: income.id,
      createdBy: 'Cashier',
    );

    return await _repository.createTransaction(tx);
  }
}
