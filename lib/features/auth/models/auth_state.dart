import 'package:equatable/equatable.dart';
import '../../../shared/models/user_session.dart';
import 'branch_model.dart';
import 'user_role.dart';

enum AuthStatus {
  unauthenticated,
  authenticating,
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
  });

  final AuthStatus status;
  final UserSession? session;
  final BranchModel? selectedBranch;
  final String? pendingEmailOrPhone;
  final UserRole pendingRole;
  final bool rememberDevice;
  final String? errorMessage;

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
  }) {
    return AuthState(
      status: status ?? this.status,
      session: session ?? this.session,
      selectedBranch: selectedBranch ?? this.selectedBranch,
      pendingEmailOrPhone: pendingEmailOrPhone ?? this.pendingEmailOrPhone,
      pendingRole: pendingRole ?? this.pendingRole,
      rememberDevice: rememberDevice ?? this.rememberDevice,
      errorMessage: errorMessage,
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
      ];
}
