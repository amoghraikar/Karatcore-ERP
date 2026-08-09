import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ornament_model.dart';
import '../providers/inventory_providers.dart';

class TransferOrnamentDialog extends ConsumerStatefulWidget {
  const TransferOrnamentDialog({
    super.key,
    required this.ornament,
  });

  final OrnamentModel ornament;

  @override
  ConsumerState<TransferOrnamentDialog> createState() => _TransferOrnamentDialogState();
}

class _TransferOrnamentDialogState extends ConsumerState<TransferOrnamentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController(text: 'Routine Vault Rebalancing');

  String _selectedBranch = 'North Extension Branch';
  final String _selectedArea = 'Central Safe Vault';
  String _selectedLocker = 'Locker #02 (Display Vault)';

  final List<String> _branches = [
    'Main Branch (Store 01)',
    'North Extension Branch',
    'South Jeweller Hub',
  ];

  final List<String> _lockers = [
    'Locker #01 (Main Safe)',
    'Locker #02 (Display Vault)',
    'Locker #03 (Loan Reserve)',
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final dest = InventoryLocationModel(
      branch: _selectedBranch,
      storageArea: _selectedArea,
      locker: _selectedLocker,
    );

    ref.read(ornamentListProvider.notifier).transferOrnament(
          ornamentId: widget.ornament.id,
          destination: dest,
          reason: _reasonController.text.trim(),
        );

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.sync_alt_rounded, color: scheme.primary, size: 24),
          const SizedBox(width: 10),
          Expanded(child: Text('Transfer Vault Location — ${widget.ornament.id}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: scheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Item: ${widget.ornament.name}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text('Current Location: ${widget.ornament.location.fullLocationPath}', style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            const Text('Destination Branch *', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _selectedBranch,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              onChanged: (val) => setState(() => _selectedBranch = val!),
              items: _branches.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
            ),
            const SizedBox(height: 14),

            const Text('Destination Vault Locker *', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _selectedLocker,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              onChanged: (val) => setState(() => _selectedLocker = val!),
              items: _lockers.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
            ),
            const SizedBox(height: 14),

            const Text('Reason for Transfer *', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _reasonController,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Enter transfer justification...'),
              validator: (val) => (val == null || val.trim().isEmpty) ? 'Transfer reason is required.' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: scheme.primary, foregroundColor: scheme.onPrimary),
          onPressed: _submit,
          child: const Text('Confirm Transfer'),
        ),
      ],
    );
  }
}

Future<bool?> showTransferOrnamentDialog(BuildContext context, OrnamentModel ornament) {
  return showDialog<bool>(
    context: context,
    builder: (context) => TransferOrnamentDialog(ornament: ornament),
  );
}
