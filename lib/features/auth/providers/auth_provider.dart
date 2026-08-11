import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_state.dart';
import '../models/branch_model.dart';
import '../models/user_role.dart';
import '../repository/mock_auth_repository.dart';
import '../services/auth_service.dart';
import '../services/customer_data_isolation_service.dart';
import '../services/owner_authorization_service.dart';
import '../../../shared/models/user_session.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return MockAuthRepository();
});

final ownerAuthorizationServiceProvider = Provider<IOwnerAuthorizationService>((ref) {
  return const OwnerAuthorizationService();
});

final customerDataIsolationServiceProvider = Provider<ICustomerDataIsolationService>((ref) {
  return const CustomerDataIsolationService();
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repository) : super(const AuthState());

  final IAuthRepository _repository;

  void checkInitialSession() async {
    state = state.copyWith(status: AuthStatus.authenticating);
    await Future.delayed(const Duration(milliseconds: 700));
    // Default to initial unauthenticated state so full flow is testable
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void setRememberDevice(bool value) {
    state = state.copyWith(rememberDevice: value);
  }

  void setOtpMethod(String method) {
    state = state.copyWith(otpMethod: method);
  }

  void selectRole(UserRole role) {
    state = state.copyWith(pendingRole: role);
  }

  Future<bool> login({
    required String emailOrPhone,
    required String password,
    UserRole? role,
  }) async {
    state = state.copyWith(
      status: AuthStatus.authenticating,
      errorMessage: null,
      pendingEmailOrPhone: emailOrPhone,
      pendingRole: role ?? state.pendingRole,
    );

    try {
      final session = await _repository.login(
        emailOrPhone: emailOrPhone,
        password: password,
        role: role ?? state.pendingRole,
      );

      state = state.copyWith(
        status: AuthStatus.pendingOtp,
        session: session,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> verifyOtp(String code) async {
    state = state.copyWith(status: AuthStatus.authenticating, errorMessage: null);

    try {
      await _repository.verifyOtp(otpCode: code, method: state.otpMethod);
      state = state.copyWith(
        status: AuthStatus.pendingBranch,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.pendingOtp,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> resendOtp() async {
    try {
      await _repository.resendOtp();
      return true;
    } catch (e) {
      return false;
    }
  }

  void selectBranch(BranchModel branch) {
    final updatedSession = state.session?.copyWith(branch: branch);
    state = state.copyWith(
      status: AuthStatus.authenticated,
      session: updatedSession,
      selectedBranch: branch,
    );
  }

  void lockSession() {
    if (state.status == AuthStatus.authenticated) {
      state = state.copyWith(status: AuthStatus.locked);
    }
  }

  Future<bool> unlockSession(String passwordOrPin) async {
    state = state.copyWith(status: AuthStatus.authenticating, errorMessage: null);
    try {
      await _repository.unlockSession(passwordOrPin: passwordOrPin);
      state = state.copyWith(status: AuthStatus.authenticated);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.locked,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  void logout() {
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void switchAccount(UserSession session) {
    state = AuthState(
      status: AuthStatus.authenticated,
      session: session,
      selectedBranch: session.branch ?? BranchModel.mockBranches[0],
    );
  }

  void forceAuthenticateAsRole(UserRole role) {
    final session = UserSession(
      id: 'OWN-101',
      name: 'Demo Owner',
      role: UserRole.owner,
      email: 'owner@karatcore.com',
      phone: '+91 98200 12345',
      branch: BranchModel.mockBranches[0],
    );

    state = AuthState(
      status: AuthStatus.authenticated,
      session: session,
      selectedBranch: BranchModel.mockBranches[0],
    );
  }
}
