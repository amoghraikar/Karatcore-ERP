import 'package:equatable/equatable.dart';
import '../../features/auth/models/branch_model.dart';
import '../../features/auth/models/user_role.dart';

class UserSession extends Equatable {
  const UserSession({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    this.phone = '+91 98200 12345',
    this.avatarUrl,
    this.branch,
    this.is2faEnabled = true,
  });

  final String id;
  final String name;
  final UserRole role;
  final String email;
  final String phone;
  final String? avatarUrl;
  final BranchModel? branch;
  final bool is2faEnabled;

  UserSession copyWith({
    String? id,
    String? name,
    UserRole? role,
    String? email,
    String? phone,
    String? avatarUrl,
    BranchModel? branch,
    bool? is2faEnabled,
  }) {
    return UserSession(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      branch: branch ?? this.branch,
      is2faEnabled: is2faEnabled ?? this.is2faEnabled,
    );
  }

  static final mock = UserSession(
    id: 'USR-101',
    name: 'Arjun Rathore',
    role: UserRole.owner,
    email: 'arjun@karatcore.com',
    phone: '+91 98200 12345',
    branch: BranchModel.mockBranches[0],
    is2faEnabled: true,
  );

  @override
  List<Object?> get props => [id, name, role, email, phone, avatarUrl, branch, is2faEnabled];
}
