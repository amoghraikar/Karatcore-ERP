import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../models/auth_state.dart';
import '../models/branch_model.dart';
import '../models/user_role.dart';
import '../repository/api_auth_repository.dart';
import '../services/auth_service.dart';
import '../services/customer_data_isolation_service.dart';
import '../services/owner_authorization_service.dart';
import '../../../shared/models/user_session.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return ApiAuthRepository(ref.watch(apiClientProvider));
});

final ownerAuthorizationServiceProvider = Provider<IOwnerAuthorizationService>((ref) {
  return const OwnerAuthorizationService();
});

final customerDataIsolationServiceProvider = Provider<ICustomerDataIsolationService>((ref) {
  return const CustomerDataIsolationService();
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider), ref.watch(apiClientProvider));
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repository, this._apiClient) : super(const AuthState());

  final IAuthRepository _repository;
  final ApiClient _apiClient;

  void checkInitialSession() async {
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void forceAuthenticateAsRole(UserRole role) {
    final session = UserSession(
      id: 'OWN-101',
      name: 'Demo Owner',
      role: role,
      email: 'owner@karatcore.com',
      phone: '+91 98200 12345',
      branch: BranchModel.defaultBranches[0],
      is2faEnabled: false,
    );
    state = AuthState(
      status: AuthStatus.authenticated,
      session: session,
      selectedBranch: session.branch,
    );
  }

  void setRememberDevice(bool value) {
    state = state.copyWith(rememberDevice: value);
  }

  void setOtpMethod(String method) {
    state = state.copyWith(otpMethod: method);
  }

  void requireOtpStep(String emailOrPhone) {
    state = state.copyWith(
      status: AuthStatus.pendingOtp,
      pendingEmailOrPhone: emailOrPhone.isNotEmpty ? emailOrPhone : '+91 98200 12345',
      otpMethod: 'sms',
    );
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
        selectedBranch: session.branch,
        pendingEmailOrPhone: emailOrPhone,
        otpMethod: 'sms',
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

  Future<bool> registerOwner({
    required String fullName,
    required String businessName,
    required String email,
    required String phone,
    required String password,
  }) async {
    state = state.copyWith(
      status: AuthStatus.authenticating,
      errorMessage: null,
      pendingEmailOrPhone: email,
    );

    try {
      final session = await _repository.registerOwner(
        fullName: fullName,
        businessName: businessName,
        email: email,
        phone: phone,
        password: password,
      );

      state = state.copyWith(
        status: AuthStatus.pendingOtp,
        session: session,
        selectedBranch: session.branch,
        pendingEmailOrPhone: email,
        otpMethod: 'sms',
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
        status: AuthStatus.authenticated,
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
    _apiClient.setToken(null);
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}
