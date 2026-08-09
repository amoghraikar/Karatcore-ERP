import 'package:flutter/material.dart';

enum ExportFormat { csv, excel, pdf, print }

abstract class IExportService {
  Future<bool> exportReport({
    required BuildContext context,
    required String reportTitle,
    required ExportFormat format,
    required List<Map<String, dynamic>> data,
  });

  Future<bool> shareReport({
    required BuildContext context,
    required String reportTitle,
    required String method,
  });
}

class MockExportService implements IExportService {
  @override
  Future<bool> exportReport({
    required BuildContext context,
    required String reportTitle,
    required ExportFormat format,
    required List<Map<String, dynamic>> data,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    if (context.mounted) {
      final ext = format == ExportFormat.csv
          ? '.csv'
          : format == ExportFormat.excel
              ? '.xlsx'
              : '.pdf';
      final fileName = '${reportTitle.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}$ext';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            format == ExportFormat.print
                ? 'Print preview sent to default network printer for "$reportTitle".'
                : 'Report successfully exported as $fileName (${data.length} records).',
          ),
          backgroundColor: const Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    return true;
  }

  @override
  Future<bool> shareReport({
    required BuildContext context,
    required String reportTitle,
    required String method,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Report "$reportTitle" link copied / shared via $method.'),
          backgroundColor: const Color(0xFF2563EB),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    return true;
  }
}
