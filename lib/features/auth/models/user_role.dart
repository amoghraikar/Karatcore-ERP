import 'package:flutter/material.dart';
import '../../../core/routing/routes.dart';

enum UserRole {
  owner,
  admin,
  manager,
  employee;

  String get label {
    switch (this) {
      case UserRole.owner:
        return 'Owner';
      case UserRole.admin:
        return 'Admin';
      case UserRole.manager:
        return 'Manager';
      case UserRole.employee:
        return 'Employee';
    }
  }

  String get description {
    switch (this) {
      case UserRole.owner:
        return 'Full business access';
      case UserRole.admin:
        return 'Operational access';
      case UserRole.manager:
        return 'Management access';
      case UserRole.employee:
        return 'Restricted operational access';
    }
  }

  IconData get icon {
    switch (this) {
      case UserRole.owner:
        return Icons.verified_user_rounded;
      case UserRole.admin:
        return Icons.admin_panel_settings_rounded;
      case UserRole.manager:
        return Icons.supervisor_account_rounded;
      case UserRole.employee:
        return Icons.badge_rounded;
    }
  }

  bool canAccessRoute(String path) {
    if (path == AppRoutes.dashboard ||
        path == AppRoutes.profile ||
        path == AppRoutes.notifications ||
        path == AppRoutes.help) {
      return true;
    }

    switch (this) {
      case UserRole.owner:
        return true;
      case UserRole.admin:
        return path != AppRoutes.showcase;
      case UserRole.manager:
        return path == AppRoutes.customers ||
            path == AppRoutes.customerDetails ||
            path == AppRoutes.kyc ||
            path == AppRoutes.ornaments ||
            path == AppRoutes.loans ||
            path == AppRoutes.loanDetails ||
            path == AppRoutes.reports ||
            path == AppRoutes.reportsExecutive ||
            path == AppRoutes.reportsCustomers ||
            path == AppRoutes.reportsKyc ||
            path == AppRoutes.reportsInventory ||
            path == AppRoutes.reportsLoans ||
            path == AppRoutes.reportsPayments ||
            path == AppRoutes.reportsAccounting ||
            path == AppRoutes.reportsProfitability ||
            path == AppRoutes.reportsOperations;
      case UserRole.employee:
        return path == AppRoutes.customers ||
            path == AppRoutes.customerDetails ||
            path == AppRoutes.kyc ||
            path == AppRoutes.ornaments ||
            path == AppRoutes.loans ||
            path == AppRoutes.loanDetails ||
            path == AppRoutes.reports ||
            path == AppRoutes.reportsCustomers ||
            path == AppRoutes.reportsKyc ||
            path == AppRoutes.reportsInventory;
    }
  }

  static UserRole fromString(String roleStr) {
    final lower = roleStr.toLowerCase();
    if (lower.contains('owner')) return UserRole.owner;
    if (lower.contains('admin')) return UserRole.admin;
    if (lower.contains('manager')) return UserRole.manager;
    return UserRole.employee;
  }
}
