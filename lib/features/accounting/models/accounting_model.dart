import 'package:flutter/material.dart';

enum AccountType {
  asset('Assets', Colors.blue),
  liability('Liabilities', Colors.orange),
  equity('Equity', Colors.purple),
  income('Income', Colors.green),
  expense('Expenses', Colors.red);

  const AccountType(this.label, this.color);
  final String label;
  final Color color;
}

enum AccountCategory {
  // Assets
  cash('Cash', AccountType.asset),
  bankAccount('Bank Account', AccountType.asset),
  inventoryGold('Inventory — Gold', AccountType.asset),
  inventorySilver('Inventory — Silver', AccountType.asset),
  loansReceivable('Loans Receivable', AccountType.asset),
  interestReceivable('Interest Receivable', AccountType.asset),
  otherReceivables('Other Receivables', AccountType.asset),

  // Liabilities
  customerDeposits('Customer Deposits', AccountType.liability),
  payables('Payables', AccountType.liability),
  otherLiabilities('Other Liabilities', AccountType.liability),

  // Equity
  ownerCapital('Owner Capital', AccountType.equity),
  retainedEarnings('Retained Earnings', AccountType.equity),

  // Income
  interestIncome('Interest Income', AccountType.income),
  jewellerySales('Jewellery Sales', AccountType.income),
  serviceIncome('Service Income', AccountType.income),
  otherIncome('Other Income', AccountType.income),

  // Expenses
  rent('Rent', AccountType.expense),
  salaries('Salaries', AccountType.expense),
  utilities('Utilities', AccountType.expense),
  maintenance('Maintenance', AccountType.expense),
  transportation('Transportation', AccountType.expense),
  marketing('Marketing', AccountType.expense),
  bankCharges('Bank Charges', AccountType.expense),
  officeSupplies('Office Supplies', AccountType.expense),
  insurance('Insurance', AccountType.expense),
  otherExpenses('Other Expenses', AccountType.expense);

  const AccountCategory(this.label, this.type);
  final String label;
  final AccountType type;
}

class AccountModel {
  const AccountModel({
    required this.id,
    required this.name,
    required this.type,
    required this.category,
    this.parentAccountId,
    required this.openingBalance,
    required this.currentBalance,
    this.status = 'Active',
    required this.createdAt,
  });

  final String id;
  final String name;
  final AccountType type;
  final AccountCategory category;
  final String? parentAccountId;
  final double openingBalance;
  final double currentBalance;
  final String status;
  final DateTime createdAt;

  AccountModel copyWith({
    String? id,
    String? name,
    AccountType? type,
    AccountCategory? category,
    String? parentAccountId,
    double? openingBalance,
    double? currentBalance,
    String? status,
    DateTime? createdAt,
  }) {
    return AccountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      category: category ?? this.category,
      parentAccountId: parentAccountId ?? this.parentAccountId,
      openingBalance: openingBalance ?? this.openingBalance,
      currentBalance: currentBalance ?? this.currentBalance,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class JournalLineModel {
  const JournalLineModel({
    required this.lineId,
    required this.accountId,
    required this.accountName,
    required this.debit,
    required this.credit,
    required this.description,
  });

  final String lineId;
  final String accountId;
  final String accountName;
  final double debit;
  final double credit;
  final String description;
}

class JournalEntryModel {
  const JournalEntryModel({
    required this.id,
    required this.date,
    required this.reference,
    required this.description,
    required this.lines,
    this.notes = '',
    this.attachments = const [],
    this.status = 'Posted',
    required this.createdBy,
  });

  final String id;
  final DateTime date;
  final String reference;
  final String description;
  final List<JournalLineModel> lines;
  final String notes;
  final List<String> attachments;
  final String status; // Posted, Draft, Reversed
  final String createdBy;

  double get totalDebit => lines.fold(0.0, (sum, line) => sum + line.debit);
  double get totalCredit => lines.fold(0.0, (sum, line) => sum + line.credit);
  bool get isBalanced => (totalDebit - totalCredit).abs() < 0.01;
}

enum SourceModule {
  loan('Gold Loan', Icons.account_balance_rounded),
  payment('Loan Payment', Icons.payments_rounded),
  inventory('Inventory Movement', Icons.diamond_rounded),
  expense('Expense Entry', Icons.receipt_rounded),
  income('Income Entry', Icons.savings_rounded),
  manualEntry('Manual Journal', Icons.edit_note_rounded);

  const SourceModule(this.label, this.icon);
  final String label;
  final IconData icon;
}

class FinancialTransactionModel {
  const FinancialTransactionModel({
    required this.id,
    required this.date,
    required this.type,
    required this.reference,
    required this.description,
    required this.debitAccountId,
    required this.debitAccountName,
    required this.creditAccountId,
    required this.creditAccountName,
    required this.amount,
    required this.sourceModule,
    required this.sourceId,
    required this.createdBy,
    this.status = 'Posted',
    this.isReversed = false,
    this.reversalTransactionId,
  });

  final String id;
  final DateTime date;
  final String type; // Debit / Credit Transfer
  final String reference;
  final String description;
  final String debitAccountId;
  final String debitAccountName;
  final String creditAccountId;
  final String creditAccountName;
  final double amount;
  final SourceModule sourceModule;
  final String sourceId;
  final String createdBy;
  final String status;
  final bool isReversed;
  final String? reversalTransactionId;
}

class IncomeModel {
  const IncomeModel({
    required this.id,
    required this.date,
    required this.category,
    required this.amount,
    required this.paymentMethod,
    required this.customerId,
    required this.customerName,
    required this.reference,
    required this.description,
    this.status = 'Received',
  });

  final String id;
  final DateTime date;
  final AccountCategory category;
  final double amount;
  final String paymentMethod;
  final String customerId;
  final String customerName;
  final String reference;
  final String description;
  final String status;
}

class ExpenseModel {
  const ExpenseModel({
    required this.id,
    required this.date,
    required this.category,
    required this.amount,
    required this.paymentMethod,
    required this.vendorName,
    required this.reference,
    required this.description,
    this.status = 'Paid',
  });

  final String id;
  final DateTime date;
  final AccountCategory category;
  final double amount;
  final String paymentMethod;
  final String vendorName;
  final String reference;
  final String description;
  final String status;
}

class ReceivableModel {
  const ReceivableModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.reference,
    required this.amountDue,
    required this.dueDate,
    required this.ageDays,
    required this.status, // Current, Due Soon, Overdue, Partially Paid, Paid
    this.relatedLoanId,
  });

  final String id;
  final String customerId;
  final String customerName;
  final String reference;
  final double amountDue;
  final DateTime dueDate;
  final int ageDays;
  final String status;
  final String? relatedLoanId;
}

class PayableModel {
  const PayableModel({
    required this.id,
    required this.vendorName,
    required this.reference,
    required this.amountDue,
    required this.dueDate,
    required this.ageDays,
    required this.status,
    required this.category,
  });

  final String id;
  final String vendorName;
  final String reference;
  final double amountDue;
  final DateTime dueDate;
  final int ageDays;
  final String status;
  final AccountCategory category;
}

class AccountingPeriodModel {
  const AccountingPeriodModel({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.status, // Open, Closing, Closed
  });

  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final String status;

  bool get isOpen => status == 'Open';
  bool get isClosed => status == 'Closed';
}

class AccountingAuditLogModel {
  const AccountingAuditLogModel({
    required this.id,
    required this.timestamp,
    required this.action,
    required this.description,
    required this.actorName,
    required this.role,
  });

  final String id;
  final DateTime timestamp;
  final String action;
  final String description;
  final String actorName;
  final String role;
}
