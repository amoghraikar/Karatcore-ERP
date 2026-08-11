import '../../customers/models/customer_model.dart';
import '../../customers/repository/customer_repository.dart';
import '../../kyc/models/kyc_model.dart';
import '../../kyc/repository/kyc_repository.dart';
import '../../loans/models/loan_model.dart';
import '../../loans/repository/loan_repository.dart';
import '../../notifications/models/notification_models.dart';
import '../../notifications/repository/notification_repository.dart';
import '../../ornaments/models/ornament_model.dart';

class CustomerAccessRestrictedException implements Exception {
  const CustomerAccessRestrictedException(this.message);
  final String message;

  @override
  String toString() => message;
}

abstract class ICustomerExperienceRepository {
  Future<CustomerModel?> getCustomerProfile(String customerId);
  Future<List<LoanModel>> getCustomerLoans(String customerId);
  Future<LoanModel> getCustomerLoanById({required String customerId, required String loanId});
  Future<List<OrnamentModel>> getCustomerJewellery(String customerId);
  Future<OrnamentModel> getCustomerJewelleryById({required String customerId, required String ornamentId});
  Future<List<LoanPaymentModel>> getCustomerPayments(String customerId);
  Future<LoanPaymentModel> getCustomerPaymentById({required String customerId, required String paymentId});
  Future<KycRecordModel?> getCustomerKyc(String customerId);
  Future<List<NotificationModel>> getCustomerNotifications(String customerId);
}

class CustomerExperienceRepository implements ICustomerExperienceRepository {
  CustomerExperienceRepository({
    required this.customerRepo,
    required this.loanRepo,
    required this.kycRepo,
    required this.notificationRepo,
  });

  final ICustomerRepository customerRepo;
  final ILoanRepository loanRepo;
  final IKycRepository kycRepo;
  final INotificationRepository notificationRepo;

  @override
  Future<CustomerModel?> getCustomerProfile(String customerId) async {
    final customer = await customerRepo.getCustomerById(customerId);
    if (customer == null || customer.id != customerId) {
      throw const CustomerAccessRestrictedException('Access Restricted: Customer profile not found.');
    }
    return customer;
  }

  @override
  Future<List<LoanModel>> getCustomerLoans(String customerId) async {
    final loans = await loanRepo.getLoansByCustomerId(customerId);
    return loans.where((l) => l.customerId == customerId).toList();
  }

  @override
  Future<LoanModel> getCustomerLoanById({required String customerId, required String loanId}) async {
    final loan = await loanRepo.getLoanById(loanId);
    if (loan == null || loan.customerId != customerId) {
      throw const CustomerAccessRestrictedException('Access Restricted: This loan record is not available to your account.');
    }
    return loan;
  }

  @override
  Future<List<OrnamentModel>> getCustomerJewellery(String customerId) async {
    final loans = await getCustomerLoans(customerId);
    final ornaments = <OrnamentModel>[];
    for (final l in loans) {
      ornaments.addAll(l.collateralOrnaments);
    }
    return ornaments;
  }

  @override
  Future<OrnamentModel> getCustomerJewelleryById({required String customerId, required String ornamentId}) async {
    final jewellery = await getCustomerJewellery(customerId);
    try {
      return jewellery.firstWhere((o) => o.id == ornamentId);
    } catch (_) {
      throw const CustomerAccessRestrictedException('Access Restricted: This jewellery asset is not registered under your account.');
    }
  }

  @override
  Future<List<LoanPaymentModel>> getCustomerPayments(String customerId) async {
    final loans = await getCustomerLoans(customerId);
    final payments = <LoanPaymentModel>[];
    for (final l in loans) {
      payments.addAll(l.payments);
    }
    payments.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
    return payments;
  }

  @override
  Future<LoanPaymentModel> getCustomerPaymentById({required String customerId, required String paymentId}) async {
    final payments = await getCustomerPayments(customerId);
    try {
      return payments.firstWhere((p) => p.id == paymentId);
    } catch (_) {
      throw const CustomerAccessRestrictedException('Access Restricted: Payment receipt not available to your account.');
    }
  }

  @override
  Future<KycRecordModel?> getCustomerKyc(String customerId) async {
    final record = await kycRepo.getKycRecordByCustomerId(customerId);
    if (record != null && record.customerId != customerId) {
      throw const CustomerAccessRestrictedException('Access Restricted: KYC record not available.');
    }
    return record;
  }

  @override
  Future<List<NotificationModel>> getCustomerNotifications(String customerId) async {
    final allNotifs = await notificationRepo.getNotifications();
    return allNotifs.where((n) {
      if (n.relatedEntityId == customerId) return true;
      if (n.relatedEntityType == 'LOAN') {
        // match loan
        return true;
      }
      return false;
    }).toList();
  }
}
