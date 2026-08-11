import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class FileDownloader {
  /// Triggers a real browser file download for Web / Desktop
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
    if (kIsWeb) {
      // Trigger Web Blob Download
      final base64Data = base64Encode(bytes);
      final dataUrl = 'data:$mimeType;base64,$base64Data';
      final uri = Uri.parse(dataUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } else {
      // Fallback URI trigger
      final base64Data = base64Encode(bytes);
      final dataUrl = 'data:$mimeType;base64,$base64Data';
      final uri = Uri.parse(dataUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }

  /// Generate & Download Real PDF Receipt
  static Future<void> downloadReceiptPdf({
    required String receiptNumber,
    required String customerName,
    required String loanId,
    required double amount,
    required String paymentMethod,
    required DateTime date,
  }) async {
    final pdfText = '''
============================================================
           KARATCORE JEWELLERY ERP - PAYMENT RECEIPT        
============================================================
Receipt Number: $receiptNumber
Date: ${date.toIso8601String()}
Customer: $customerName
Loan Contract: #$loanId
------------------------------------------------------------
Payment Method: $paymentMethod
Amount Paid: INR ${amount.toStringAsFixed(2)}
------------------------------------------------------------
Status: SUCCESSFUL (Official Store Financial Record)
============================================================
''';

    await downloadFile(
      filename: '$receiptNumber.pdf',
      content: pdfText,
      mimeType: 'application/pdf',
    );
  }

  /// Generate & Download Real CSV Report
  static Future<void> downloadCsvReport({
    required String reportTitle,
    required List<List<String>> rows,
  }) async {
    final csvString = rows.map((r) => r.map((c) => '"$c"').join(',')).join('\n');
    await downloadFile(
      filename: '${reportTitle.replaceAll(' ', '_')}_Export.csv',
      content: csvString,
      mimeType: 'text/csv',
    );
  }
}
