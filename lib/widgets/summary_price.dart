import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mlkit_store/database/cart_db.dart';
import 'package:mlkit_store/pages/cart/product_cart.dart';
import 'package:mlkit_store/providers/order_provider.dart';

class SummaryPrice extends HookConsumerWidget {
  const SummaryPrice({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final storeProduct = useState<List<Map<String, dynamic>>>([]);
    final carts = ref.watch(storeProductProvider);

    useEffect(() {
      getCartsProduct(ref);
      return null;
    }, []);

    double calProductPrice() {
      double sumPrice = 0.0;

      for (var item in carts) {
        final priceStr = item['price']?.toString() ?? '0';
        final countStr = item['count']?.toString() ?? '1';

        final price = double.tryParse(priceStr) ?? 0.0;
        final count = int.tryParse(countStr) ?? 1;

        sumPrice += price * count;
      }

      return sumPrice;
    }

    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProductCart()),
          ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(0.5, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total Price',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              calProductPrice().toString(),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
