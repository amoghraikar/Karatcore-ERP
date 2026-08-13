class ApiEndpoints {
  static const String ownerRegister = '/auth/owner/register';
  static const String ownerLogin = '/auth/owner/login';
  static const String customerLogin = '/auth/customer/login';

  static const String customers = '/customers';
  static const String customerById = '/customers/';

  static const String loans = '/loans';
  static const String loanById = '/loans/';

  static const String kycMetrics = '/kyc/metrics';
  static const String kyc = '/kyc';
  static const String kycById = '/kyc/';
  static const String kycApprove = '/approve';
  static const String kycReject = '/reject';
  static const String kycReverification = '/reverification';

  static const String payments = '/payments';
  static const String paymentById = '/payments/';

  static const String accountingJournal = '/accounting/journal-entries';

  static const String inventory = '/inventory';
  static const String accountingAccounts = '/accounting/accounts';
  static const String accountingTransactions = '/accounting/transactions';
  static const String accountingMetrics = '/accounting/metrics';
  static const String notifications = '/notifications';
  static const String reports = '/reports';

  // Customer Portal Endpoints
  static const String customerProfile = '/customer/profile';
  static const String customerLoans = '/customer/loans';
  static const String customerJewellery = '/customer/jewellery';
  static const String customerPayments = '/customer/payments';
}
