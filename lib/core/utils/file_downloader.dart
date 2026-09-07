import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/print_export_service.dart';

class FileDownloader {
  /// Triggers a real browser file download for Web / Mobile
  static Future<void> downloadFile({
    required String filename,
    required String content,
    required String mimeType,
  }) async {
    final bytes = utf8.encode(content);
    await downloadBytes(filename: filename, bytes: bytes, mimeType: mimeType);
  }

  /// Triggers a real browser file download from bytes
  static Future<void> downloadBytes({
    required String filename,
    required List<int> bytes,
    required String mimeType,
  }) async {
    final uint8Bytes = Uint8List.fromList(bytes);
    if (mimeType == 'application/pdf') {
      await Printing.sharePdf(bytes: uint8Bytes, filename: filename);
      return;
    }

    final base64Data = base64Encode(bytes);
    final dataUrl = 'data:$mimeType;charset=utf-8;base64,$base64Data';
    final uri = Uri.parse(dataUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// Generate & Download Real Vector PDF Receipt
  static Future<void> downloadReceiptPdf({
    required String receiptNumber,
    required String customerName,
    required String loanId,
    required double amount,
    required String paymentMethod,
    required DateTime date,
  }) async {
    await PrintExportService.downloadReceiptPdf(
      receiptNumber: receiptNumber,
      title: 'Payment Receipt',
      customerName: customerName,
      loanId: loanId,
      amount: amount,
      paymentMethod: paymentMethod,
      date: date,
    );
  }

  /// Generate & Download Real CSV Report
  static Future<void> downloadCsvReport({
    required String reportTitle,
    required List<List<String>> rows,
  }) async {
    final csvString = rows.map((r) => r.map((c) => '"${c.replaceAll('"', '""')}"').join(',')).join('\n');
    await downloadFile(
      filename: '${reportTitle.replaceAll(' ', '_')}_Export.csv',
      content: csvString,
      mimeType: 'text/csv',
    );
  }
}
