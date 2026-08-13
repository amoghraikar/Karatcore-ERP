import '../models/branch_model.dart';
import '../models/user_role.dart';
import '../../../shared/models/user_session.dart';

abstract class IAuthRepository {
  Future<UserSession> login({
    required String emailOrPhone,
    required String password,
    required UserRole role,
  });

  Future<UserSession> registerOwner({
    required String fullName,
    required String businessName,
    required String email,
    required String phone,
    required String password,
  });

  Future<bool> verifyOtp({
    required String otpCode,
    required String method,
  });

  Future<bool> resendOtp();

  Future<bool> requestPasswordReset({
    required String emailOrPhone,
  });

  Future<bool> resetPassword({
    required String newPassword,
  });

  Future<bool> unlockSession({
    required String passwordOrPin,
  });

  Future<List<BranchModel>> getAvailableBranches();
}

class AuthException implements Exception {
  AuthException({required this.message});
  final String message;

  @override
  String toString() => message;
}
