import 'package:hooks_riverpod/hooks_riverpod.dart';

final storeProductProvider = StateProvider<List<Map<String, dynamic>>>(
  (ref) => [],
);

void addProductToStore(WidgetRef ref, Map<String, dynamic> newItem) {
  final oldList = ref.read(storeProductProvider);
  final newList = [...oldList, newItem];
  ref.read(storeProductProvider.notifier).state = newList;
}
