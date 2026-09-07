import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../utils/file_downloader.dart';
import '../utils/formatters.dart';

class PrintExportService {
  /// Generate crisp, compliant Vector PDF bytes for a Payment / Pledge Receipt
  static Future<Uint8List> buildReceiptPdfBytes({
    required String receiptNumber,
    required String title,
    required String customerName,
    required String loanId,
    required double amount,
    required String paymentMethod,
    required DateTime date,
    String staffName = 'Store Cashier',
    String branch = 'Main Store, Mumbai • BIS Reg: BIS-MH-4002',
  }) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80, // Standard 80mm thermal receipt format
        margin: const pw.EdgeInsets.all(12),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                'KARATCORE ERP',
                style: const pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Luxury Jewellery & Secured Gold Loans',
                style: const pw.TextStyle(fontSize: 8),
              ),
              pw.Text(
                branch,
                style: const pw.TextStyle(fontSize: 7),
              ),
              pw.SizedBox(height: 6),
              pw.Divider(thickness: 0.5),
              pw.SizedBox(height: 4),
              pw.Text(
                title.toUpperCase(),
                style: const pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                'Receipt #: $receiptNumber',
                style: const pw.TextStyle(fontSize: 8),
              ),
              pw.SizedBox(height: 6),
              pw.Divider(thickness: 0.5),
              pw.SizedBox(height: 4),

              _buildPdfRow('Date & Time', KcFormatters.dateTime(date)),
              _buildPdfRow('Loan Account', '#$loanId'),
              _buildPdfRow('Customer', customerName),
              _buildPdfRow('Payment Mode', paymentMethod),
              pw.SizedBox(height: 4),
              pw.Divider(thickness: 0.5),
              pw.SizedBox(height: 4),

              _buildPdfRow('AMOUNT PAID', KcFormatters.inr(amount), isBold: true, fontSize: 10),
              pw.SizedBox(height: 4),
              pw.Divider(thickness: 0.5),
              pw.SizedBox(height: 6),

              _buildPdfRow('Authorized By', staffName),
              pw.SizedBox(height: 8),
              pw.Text(
                'Official Store Financial Document • Retain for records',
                style: const pw.TextStyle(fontSize: 6),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 4),
              pw.BarcodeWidget(
                data: receiptNumber,
                barcode: pw.Barcode.code128(),
                width: 140,
                height: 30,
                drawText: false,
              ),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  /// Triggers the native OS print dialog for a receipt (thermal or standard printer)
  static Future<void> printReceipt({
    required String receiptNumber,
    required String title,
    required String customerName,
    required String loanId,
    required double amount,
    required String paymentMethod,
    required DateTime date,
    String staffName = 'Store Cashier',
  }) async {
    final bytes = await buildReceiptPdfBytes(
      receiptNumber: receiptNumber,
      title: title,
      customerName: customerName,
      loanId: loanId,
      amount: amount,
      paymentMethod: paymentMethod,
      date: date,
      staffName: staffName,
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => bytes,
      name: '$receiptNumber.pdf',
    );
  }

  /// Downloads genuine binary vector PDF for a receipt
  static Future<void> downloadReceiptPdf({
    required String receiptNumber,
    required String title,
    required String customerName,
    required String loanId,
    required double amount,
    required String paymentMethod,
    required DateTime date,
    String staffName = 'Store Cashier',
  }) async {
    final bytes = await buildReceiptPdfBytes(
      receiptNumber: receiptNumber,
      title: title,
      customerName: customerName,
      loanId: loanId,
      amount: amount,
      paymentMethod: paymentMethod,
      date: date,
      staffName: staffName,
    );

    await FileDownloader.downloadBytes(
      filename: '$receiptNumber.pdf',
      bytes: bytes,
      mimeType: 'application/pdf',
    );
  }

  /// Builds a genuine BIS Hallmark Quality Certificate PDF
  static Future<Uint8List> buildQualityCertificatePdfBytes({
    required String ornamentId,
    required String ornamentName,
    required String purity,
    required double grossWeight,
    required double netWeight,
    required double valuationAmount,
    String hallmarkNo = 'BIS-HM-22K-916-400002',
    String customerName = 'Pledge Collateral Asset',
    String vaultLocation = 'Safe Vault A-12 (Insured Storage)',
  }) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context ctx) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(24),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.amber800, width: 3),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  'KARATCORE JEWELLERY ERP',
                  style: const pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.amber900),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'BIS HALLMARK CERTIFICATE OF QUALITY & PURITY',
                  style: const pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  'Government Approved Appraiser & Hallmarking Protocol Standards',
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                ),
                pw.SizedBox(height: 16),
                pw.Divider(color: PdfColors.amber800, thickness: 1.5),
                pw.SizedBox(height: 16),

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Certificate #: CERT-BIS-$ornamentId', style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                    pw.Text('Issue Date: ${KcFormatters.date(DateTime.now())}', style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
                pw.SizedBox(height: 16),

                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  color: PdfColors.grey100,
                  child: pw.Column(
                    children: [
                      _buildPdfRow('Ornament Description', ornamentName, fontSize: 10),
                      pw.SizedBox(height: 6),
                      _buildPdfRow('Asset Identification ID', ornamentId, fontSize: 10),
                      pw.SizedBox(height: 6),
                      _buildPdfRow('Customer / Pledgor', customerName, fontSize: 10),
                      pw.SizedBox(height: 6),
                      _buildPdfRow('BIS Hallmark Registration', hallmarkNo, fontSize: 10, isBold: true),
                      pw.SizedBox(height: 6),
                      _buildPdfRow('Certified Metal Purity', purity, fontSize: 10, isBold: true),
                      pw.SizedBox(height: 6),
                      _buildPdfRow('Gross Metal Weight', '${grossWeight.toStringAsFixed(2)} g', fontSize: 10),
                      pw.SizedBox(height: 6),
                      _buildPdfRow('Net Fine Metal Weight', '${netWeight.toStringAsFixed(2)} g', fontSize: 10),
                      pw.SizedBox(height: 6),
                      _buildPdfRow('Appraised Valuation', KcFormatters.inr(valuationAmount), fontSize: 11, isBold: true),
                      pw.SizedBox(height: 6),
                      _buildPdfRow('Secure Vault Location', vaultLocation, fontSize: 10),
                    ],
                  ),
                ),

                pw.Spacer(),

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.BarcodeWidget(
                          data: 'https://karatcore.in/cert/$ornamentId',
                          barcode: pw.Barcode.qrCode(),
                          width: 60,
                          height: 60,
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text('Scan to Verify', style: const pw.TextStyle(fontSize: 7)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Container(
                          width: 140,
                          height: 1,
                          color: PdfColors.black,
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text('Authorized Assayer Seal & Signature', style: const pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                        pw.Text('Government Approved Assayer #982', style: const pw.TextStyle(fontSize: 7)),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'This certificate is an official legal record generated by KaratCore ERP. Purity is certified in compliance with Bureau of Indian Standards (BIS).',
                  style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );

    return doc.save();
  }

  /// Triggers native OS print dialog for a Quality Certificate
  static Future<void> printQualityCertificate({
    required String ornamentId,
    required String ornamentName,
    required String purity,
    required double grossWeight,
    required double netWeight,
    required double valuationAmount,
    String hallmarkNo = 'BIS-HM-22K-916-400002',
    String customerName = 'Pledge Collateral Asset',
  }) async {
    final bytes = await buildQualityCertificatePdfBytes(
      ornamentId: ornamentId,
      ornamentName: ornamentName,
      purity: purity,
      grossWeight: grossWeight,
      netWeight: netWeight,
      valuationAmount: valuationAmount,
      hallmarkNo: hallmarkNo,
      customerName: customerName,
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => bytes,
      name: 'CERT-BIS-$ornamentId.pdf',
    );
  }

  /// Downloads genuine binary vector PDF for a Quality Certificate
  static Future<void> downloadQualityCertificatePdf({
    required String ornamentId,
    required String ornamentName,
    required String purity,
    required double grossWeight,
    required double netWeight,
    required double valuationAmount,
    String hallmarkNo = 'BIS-HM-22K-916-400002',
    String customerName = 'Pledge Collateral Asset',
  }) async {
    final bytes = await buildQualityCertificatePdfBytes(
      ornamentId: ornamentId,
      ornamentName: ornamentName,
      purity: purity,
      grossWeight: grossWeight,
      netWeight: netWeight,
      valuationAmount: valuationAmount,
      hallmarkNo: hallmarkNo,
      customerName: customerName,
    );

    await FileDownloader.downloadBytes(
      filename: 'CERT-BIS-$ornamentId.pdf',
      bytes: bytes,
      mimeType: 'application/pdf',
    );
  }

  /// Prints barcode and QR inventory tags
  static Future<void> printBarcodeTag({
    required String ornamentId,
    required String ornamentName,
    required String purity,
    required double grossWeight,
    required double netWeight,
    required double estimatedValue,
  }) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(70 * PdfPageFormat.mm, 45 * PdfPageFormat.mm), // Standard jewellery tag label
        margin: const pw.EdgeInsets.all(6),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text('KARATCORE ERP', style: const pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 2),
              pw.Text(ornamentName, style: const pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold), maxLines: 1),
              pw.Text('ID: $ornamentId • $purity', style: const pw.TextStyle(fontSize: 6)),
              pw.Text('GW: ${grossWeight.toStringAsFixed(2)}g | NW: ${netWeight.toStringAsFixed(2)}g', style: const pw.TextStyle(fontSize: 6)),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.BarcodeWidget(
                    data: ornamentId,
                    barcode: pw.Barcode.code128(),
                    width: 90,
                    height: 18,
                    drawText: false,
                  ),
                  pw.SizedBox(width: 8),
                  pw.BarcodeWidget(
                    data: ornamentId,
                    barcode: pw.Barcode.qrCode(),
                    width: 20,
                    height: 20,
                  ),
                ],
              ),
              pw.SizedBox(height: 2),
              pw.Text('Valuation: ${KcFormatters.inr(estimatedValue)}', style: const pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold)),
            ],
          );
        },
      ),
    );

    final bytes = await doc.save();
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => bytes,
      name: 'Tag_$ornamentId.pdf',
    );
  }

  /// Builds and prints a multi-column report table as PDF
  static Future<void> printReportTable({
    required String reportTitle,
    required List<Map<String, dynamic>> rows,
  }) async {
    final doc = pw.Document();

    final List<String> headers = rows.isNotEmpty ? rows.first.keys.toList() : ['Title', 'Status', 'Date'];
    final List<List<String>> tableData = rows.map((r) => r.values.map((v) => v.toString()).toList()).toList();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        header: (pw.Context ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('KARATCORE ERP — $reportTitle', style: const pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.Text('Generated: ${KcFormatters.dateTime(DateTime.now())}', style: const pw.TextStyle(fontSize: 9)),
              ],
            ),
            pw.Divider(thickness: 0.5),
            pw.SizedBox(height: 6),
          ],
        ),
        build: (pw.Context ctx) {
          if (rows.isEmpty) {
            return [
              pw.Center(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.all(32),
                  child: pw.Text('No records found for this report filter criteria.', style: const pw.TextStyle(fontSize: 12)),
                ),
              ),
            ];
          }

          return [
            pw.TableHelper.fromTextArray(
              headers: headers,
              data: tableData,
              headerStyle: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
              cellStyle: const pw.TextStyle(fontSize: 7),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
              rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5))),
              cellAlignment: pw.Alignment.centerLeft,
            ),
          ];
        },
      ),
    );

    final bytes = await doc.save();
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => bytes,
      name: '${reportTitle.replaceAll(' ', '_')}.pdf',
    );
  }

  /// Downloads multi-column report table as real binary PDF
  static Future<void> downloadReportPdf({
    required String reportTitle,
    required List<Map<String, dynamic>> rows,
  }) async {
    final doc = pw.Document();

    final List<String> headers = rows.isNotEmpty ? rows.first.keys.toList() : ['Title', 'Status', 'Date'];
    final List<List<String>> tableData = rows.map((r) => r.values.map((v) => v.toString()).toList()).toList();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        header: (pw.Context ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('KARATCORE ERP — $reportTitle', style: const pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.Text('Generated: ${KcFormatters.dateTime(DateTime.now())}', style: const pw.TextStyle(fontSize: 9)),
              ],
            ),
            pw.Divider(thickness: 0.5),
            pw.SizedBox(height: 6),
          ],
        ),
        build: (pw.Context ctx) {
          if (rows.isEmpty) {
            return [
              pw.Center(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.all(32),
                  child: pw.Text('No records found for this report filter criteria.', style: const pw.TextStyle(fontSize: 12)),
                ),
              ),
            ];
          }

          return [
            pw.TableHelper.fromTextArray(
              headers: headers,
              data: tableData,
              headerStyle: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
              cellStyle: const pw.TextStyle(fontSize: 7),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
              rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5))),
              cellAlignment: pw.Alignment.centerLeft,
            ),
          ];
        },
      ),
    );

    final bytes = await doc.save();
    await FileDownloader.downloadBytes(
      filename: '${reportTitle.replaceAll(' ', '_')}_Report.pdf',
      bytes: bytes,
      mimeType: 'application/pdf',
    );
  }

  static pw.Widget _buildPdfRow(String label, String value, {bool isBold = false, double fontSize = 8}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: fontSize, color: PdfColors.grey800)),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
