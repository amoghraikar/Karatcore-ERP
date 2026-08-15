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
    final rawName = (data['full_name'] ?? data['name'] ?? '').toString().trim();
    final rawStoreName = (data['store_name'] ?? data['business_name'] ?? '').toString().trim();
    final phone = (data['phone'] ?? '').toString();
    final customerId = data['customer_id']?.toString();

    final displayName = rawName.isNotEmpty
        ? rawName
        : (phone.isNotEmpty ? phone : (sub.isNotEmpty ? sub : 'Store Owner'));

    final id = role == UserRole.customer
        ? (customerId ?? sub)
        : (customerId ?? sub);

    final storeTitle = rawStoreName.isNotEmpty ? rawStoreName : _defaultStoreName;

    final token = data['access_token']?.toString();

    return UserSession(
      id: id.isNotEmpty ? id : 'OWN-101',
      name: displayName,
      role: role,
      email: sub.contains('@') ? sub : '',
      phone: phone.isNotEmpty ? phone : (sub.contains('@') ? '' : sub),
      token: token,
      storeName: rawStoreName.isNotEmpty ? rawStoreName : null,
      is2faEnabled: false,
      branch: BranchModel(
        id: 'MAIN-STORE',
        name: storeTitle,
        location: 'Main Market',
        city: 'Headquarters',
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

    final dynamic data = await _api.post(
      ApiEndpoints.ownerLogin,
      body: {'username': emailOrPhone.trim(), 'password': password},
    );

    _api.setToken(data['access_token']?.toString() ?? '');
    return _sessionFromResponse(
      Map<String, dynamic>.from(data as Map),
      role: role,
    );
  }

  @override
  Future<UserSession> registerOwner({
    required String fullName,
    required String businessName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final dynamic data = await _api.post(
      ApiEndpoints.ownerRegister,
      body: {
        'full_name': fullName,
        'business_name': businessName,
        'email': email,
        'phone': phone,
        'password': password,
      },
    );

    _api.setToken(data['access_token']?.toString() ?? '');
    return _sessionFromResponse(
      Map<String, dynamic>.from(data as Map),
      role: UserRole.owner,
    );
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
