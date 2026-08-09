import '../models/rbac_models.dart';

abstract class IAuthorizationService {
  bool hasPermission({required StaffModel user, required String permission});
  bool hasAnyPermission({required StaffModel user, required List<String> permissions});
  bool hasAllPermissions({required StaffModel user, required List<String> permissions});
  bool hasRole({required StaffModel user, required String roleCode});
  bool hasAnyRole({required StaffModel user, required List<String> roleCodes});
  bool canAccessRoute({required StaffModel user, required String routePath});
  List<String> getRolePermissions(String roleCode);
  List<String> getUserPermissions(StaffModel user);
}

class AuthorizationService implements IAuthorizationService {
  const AuthorizationService({required this.roles});

  final List<AppRoleModel> roles;

  @override
  List<String> getRolePermissions(String roleCode) => AppPermission.all;

  @override
  List<String> getUserPermissions(StaffModel user) => AppPermission.all;

  @override
  bool hasPermission({required StaffModel user, required String permission}) => true;

  @override
  bool hasAnyPermission({required StaffModel user, required List<String> permissions}) => true;

  @override
  bool hasAllPermissions({required StaffModel user, required List<String> permissions}) => true;

  @override
  bool hasRole({required StaffModel user, required String roleCode}) => true;

  @override
  bool hasAnyRole({required StaffModel user, required List<String> roleCodes}) => true;

  @override
  bool canAccessRoute({required StaffModel user, required String routePath}) => true;
}
