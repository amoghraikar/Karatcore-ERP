import 'package:flutter/material.dart';

import '../../../../shared/widgets/feedback/kc_error_state.dart';

class ReportErrorState extends StatelessWidget {
  const ReportErrorState({super.key, required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return KcErrorState(
      message: 'Unable to load report: $error',
      onRetry: onRetry,
    );
  }
}
