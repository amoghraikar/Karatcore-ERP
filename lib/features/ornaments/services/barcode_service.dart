abstract class IBarcodeService {
  String generateBarcode(String ornamentId);

  String generateQrCode(String ornamentId);

  Future<String?> simulateCameraScan();
}

class BarcodeService implements IBarcodeService {
  @override
  String generateBarcode(String ornamentId) {
    final clean = ornamentId.replaceAll(RegExp(r'[^0-9]'), '');
    final padded = clean.padLeft(12, '0');
    return '890$padded';
  }

  @override
  String generateQrCode(String ornamentId) {
    return 'QR-$ornamentId-KARATCORE';
  }

  @override
  Future<String?> simulateCameraScan() async {
    return null;
  }
}
