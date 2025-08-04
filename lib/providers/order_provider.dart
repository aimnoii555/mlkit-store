import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mlkit_store/database/cart_db.dart';

final storeProductProvider = StateProvider<List<Map<String, dynamic>>>(
  (ref) => [],
);

void addProductToStore(WidgetRef ref, Map<String, dynamic> newItem) {
  final oldList = ref.read(storeProductProvider);
  final newList = [...oldList, newItem];
  ref.read(storeProductProvider.notifier).state = newList;
}

// provider.dart
Future<void> getCartsProduct(WidgetRef ref) async {
  final cart = await CartDb.query("SELECT * FROM carts");
  ref.read(storeProductProvider.notifier).state = cart;
}
