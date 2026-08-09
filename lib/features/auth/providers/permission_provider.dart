import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_role.dart';
import 'auth_provider.dart';

final currentRoleProvider = Provider<UserRole>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.session?.role ?? UserRole.owner;
});

final canAccessRouteProvider = Provider.family<bool, String>((ref, routePath) {
  final role = ref.watch(currentRoleProvider);
  return role.canAccessRoute(routePath);
});
