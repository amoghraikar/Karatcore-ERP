import 'package:equatable/equatable.dart';
import '../../features/auth/models/branch_model.dart';
import '../../features/auth/models/user_role.dart';

class UserSession extends Equatable {
  const UserSession({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    required this.phone,
    this.token,
    this.storeName,
    this.avatarUrl,
    this.branch,
    this.is2faEnabled = false,
  });

  final String id;
  final String name;
  final UserRole role;
  final String email;
  final String phone;
  final String? token;
  final String? storeName;
  final String? avatarUrl;
  final BranchModel? branch;
  final bool is2faEnabled;

  UserSession copyWith({
    String? id,
    String? name,
    UserRole? role,
    String? email,
    String? phone,
    String? token,
    String? storeName,
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
      token: token ?? this.token,
      storeName: storeName ?? this.storeName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      branch: branch ?? this.branch,
      is2faEnabled: is2faEnabled ?? this.is2faEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role.name,
      'email': email,
      'phone': phone,
      'token': token,
      'storeName': storeName,
      'avatarUrl': avatarUrl,
      'branchName': branch?.name,
      'is2faEnabled': is2faEnabled,
    };
  }

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      id: json['id'] as String? ?? 'OWN-101',
      name: json['name'] as String? ?? 'Store Owner',
      role: UserRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => UserRole.owner,
      ),
      email: json['email'] as String? ?? 'owner@karatcore.com',
      phone: json['phone'] as String? ?? '+91 98765 43210',
      token: json['token'] as String?,
      storeName: json['storeName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      branch: BranchModel.defaultBranches[0],
      is2faEnabled: json['is2faEnabled'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [id, name, role, email, phone, token, storeName, avatarUrl, branch, is2faEnabled];
}
