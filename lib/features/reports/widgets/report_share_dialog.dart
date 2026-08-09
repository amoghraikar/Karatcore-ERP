import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/reports_providers.dart';

class ReportShareDialog extends ConsumerWidget {
  const ReportShareDialog({super.key, required this.reportTitle});

  final String reportTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Share — $reportTitle', style: const TextStyle(fontWeight: FontWeight.w800)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.link_rounded, color: Color(0xFF2563EB)),
            title: const Text('Copy Secure Web Link'),
            subtitle: const Text('Copy report view URL to clipboard'),
            onTap: () {
              ref.read(exportServiceProvider).shareReport(context: context, reportTitle: reportTitle, method: 'Clipboard Link');
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: const Icon(Icons.email_rounded, color: Color(0xFFD97706)),
            title: const Text('Email Executive Summary'),
            subtitle: const Text('Send PDF summary to business owner email'),
            onTap: () {
              ref.read(exportServiceProvider).shareReport(context: context, reportTitle: reportTitle, method: 'Email');
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: const Icon(Icons.share_rounded, color: Color(0xFF059669)),
            title: const Text('Share to Management Group'),
            subtitle: const Text('Share directly to internal staff dashboard'),
            onTap: () {
              ref.read(exportServiceProvider).shareReport(context: context, reportTitle: reportTitle, method: 'Internal Group');
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
      ],
    );
  }
}
