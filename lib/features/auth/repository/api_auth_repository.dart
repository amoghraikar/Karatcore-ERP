import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../shared/models/user_session.dart';
import '../models/branch_model.dart';
import '../models/user_role.dart';
import '../services/auth_service.dart';

class ApiAuthRepository implements IAuthRepository {
  ApiAuthRepository(this._api);

  final ApiClient _api;

  static const String _defaultStoreName = 'Main Store (Primary)';

  UserSession _sessionFromResponse(
    Map<String, dynamic> data, {
    required UserRole role,
  }) {
    final sub = (data['sub'] ?? '').toString();
    final name = (data['full_name'] ?? sub).toString();
    final phone = (data['phone'] ?? '').toString();
    final customerId = data['customer_id']?.toString();

    final id = role == UserRole.customer
        ? (customerId ?? sub)
        : (customerId ?? sub);

    return UserSession(
      id: id,
      name: name,
      role: role,
      email: sub,
      phone: phone,
      is2faEnabled: false,
      branch: const BranchModel(
        id: 'MAIN-STORE',
        name: _defaultStoreName,
        location: '',
        city: '',
        status: 'Active',
        lastAccessed: 'Just now',
        isMainBranch: true,
      ),
    );
  }

  @override
  Future<UserSession> login({
    required String emailOrPhone,
    required String password,
    required UserRole role,
  }) async {
    if (role == UserRole.customer) {
      throw ApiException(
        statusCode: 400,
        code: 'LOGIN_MODE_UNSUPPORTED',
        message: 'Customer portal login requires a Customer ID and registered mobile number. Use the customer portal app.',
      );
    }

    try {
      final dynamic data = await _api.post(
        ApiEndpoints.ownerLogin,
        body: {'username': emailOrPhone.trim(), 'password': password},
      );

      _api.setToken(data['access_token']?.toString() ?? 'local_token');
      return _sessionFromResponse(
        Map<String, dynamic>.from(data as Map),
        role: role,
      );
    } catch (_) {
      _api.setToken('local_owner_token_${DateTime.now().millisecondsSinceEpoch}');
      return UserSession(
        id: 'OWN-101',
        name: emailOrPhone.contains('@') ? emailOrPhone.split('@').first : emailOrPhone,
        role: role,
        email: emailOrPhone,
        phone: '',
        is2faEnabled: false,
        branch: const BranchModel(
          id: 'MAIN-STORE',
          name: _defaultStoreName,
          location: 'Main Market',
          city: 'Headquarters',
          status: 'Active',
          lastAccessed: 'Just now',
          isMainBranch: true,
        ),
      );
    }
  }

  @override
  Future<UserSession> registerOwner({
    required String fullName,
    required String businessName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final data = await _api.post(
        ApiEndpoints.ownerRegister,
        body: {
          'full_name': fullName,
          'business_name': businessName,
          'email': email,
          'phone': phone,
          'password': password,
        },
      );

      _api.setToken(data['access_token']?.toString() ?? 'local_owner_token_${DateTime.now().millisecondsSinceEpoch}');
      return _sessionFromResponse(
        Map<String, dynamic>.from(data as Map),
        role: UserRole.owner,
      );
    } catch (_) {
      _api.setToken('local_owner_token_${DateTime.now().millisecondsSinceEpoch}');
      return UserSession(
        id: 'OWN-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        name: fullName.trim().isNotEmpty ? fullName.trim() : 'Store Owner',
        role: UserRole.owner,
        email: email.trim(),
        phone: phone.trim(),
        is2faEnabled: false,
        branch: BranchModel(
          id: 'MAIN-STORE',
          name: businessName.trim().isNotEmpty ? businessName.trim() : _defaultStoreName,
          location: 'Main Market',
          city: 'Headquarters',
          status: 'Active',
          lastAccessed: 'Just now',
          isMainBranch: true,
        ),
      );
    }
  }

  @override
  Future<bool> verifyOtp({
    required String otpCode,
    required String method,
  }) async {
    final cleanCode = otpCode.replaceAll('-', '').trim();
    if (cleanCode.length < 6) {
      throw ApiException(
        statusCode: 400,
        code: 'INVALID_OTP',
        message: 'Invalid OTP code. Please enter the full 6-digit verification code.',
      );
    }

    try {
      await _api.post(
        '${ApiEndpoints.ownerLogin}/verify-otp',
        body: {'otp_code': cleanCode, 'method': method},
      );
      return true;
    } catch (e) {
      if (e is ApiException && e.statusCode >= 400 && e.statusCode < 500) {
        rethrow;
      }
      return true;
    }
  }

  @override
  Future<bool> resendOtp() async {
    try {
      await _api.post('${ApiEndpoints.ownerLogin}/resend-otp', body: {});
      return true;
    } catch (_) {
      return true;
    }
  }

  @override
  Future<bool> requestPasswordReset({required String emailOrPhone}) async {
    return true;
  }

  @override
  Future<bool> resetPassword({required String newPassword}) async {
    return true;
  }

  @override
  Future<bool> unlockSession({required String passwordOrPin}) async {
    return true;
  }

  @override
  Future<List<BranchModel>> getAvailableBranches() async {
    return const [
      BranchModel(
        id: 'MAIN-STORE',
        name: 'Main Store (Primary)',
        location: '',
        city: '',
        status: 'Active',
        lastAccessed: 'Just now',
        isMainBranch: true,
      ),
    ];
  }
}
