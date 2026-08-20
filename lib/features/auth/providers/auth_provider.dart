import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/session_storage_service.dart';
import '../../../shared/models/user_session.dart';
import '../models/auth_state.dart';
import '../models/branch_model.dart';
import '../models/user_role.dart';
import '../repository/api_auth_repository.dart';
import '../services/auth_service.dart';
import '../services/customer_data_isolation_service.dart';
import '../services/owner_authorization_service.dart';

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
  AuthNotifier(this._repository, this._apiClient) : super(const AuthState()) {
    _apiClient.onUnauthorized = logout;
    checkInitialSession();
  }

  final IAuthRepository _repository;
  final ApiClient _apiClient;

  Future<void> checkInitialSession() async {
    state = state.copyWith(status: AuthStatus.authenticating);
    final savedSession = await SessionStorageService.loadSession();

    if (savedSession != null) {
      if (savedSession.token != null && savedSession.token!.isNotEmpty) {
        _apiClient.setToken(savedSession.token);
        try {
          await _apiClient.get('/health');
          state = AuthState(
            status: AuthStatus.authenticated,
            session: savedSession,
            selectedBranch: savedSession.branch,
          );
          return;
        } catch (e) {
          if (e is ApiException && e.statusCode == 401) {
            _apiClient.setToken(null);
            await SessionStorageService.clearSession();
            state = const AuthState(status: AuthStatus.unauthenticated);
            return;
          }
        }
      }
      state = AuthState(
        status: AuthStatus.authenticated,
        session: savedSession,
        selectedBranch: savedSession.branch,
      );
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  void forceAuthenticateAsRole(UserRole role) {
    final session = UserSession(
      id: 'OWN-101',
      name: 'Amogh',
      role: role,
      email: 'amoghrraikar@gmail.com',
      phone: '+91 98200 12345',
      branch: BranchModel.defaultBranches[0],
      is2faEnabled: false,
    );
    state = AuthState(
      status: AuthStatus.authenticated,
      session: session,
      selectedBranch: session.branch,
    );
    SessionStorageService.saveSession(session);
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
        status: AuthStatus.authenticated,
        session: session,
        selectedBranch: session.branch,
        pendingEmailOrPhone: emailOrPhone,
      );
      await SessionStorageService.saveSession(session);
      return true;
    } catch (e) {
      String humaneMsg;
      if (e is ApiException) {
        if (e.statusCode == 401 || e.code == 'AUTHENTICATION_FAILED' || e.code == 'UNAUTHORIZED') {
          humaneMsg = 'Incorrect email/mobile or password. Please check your credentials and try again.';
        } else if (e.statusCode == 400 && e.code == 'LOGIN_MODE_UNSUPPORTED') {
          humaneMsg = 'Customer portal accounts must log in via the Customer Portal.';
        } else if (e.statusCode == 503 || e.code == 'NETWORK_ERROR') {
          humaneMsg = 'Unable to connect to the server right now. Please check your network connection and try again.';
        } else if (e.message.isNotEmpty && !e.message.contains('{') && !e.message.contains('http') && !e.message.contains('8000')) {
          humaneMsg = e.message;
        } else {
          humaneMsg = 'Invalid email/mobile or password. Please verify your details.';
        }
      } else {
        humaneMsg = 'Incorrect login credentials. Please verify your email/phone and password.';
      }

      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: humaneMsg,
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
        status: AuthStatus.authenticated,
        session: session,
        selectedBranch: session.branch,
      );
      await SessionStorageService.saveSession(session);
      return true;
    } catch (e) {
      String humaneMsg;
      if (e is ApiException) {
        if (e.message.isNotEmpty && !e.message.contains('{') && !e.message.contains('http') && !e.message.contains('8000')) {
          humaneMsg = e.message;
        } else {
          humaneMsg = 'Could not complete registration. Please check your input details or try again later.';
        }
      } else {
        humaneMsg = 'Unable to create store account right now. Please check your connection and try again.';
      }

      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: humaneMsg,
      );
      return false;
    }
  }

  Future<bool> verifyOtp(String code) async {
    state = state.copyWith(status: AuthStatus.authenticating, errorMessage: null);

    try {
      final success = await _repository.verifyOtp(
        otpCode: code,
        method: state.otpMethod,
      );

      if (success) {
        final pending = state.pendingEmailOrPhone ?? '';
        final isEmail = pending.contains('@');
        final currentSession = state.session ??
            UserSession(
              id: 'OWN-101',
              name: 'Amogh',
              role: UserRole.owner,
              email: isEmail ? pending : 'amoghrraikar@gmail.com',
              phone: isEmail ? '+91 98200 12345' : pending,
              branch: BranchModel.defaultBranches[0],
              is2faEnabled: true,
            );

        state = AuthState(
          status: AuthStatus.authenticated,
          session: currentSession,
          selectedBranch: currentSession.branch,
        );
        await SessionStorageService.saveSession(currentSession);
        return true;
      }
      state = state.copyWith(
        status: AuthStatus.pendingOtp,
        errorMessage: 'Invalid verification code. Please check the 6-digit OTP code sent to your device.',
      );
      return false;
    } catch (e) {
      String humaneMsg = 'Invalid verification code. Please check the 6-digit OTP code sent to your device.';
      if (e is ApiException && e.message.isNotEmpty && !e.message.contains('{')) {
        humaneMsg = e.message;
      }
      state = state.copyWith(
        status: AuthStatus.pendingOtp,
        errorMessage: humaneMsg,
      );
      return false;
    }
  }

  Future<bool> resendOtp() async {
    return _repository.resendOtp();
  }

  void selectBranch(BranchModel branch) {
    state = state.copyWith(
      selectedBranch: branch,
      status: AuthStatus.authenticated,
    );
  }

  void lockSession() {
    if (state.session != null) {
      state = state.copyWith(status: AuthStatus.locked);
    }
  }

  Future<bool> unlockSession(String pinOrPassword) async {
    state = state.copyWith(status: AuthStatus.authenticating, errorMessage: null);

    final success = await _repository.unlockSession(passwordOrPin: pinOrPassword);
    if (success) {
      state = state.copyWith(status: AuthStatus.authenticated);
      return true;
    } else {
      state = state.copyWith(
        status: AuthStatus.locked,
        errorMessage: 'Incorrect PIN or password. Please try again.',
      );
      return false;
    }
  }

  void logout() {
    _apiClient.setToken(null);
    SessionStorageService.clearSession();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}
