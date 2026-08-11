import 'package:flutter/material.dart';

enum UserRole {
  owner,
  customer;

  String get label {
    switch (this) {
      case UserRole.owner:
        return 'Store Owner';
      case UserRole.customer:
        return 'Customer';
    }
  }

  String get description {
    switch (this) {
      case UserRole.owner:
        return 'Full Store ERP access';
      case UserRole.customer:
        return 'Customer-facing access to own data only';
    }
  }

  IconData get icon {
    switch (this) {
      case UserRole.owner:
        return Icons.verified_user_rounded;
      case UserRole.customer:
        return Icons.person_rounded;
    }
  }

  bool canAccessRoute(String path) {
    if (this == UserRole.owner) {
      return true;
    }
    // Customer route access check (for future customer portal)
    return false;
  }

  static UserRole fromString(String roleStr) {
    final lower = roleStr.toLowerCase();
    if (lower.contains('customer')) return UserRole.customer;
    return UserRole.owner;
  }
}
