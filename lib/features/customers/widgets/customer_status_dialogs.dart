import 'package:flutter/material.dart';
import '../../../../core/constants/color_tokens.dart';
import '../models/customer_model.dart';

Future<bool?> showCustomerArchiveDialog(BuildContext context, CustomerModel customer) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.archive_rounded, color: KcColors.carbon700, size: 24),
            SizedBox(width: 10),
            Text('Archive Customer Record?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to archive ${customer.fullName} (${customer.id})?',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: KcColors.carbon100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 18, color: KcColors.carbon700),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Archival preserves all financial history, pledged ornaments, loans, and audit logs. The customer can be restored at any time.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: KcColors.pitchBlack,
              foregroundColor: KcColors.pureWhite,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm Archival'),
          ),
        ],
      );
    },
  );
}

Future<bool?> showCustomerRestoreDialog(BuildContext context, CustomerModel customer) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.unarchive_rounded, color: Color(0xFF059669), size: 24),
            SizedBox(width: 10),
            Text('Restore Customer Record'),
          ],
        ),
        content: Text(
          'Restore ${customer.fullName} (${customer.id}) to Active customer directory?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF059669),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Restore Customer'),
          ),
        ],
      );
    },
  );
}

Future<bool?> showCustomerBlockDialog(BuildContext context, CustomerModel customer) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 26),
            SizedBox(width: 10),
            Text('Block Customer Account?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'WARNING: Blocking ${customer.fullName} (${customer.id}) will halt all store operations for this customer.',
              style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFDC2626)),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: const Text(
                'Blocked customers cannot request new gold loans, redeem pledged ornaments, or process store transactions without explicit Admin override.',
                style: TextStyle(fontSize: 12, color: Color(0xFF991B1B)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm Block'),
          ),
        ],
      );
    },
  );
}
