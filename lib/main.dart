import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mlkit_store/classifier.dart';
import 'package:mlkit_store/database/product_db.dart';
import 'package:mlkit_store/pages/order/list_order_page.dart';
import 'package:mlkit_store/pages/product/add_product_page.dart';
import 'package:mlkit_store/pages/product/category_page.dart';
import 'package:mlkit_store/pages/product/list_products_page.dart';
import 'package:mlkit_store/pages/traning/training_page.dart';
import 'package:mlkit_store/providers/order_provider.dart';
import 'package:mlkit_store/scanner.dart';
import 'package:mlkit_store/widgets/my_dialog.dart';
import 'package:mlkit_store/widgets/summary_price.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() => runApp(ProviderScope(child: MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MLKit Store Scanner',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  final List<_HomeFeature> features = [
    _HomeFeature(
      icon: Icons.camera_alt,
      title: 'Scan Product',
      route: ScanPage(),
    ),
    _HomeFeature(
      icon: Icons.inventory,
      title: 'List Products',
      route: ListProductsPage(),
    ),
    _HomeFeature(
      icon: Icons.category,
      title: 'Categories',
      route: CategoryPage(),
    ),
    _HomeFeature(
      icon: Icons.add_box,
      title: 'Add Product',
      route: AddProductPage(),
    ),
    _HomeFeature(
      icon: Icons.list_alt_outlined,
      title: 'Orders',
      route: ListOrderPage(),
    ),
    _HomeFeature(
      icon: Icons.model_training,
      title: 'Train Model',
      route: UploadModelPage(),
    ),
  ];

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('MLKit Store')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        itemCount: features.length,
        itemBuilder: (context, index) {
          final feature = features[index];
          return GestureDetector(
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => feature.route),
                ),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(feature.icon, size: 48, color: Colors.indigo),
                    SizedBox(height: 12),
                    Text(feature.title, style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HomeFeature {
  final IconData icon;
  final String title;
  final Widget route;

  _HomeFeature({required this.icon, required this.title, required this.route});
}

class ScanPage extends HookConsumerWidget {
  const ScanPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState<bool>(false);
    final classificationResult = useState<String>("");

    Future<void> pickImageAndDetectObjects() async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.camera);

      if (pickedFile == null) return;

      isLoading.value = true;

      try {
        final classifier = Classifier(); // assume this exists
        await classifier.loadModel(); // assume loadModel() is valid
        final result = await classifier.classify(File(pickedFile.path));

        classificationResult.value = result;
        isLoading.value = false;

        print('วัตถุที่ตรวจพบ: $result');

        final query = await ProductDb.query(
          "SELECT name, pd_code, price FROM products where name = '$result' or pd_code = '$result' or barcode = '$result' ",
        );

        if (query.isNotEmpty) {
          addProductToStore(ref, query.first);
          alertOrder(
            productName: query.first['name'].toString(),
            context: context,
            title: 'Created Order',
            icon: Icons.check_circle,
            iconColor: Colors.green,
          );
        } else {
          alertOrder(
            title: 'Product Not Found.',
            productName: '',
            context: context,
            icon: Icons.error_outline_outlined,
            iconColor: Colors.red,
          );
        }
      } catch (e) {
        isLoading.value = false;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: ${e.toString()}')),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Scan Product')),
      body:
          isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  Column(
                    children: [
                      // กล้องแสดงผลเต็มครึ่งจอ
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade500),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => Scanner()),
                              );
                            },
                            child: Image.network(
                              'https://cdn-icons-png.flaticon.com/128/5393/5393325.png',
                            ),
                          ),
                        ),
                      ),
                      // ปุ่มและข้อมูลผลลัพธ์
                      Expanded(
                        flex: 1,
                        child: Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade500),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.camera,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                if (classificationResult.value.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                    ),
                                    child: Text(
                                      'result: $classificationResult',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                const SizedBox(height: 32),
                                ElevatedButton(
                                  onPressed: pickImageAndDetectObjects,
                                  child: const Text('Scan with Camera'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 90),
                    ],
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: SummaryPrice(),
                  ),
                ],
              ),
    );
  }
}

class StockListPage extends StatelessWidget {
  final List<String> mockItems = [
    'เสื้อยืดคอกลม',
    'หมวกแก๊ปสีน้ำเงิน',
    'รองเท้าผ้าใบไซส์ 42',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('รายการสต็อก')),
      body: ListView.builder(
        itemCount: mockItems.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.shopping_bag),
            title: Text(mockItems[index]),
            trailing: Icon(Icons.keyboard_arrow_right),
          );
        },
      ),
    );
  }
}

// class AddProductPage extends StatelessWidget {
//   final _formKey = GlobalKey<FormState>();

//   AddProductPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('เพิ่มสินค้า')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 decoration: InputDecoration(labelText: 'ชื่อสินค้า'),
//               ),
//               TextFormField(
//                 decoration: InputDecoration(labelText: 'รหัสสินค้า'),
//               ),
//               TextFormField(
//                 decoration: InputDecoration(labelText: 'จำนวนในสต็อก'),
//                 keyboardType: TextInputType.number,
//               ),
//               SizedBox(height: 24),
//               ElevatedButton(onPressed: () {}, child: Text('บันทึกสินค้า')),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
