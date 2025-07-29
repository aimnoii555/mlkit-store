import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

Future<String> barcodeScanner() async {
  String barcodeScan;

  barcodeScan = await FlutterBarcodeScanner.scanBarcode(
    '#ff6666',
    'Cancel',
    true,
    ScanMode.BARCODE,
  );
  return barcodeScan;
}
