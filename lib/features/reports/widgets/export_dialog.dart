import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/reports_providers.dart';
import '../services/export_service.dart';

class ExportDialog extends ConsumerStatefulWidget {
  const ExportDialog({
    super.key,
    required this.reportTitle,
    required this.data,
  });

  final String reportTitle;
  final List<Map<String, dynamic>> data;

  @override
  ConsumerState<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends ConsumerState<ExportDialog> {
  ExportFormat _selectedFormat = ExportFormat.pdf;
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Export — ${widget.reportTitle}', style: const TextStyle(fontWeight: FontWeight.w800)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select export file format:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          RadioGroup<ExportFormat>(
            groupValue: _selectedFormat,
            onChanged: (val) {
              if (val != null) setState(() => _selectedFormat = val);
            },
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<ExportFormat>(
                  title: Row(children: [Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFDC2626)), SizedBox(width: 8), Text('PDF Document (.pdf)')]),
                  value: ExportFormat.pdf,
                ),
                RadioListTile<ExportFormat>(
                  title: Row(children: [Icon(Icons.table_chart_rounded, color: Color(0xFF059669)), SizedBox(width: 8), Text('Microsoft Excel (.xlsx)')]),
                  value: ExportFormat.excel,
                ),
                RadioListTile<ExportFormat>(
                  title: Row(children: [Icon(Icons.view_headline_rounded, color: Color(0xFF2563EB)), SizedBox(width: 8), Text('CSV Comma Separated (.csv)')]),
                  value: ExportFormat.csv,
                ),
                RadioListTile<ExportFormat>(
                  title: Row(children: [Icon(Icons.print_rounded, color: Color(0xFF7C3AED)), SizedBox(width: 8), Text('Direct Thermal / Network Printer')]),
                  value: ExportFormat.print,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _isExporting
              ? null
              : () async {
                  setState(() => _isExporting = true);
                  final currentNav = Navigator.of(context);

                  await ref.read(exportServiceProvider).exportReport(
                        context: context,
                        reportTitle: widget.reportTitle,
                        format: _selectedFormat,
                        data: widget.data,
                      );

                  if (mounted) currentNav.pop();
                },
          child: _isExporting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Generate Export'),
        ),
      ],
    );
  }
}
