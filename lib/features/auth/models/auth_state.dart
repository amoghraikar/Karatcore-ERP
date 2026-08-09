import 'package:equatable/equatable.dart';
import '../../../shared/models/user_session.dart';
import 'branch_model.dart';
import 'user_role.dart';

enum AuthStatus {
  unauthenticated,
  authenticating,
  pendingOtp,
  pendingBranch,
  authenticated,
  sessionExpired,
  locked,
}

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unauthenticated,
    this.session,
    this.selectedBranch,
    this.pendingEmailOrPhone,
    this.pendingRole = UserRole.owner,
    this.rememberDevice = true,
    this.errorMessage,
    this.otpMethod = 'sms',
  });

  final AuthStatus status;
  final UserSession? session;
  final BranchModel? selectedBranch;
  final String? pendingEmailOrPhone;
  final UserRole pendingRole;
  final bool rememberDevice;
  final String? errorMessage;
  final String otpMethod; // 'sms', 'authenticator', 'backup'

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLocked => status == AuthStatus.locked || status == AuthStatus.sessionExpired;
  bool get isAuthenticating => status == AuthStatus.authenticating;

  AuthState copyWith({
    AuthStatus? status,
    UserSession? session,
    BranchModel? selectedBranch,
    String? pendingEmailOrPhone,
    UserRole? pendingRole,
    bool? rememberDevice,
    String? errorMessage,
    String? otpMethod,
  }) {
    return AuthState(
      status: status ?? this.status,
      session: session ?? this.session,
      selectedBranch: selectedBranch ?? this.selectedBranch,
      pendingEmailOrPhone: pendingEmailOrPhone ?? this.pendingEmailOrPhone,
      pendingRole: pendingRole ?? this.pendingRole,
      rememberDevice: rememberDevice ?? this.rememberDevice,
      errorMessage: errorMessage,
      otpMethod: otpMethod ?? this.otpMethod,
    );
  }

  @override
  List<Object?> get props => [
        status,
        session,
        selectedBranch,
        pendingEmailOrPhone,
        pendingRole,
        rememberDevice,
        errorMessage,
        otpMethod,
      ];
}
