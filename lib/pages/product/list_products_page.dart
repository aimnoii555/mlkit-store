import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mlkit_store/database/product_db.dart';

class ListProductsPage extends HookConsumerWidget {
  const ListProductsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // โหลดสินค้าแบบ useEffect ครั้งเดียว
    final products = useState<List<Map<String, dynamic>>>([]);
    final isLoading = useState(true);

    Future<void> loadProducts() async {
      final result = await ProductDb.getAllProducts();
      products.value = result;
      isLoading.value = false;
    }

    useEffect(() {
      loadProducts();
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product list'),
        actions: [
          IconButton(
            onPressed: () async {
              // await exportProductsToCSV(products.value);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Export Success')));
            },
            icon: Icon(Icons.file_copy),
          ),
        ],
      ),
      body:
          isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : products.value.isEmpty
              ? const Center(child: Text('No Product'))
              : ListView.builder(
                itemCount: products.value.length,
                itemBuilder: (context, index) {
                  final product = products.value[index];
                  final imagePath = product['image_path'];

                  return Card(
                    margin: const EdgeInsets.all(8),
                    elevation: 4,
                    child: ListTile(
                      leading:
                          product['image_path'] != null
                              ? Image.memory(base64Decode(imagePath))
                              : const Icon(Icons.image_not_supported, size: 50),
                      title: Text(product['pd_code']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product['name']),
                          Text('Price: ${product['price']} บาท'),
                          if (product['category'] != null)
                            Text('Category: ${product['category']}'),
                          if (product['description'] != null)
                            Text('Description: ${product['description']}'),
                        ],
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
    );
  }
}
