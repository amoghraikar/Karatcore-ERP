import '../models/branch_model.dart';
import '../models/user_role.dart';
import '../services/auth_service.dart';
import '../../../shared/models/user_session.dart';

class MockAuthRepository implements IAuthRepository {
  @override
  Future<UserSession> login({
    required String emailOrPhone,
    required String password,
    required UserRole role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    if (password == 'wrong' || password == '1234') {
      throw Exception('Invalid credentials provided. Please check your password.');
    }

    final lowerInput = emailOrPhone.toLowerCase();

    return UserSession(
      id: 'OWN-101',
      name: 'Demo Owner',
      role: UserRole.owner,
      email: lowerInput.contains('@') ? lowerInput : 'owner@karatcore.com',
      phone: lowerInput.startsWith('+') ? lowerInput : '+91 98200 12345',
      branch: BranchModel.mockBranches[0],
      is2faEnabled: true,
    );
  }

  @override
  Future<bool> verifyOtp({
    required String otpCode,
    required String method,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final sanitizedCode = otpCode.trim().replaceAll('-', '');

    if (method == 'authenticator') {
      if (sanitizedCode != '482910') {
        throw Exception('Invalid Authenticator TOTP code. Use 482910.');
      }
    } else if (method == 'backup') {
      if (sanitizedCode != '84923019') {
        throw Exception('Invalid 8-digit emergency backup code. Use 84923019.');
      }
    } else {
      if (sanitizedCode != '123456') {
        throw Exception('Invalid SMS/Email verification code. Use valid OTP: 123456.');
      }
    }
    return true;
  }

  @override
  Future<bool> resendOtp() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  @override
  Future<bool> requestPasswordReset({required String emailOrPhone}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (emailOrPhone.isEmpty) {
      throw Exception('Please enter a valid email or mobile number.');
    }
    return true;
  }

  @override
  Future<bool> resetPassword({required String newPassword}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (newPassword.length < 8) {
      throw Exception('Password must be at least 8 characters long.');
    }
    return true;
  }

  @override
  Future<bool> unlockSession({required String passwordOrPin}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (passwordOrPin == 'wrong' || passwordOrPin == '0000') {
      throw Exception('Incorrect passcode or biometric mismatch.');
    }
    return true;
  }

  @override
  Future<List<BranchModel>> getAvailableBranches() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return BranchModel.mockBranches;
  }
}
