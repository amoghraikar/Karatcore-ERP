import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/rbac_models.dart';
import '../repository/mock_staff_repository.dart';
import '../repository/staff_repository.dart';
import '../services/authorization_service.dart';

final staffRepositoryProvider = Provider<IStaffRepository>((ref) {
  return MockStaffRepository();
});

final rolesListProvider = FutureProvider<List<AppRoleModel>>((ref) async {
  final repo = ref.watch(staffRepositoryProvider);
  return repo.getRoles();
});

final authorizationServiceProvider = Provider<IAuthorizationService>((ref) {
  final rolesAsync = ref.watch(rolesListProvider);
  final roles = rolesAsync.valueOrNull ?? [];
  return AuthorizationService(roles: roles);
});

// Active Logged-in Staff User Persona (StateNotifier so user can switch persona live in top bar!)
class CurrentStaffNotifier extends StateNotifier<StaffModel> {
  CurrentStaffNotifier()
      : super(
          StaffModel(
            id: 'STF-001',
            employeeId: 'EMP-1001',
            fullName: 'Vikramaditya Verma',
            email: 'vikram.verma@karatcore.com',
            mobile: '+91 98200 11223',
            avatarUrl: '',
            roleCode: 'OWNER',
            department: 'Executive Management',
            branchId: 'BR-001',
            branchName: 'Zaveri Bazaar Main Branch',
            status: StaffStatus.active,
            joiningDate: DateTime(2022, 1, 1),
            lastActive: DateTime.now(),
            createdAt: DateTime(2022, 1, 1),
          ),
        );

  void switchPersona(StaffModel staff) {
    state = staff;
  }
}

final currentStaffUserProvider = StateNotifierProvider<CurrentStaffNotifier, StaffModel>((ref) {
  return CurrentStaffNotifier();
});

final staffListProvider = FutureProvider<List<StaffModel>>((ref) async {
  final repo = ref.watch(staffRepositoryProvider);
  return repo.getStaffList();
});

final branchesListProvider = FutureProvider<List<BranchModel>>((ref) async {
  final repo = ref.watch(staffRepositoryProvider);
  return repo.getBranches();
});

final departmentsListProvider = FutureProvider<List<DepartmentModel>>((ref) async {
  final repo = ref.watch(staffRepositoryProvider);
  return repo.getDepartments();
});

final staffDetailProvider = FutureProvider.family<StaffModel?, String>((ref, id) async {
  final repo = ref.watch(staffRepositoryProvider);
  return repo.getStaffById(id);
});

final staffSessionsProvider = FutureProvider.family<List<StaffSessionModel>, String>((ref, staffId) async {
  final repo = ref.watch(staffRepositoryProvider);
  return repo.getSessionsForStaff(staffId);
});

final securityEventsProvider = FutureProvider<List<SecurityEventModel>>((ref) async {
  final repo = ref.watch(staffRepositoryProvider);
  return repo.getSecurityEvents();
});

final staffAuditTrailProvider = FutureProvider.family<List<StaffAuditModel>, String>((ref, staffId) async {
  final repo = ref.watch(staffRepositoryProvider);
  return repo.getAuditTrail(staffId);
});
