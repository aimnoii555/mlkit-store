import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mlkit_store/database/cart_db.dart';
import 'package:mlkit_store/providers/order_provider.dart';

class ProductCart extends HookConsumerWidget {
  const ProductCart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      getCartsProduct(ref);
      return null;
    }, []);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: Text("My Carts")),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Consumer(
                builder: (context, ref, _) {
                  final carts = ref.watch(storeProductProvider);
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: carts.length,
                    itemBuilder: (context, index) {
                      final item = carts[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 30,
                        ),
                        margin: EdgeInsets.all(6),
                        decoration: BoxDecoration(color: Colors.grey.shade200),
                        child: Stack(
                          children: [
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Product Name: ",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text("${item['name']}"),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Price: ",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text("${item['price']}"),
                                  ],
                                ),
                              ],
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              bottom: 0,
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 60,
                                    height: 40,
                                    child: TextField(
                                      onChanged: (value) async {
                                        await CartDb.query(
                                          "update carts set count = '$value' where id = ${item['id']}",
                                        );

                                        getCartsProduct(ref);
                                      },
                                      controller: TextEditingController(
                                        text: item['count'],
                                      ),
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(4),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      await CartDb.query(
                                        "DELETE FROM carts where id = ${item['id']}",
                                      );

                                      // ref.read(getCartsProductProvider);

                                      getCartsProduct(ref);
                                    },
                                    icon: Icon(
                                      Icons.delete_outline_outlined,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              ElevatedButton(onPressed: () {}, child: Text('Confirm')),
            ],
          ),
        ),
      ),
    );
  }
}
