import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/models/customer_session_model.dart';
import '../../customers/models/customer_model.dart';
import '../../customers/providers/customer_providers.dart';
import '../../kyc/models/kyc_model.dart';
import '../../kyc/providers/kyc_providers.dart';
import '../../loans/models/loan_model.dart';
import '../../loans/providers/loan_providers.dart';
import '../../notifications/models/notification_models.dart';
import '../../notifications/providers/notification_providers.dart';
import '../../ornaments/models/ornament_model.dart';
import '../repository/customer_experience_repository.dart';

final currentCustomerSessionProvider = StateProvider<CustomerSession>((ref) {
  return CustomerSession.demoCustomerA;
});

final customerExperienceRepositoryProvider = Provider<ICustomerExperienceRepository>((ref) {
  return CustomerExperienceRepository(
    customerRepo: ref.watch(customerRepositoryProvider),
    loanRepo: ref.watch(loanRepositoryProvider),
    kycRepo: ref.watch(kycRepositoryProvider),
    notificationRepo: ref.watch(notificationRepositoryProvider),
  );
});

final customerProfileProvider = FutureProvider<CustomerModel?>((ref) async {
  final session = ref.watch(currentCustomerSessionProvider);
  final repo = ref.watch(customerExperienceRepositoryProvider);
  return repo.getCustomerProfile(session.customerId);
});

final customerLoansProvider = FutureProvider<List<LoanModel>>((ref) async {
  final session = ref.watch(currentCustomerSessionProvider);
  final repo = ref.watch(customerExperienceRepositoryProvider);
  return repo.getCustomerLoans(session.customerId);
});

final customerLoanDetailProvider = FutureProvider.family<LoanModel, String>((ref, loanId) async {
  final session = ref.watch(currentCustomerSessionProvider);
  final repo = ref.watch(customerExperienceRepositoryProvider);
  return repo.getCustomerLoanById(customerId: session.customerId, loanId: loanId);
});

final customerJewelleryProvider = FutureProvider<List<OrnamentModel>>((ref) async {
  final session = ref.watch(currentCustomerSessionProvider);
  final repo = ref.watch(customerExperienceRepositoryProvider);
  return repo.getCustomerJewellery(session.customerId);
});

final customerJewelleryDetailProvider = FutureProvider.family<OrnamentModel, String>((ref, ornamentId) async {
  final session = ref.watch(currentCustomerSessionProvider);
  final repo = ref.watch(customerExperienceRepositoryProvider);
  return repo.getCustomerJewelleryById(customerId: session.customerId, ornamentId: ornamentId);
});

final customerPaymentsProvider = FutureProvider<List<LoanPaymentModel>>((ref) async {
  final session = ref.watch(currentCustomerSessionProvider);
  final repo = ref.watch(customerExperienceRepositoryProvider);
  return repo.getCustomerPayments(session.customerId);
});

final customerPaymentDetailProvider = FutureProvider.family<LoanPaymentModel, String>((ref, paymentId) async {
  final session = ref.watch(currentCustomerSessionProvider);
  final repo = ref.watch(customerExperienceRepositoryProvider);
  return repo.getCustomerPaymentById(customerId: session.customerId, paymentId: paymentId);
});

final customerKycProvider = FutureProvider<KycRecordModel?>((ref) async {
  final session = ref.watch(currentCustomerSessionProvider);
  final repo = ref.watch(customerExperienceRepositoryProvider);
  return repo.getCustomerKyc(session.customerId);
});

final customerNotificationsProvider = FutureProvider<List<NotificationModel>>((ref) async {
  final session = ref.watch(currentCustomerSessionProvider);
  final repo = ref.watch(customerExperienceRepositoryProvider);
  return repo.getCustomerNotifications(session.customerId);
});
