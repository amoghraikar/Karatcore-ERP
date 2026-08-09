import 'package:flutter/material.dart';

class KycRejectionDialog extends StatefulWidget {
  const KycRejectionDialog({
    super.key,
    required this.customerName,
  });

  final String customerName;

  @override
  State<KycRejectionDialog> createState() => _KycRejectionDialogState();
}

class _KycRejectionDialogState extends State<KycRejectionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  String _selectedReason = 'Information Mismatch';

  final List<String> _rejectionCategories = [
    'Invalid Document',
    'Document Unreadable',
    'Information Mismatch',
    'Expired Document',
    'Missing Information',
    'Manual Review Required',
    'Other Integrity Failure',
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop({
      'reason': _selectedReason,
      'notes': _notesController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: Row(
        children: [
          const Icon(Icons.cancel_rounded, color: Color(0xFFDC2626), size: 24),
          const SizedBox(width: 10),
          Text('Reject KYC — ${widget.customerName}'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select primary rejection category *',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedReason,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              onChanged: (val) => setState(() => _selectedReason = val ?? _selectedReason),
              items: _rejectionCategories
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
            ),
            const SizedBox(height: 16),
            const Text(
              'Mandatory Reviewer Note *',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Explain specifically why verification was rejected...',
                border: OutlineInputBorder(),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Reviewer note is required for rejection audit trail.';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDC2626),
            foregroundColor: Colors.white,
          ),
          onPressed: _submit,
          child: const Text('Confirm Rejection'),
        ),
      ],
    );
  }
}

Future<Map<String, String>?> showKycRejectionDialog(BuildContext context, String customerName) {
  return showDialog<Map<String, String>>(
    context: context,
    builder: (context) => KycRejectionDialog(customerName: customerName),
  );
}
