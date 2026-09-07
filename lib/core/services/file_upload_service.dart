import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

class UploadedDocument {
  const UploadedDocument({
    required this.fileName,
    required this.bytes,
    required this.sizeBytes,
    required this.extension,
    required this.mimeType,
  });

  final String fileName;
  final Uint8List bytes;
  final int sizeBytes;
  final String extension;
  final String mimeType;

  String get formattedSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}

class FileUploadService {
  static const int maxSizeBytes = 10 * 1024 * 1024; // 10 MB limit
  static const List<String> allowedExtensions = ['pdf', 'png', 'jpg', 'jpeg', 'webp'];

  static String getMimeType(String ext) {
    switch (ext.toLowerCase().replaceAll('.', '')) {
      case 'pdf':
        return 'application/pdf';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }

  /// Opens the native OS file picker (on Web, Android, iOS, Desktop)
  static Future<UploadedDocument?> pickDocument({
    List<String>? customExtensions,
  }) async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: customExtensions ?? allowedExtensions,
      );

      if (file == null) {
        return null;
      }

      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        return null;
      }

      final fileSize = bytes.lengthInBytes;
      if (fileSize > maxSizeBytes) {
        throw Exception('File exceeds maximum allowed size of 10 MB.');
      }

      final ext = file.extension ?? 'png';
      return UploadedDocument(
        fileName: file.name,
        bytes: bytes,
        sizeBytes: fileSize,
        extension: ext,
        mimeType: getMimeType(ext),
      );
    } catch (e) {
      rethrow;
    }
  }
}
