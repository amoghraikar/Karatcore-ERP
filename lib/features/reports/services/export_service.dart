import 'package:flutter/material.dart';
import '../../../../core/utils/file_downloader.dart';

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
    final fileName = '${reportTitle.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}';

    if (format == ExportFormat.csv || format == ExportFormat.excel) {
      final List<List<String>> csvRows = [];
      if (data.isNotEmpty) {
        csvRows.add(data.first.keys.toList());
        for (final row in data) {
          csvRows.add(row.values.map((v) => v.toString()).toList());
        }
      } else {
        csvRows.add(['Title', 'Status', 'GeneratedAt']);
        csvRows.add([reportTitle, 'ACTIVE', DateTime.now().toIso8601String()]);
      }

      await FileDownloader.downloadCsvReport(
        reportTitle: reportTitle,
        rows: csvRows,
      );
    } else if (format == ExportFormat.pdf) {
      final pdfContent = '''
============================================================
           KARATCORE JEWELLERY ERP - $reportTitle         
============================================================
Generated Date: ${DateTime.now().toIso8601String()}
Total Records: ${data.length}
------------------------------------------------------------
${data.take(10).map((d) => d.entries.map((e) => '${e.key}: ${e.value}').join(' | ')).join('\n')}
============================================================
''';
      await FileDownloader.downloadFile(
        filename: '$fileName.pdf',
        content: pdfContent,
        mimeType: 'application/pdf',
      );
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            format == ExportFormat.print
                ? 'Print preview sent to default network printer for "$reportTitle".'
                : 'Report file generated & downloaded ($fileName).',
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
