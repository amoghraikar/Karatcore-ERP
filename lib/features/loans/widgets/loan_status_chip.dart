import 'package:flutter/material.dart';
import '../../../../shared/widgets/feedback/kc_status_badge.dart';
import '../models/loan_model.dart';

class LoanStatusChip extends StatelessWidget {
  const LoanStatusChip({
    super.key,
    required this.status,
  });

  final LoanStatus status;

  @override
  Widget build(BuildContext context) {
    return KcStatusBadge(
      label: status.label,
      statusColor: status.color,
      icon: status.icon,
    );
  }
}

class LoanRiskChip extends StatelessWidget {
  const LoanRiskChip({
    super.key,
    required this.risk,
  });

  final LoanRiskStatus risk;

  @override
  Widget build(BuildContext context) {
    return KcStatusBadge(
      label: risk.label,
      statusColor: risk.color,
      icon: risk.icon,
    );
  }
}
