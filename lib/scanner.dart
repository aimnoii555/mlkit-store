import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mlkit_store/database/product_db.dart';
import 'package:mlkit_store/providers/order_provider.dart';
import 'package:mlkit_store/widgets/my_dialog.dart';
import 'package:mlkit_store/widgets/summary_price.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class Scanner extends HookConsumerWidget {
  const Scanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isScanned = useState<bool>(false);
    final MobileScannerController controller = MobileScannerController(
      autoZoom: true,
    );

    void onDetect(BarcodeCapture capture) async {
      if (isScanned.value) return;

      final barcode = capture.barcodes.first;
      final String? value = barcode.rawValue;

      if (value != null) {
        try {
          int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

          final query = await ProductDb.query(
            "SELECT name,barcode,price FROM products where barcode = '$value' limit 1",
          );

          if (query.isNotEmpty) {
            isScanned.value = true;
            addProductToStore(ref, query.first);
            alertOrder(
              title: 'Created Order',
              productName: query.first['name'].toString(),
              isScanned: isScanned.value,
              context: context,
              icon: Icons.check_circle,
              iconColor: Colors.green,
            );

            // await OrderDb.insertOrder({
            //   'pd_code': value,
            //   'od_create': timestamp.toString(),
            //   'od_update': timestamp.toString(),
            //   'od_price': query.first['price'].toString(),
            // });
          } else {
            alertOrder(
              title: 'Product Not Found.',
              productName: '',
              isScanned: isScanned.value,
              context: context,
              icon: Icons.error_outline_outlined,
              iconColor: Colors.red,
            );
          }
        } catch (e) {
          print('e = $e');
        }
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text('Scan Barcode')),
      body: Stack(
        children: [
          MobileScanner(controller: controller, onDetect: onDetect),
          Positioned(bottom: 20, left: 20, right: 20, child: SummaryPrice()),
        ],
      ),
    );
  }
}
