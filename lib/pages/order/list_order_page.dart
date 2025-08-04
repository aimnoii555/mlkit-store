import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mlkit_store/database/order_db.dart';

class ListOrderPage extends HookConsumerWidget {
  const ListOrderPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersList = useState<List<Map<String, dynamic>>>([]);
    Future<void> fetchOrders() async {
      final query = await OrderDb.query("SELECT * FROM orders");
      ordersList.value = query;

      // print('order = ${ordersList.value}');
    }

    useEffect(() {
      fetchOrders();
      return null;
    }, []);
    return Scaffold(appBar: AppBar(title: Text('List Orders')));
  }
}
