import 'package:flutter/material.dart';
import '../../../../shared/widgets/feedback/kc_status_badge.dart';
import '../models/ornament_model.dart';

class OrnamentStatusChip extends StatelessWidget {
  const OrnamentStatusChip({
    super.key,
    required this.status,
  });

  final OrnamentStatus status;

  @override
  Widget build(BuildContext context) {
    return KcStatusBadge(
      label: status.label,
      statusColor: status.color,
      icon: status.icon,
    );
  }
}
