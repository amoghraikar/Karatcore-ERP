import 'package:flutter/material.dart';
import '../../../../shared/widgets/feedback/kc_status_badge.dart';
import '../models/kyc_model.dart';

class KycStatusChip extends StatelessWidget {
  const KycStatusChip({
    super.key,
    required this.status,
  });

  final KycStatus status;

  @override
  Widget build(BuildContext context) {
    return KcStatusBadge(
      label: status.label,
      statusColor: status.color,
      icon: status.icon,
    );
  }
}
