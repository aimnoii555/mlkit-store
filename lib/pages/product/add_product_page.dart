import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mlkit_store/database/product_db.dart';
import 'package:mlkit_store/helpers/barcode_scanner.dart';
import 'package:mlkit_store/providers/add_product_provider.dart';

class AddProductPage extends HookConsumerWidget {
  const AddProductPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ProductDb();

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(imageProvider.notifier).state = null;
      });
      return null;
    }, []);

    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameController = useTextEditingController();
    final priceController = useTextEditingController();
    final detailController = useTextEditingController();
    final selectedCategory = useState<String?>(null);
    final barcodeController = useTextEditingController();
    final stockController = useTextEditingController();

    final fileImage = ref.watch(imageProvider);

    final categories = [
      'เครื่องใช้ไฟฟ้า',
      'แฟชั่น',
      'อาหาร',
      'อุปกรณ์กีฬา',
      'อื่นๆ',
    ];

    return Scaffold(
      appBar: AppBar(
        actions: [
          Tooltip(
            message: 'import product',
            child: GestureDetector(
              onTap: () {},

              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.network(
                  'https://cdn-icons-png.flaticon.com/128/8765/8765164.png',
                  width: 30,
                ),
              ),
            ),
          ),
        ],
        title: const Text(
          'Add Product',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(
                  controller: barcodeController,
                  label: 'Barcode',
                  icon: Icons.qr_code_2_outlined,
                  suffixIcon: IconButton(
                    onPressed: () async {
                      final barcode = await barcodeScanner();
                      barcodeController.text = barcode;
                    },
                    icon: Icon(Icons.qr_code_scanner_outlined),
                  ),
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: nameController,
                  label: 'Product Name',
                  icon: Icons.shopping_bag,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: priceController,
                  label: 'Price',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: stockController,
                  keyboardType: TextInputType.number,
                  label: 'Stock',
                  icon: Icons.list_alt_outlined,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory.value,
                  items:
                      categories
                          .map(
                            (category) => DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            ),
                          )
                          .toList(),
                  onChanged: (value) => selectedCategory.value = value,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    prefixIcon: const Icon(Icons.category),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator:
                      (value) =>
                          value == null ? 'Please Select Category name' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: detailController,
                  label: 'Description',
                  icon: Icons.description,
                  maxLines: 4,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        _modalBottomSheetMenu(context: context, ref: ref);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        child:
                            fileImage != null
                                ? Image.file(
                                  File(fileImage.path),
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                )
                                : Icon(Icons.photo_outlined, size: 80),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 100),

                ElevatedButton.icon(
                  onPressed: () async {
                    // print('select = ${selectedCategory.value}');

                    // final savedPath = await savePickedImageToAppDir(
                    //   File(fileImage!.path),
                    // );

                    try {
                      final bytes = await File(fileImage!.path).readAsBytes();
                      final base64Image = base64Encode(bytes);

                      final queryProducts = await ProductDb.query(
                        "SELECT pd_code FROM products order by pd_code desc limit 1",
                      );

                      String newCode = "";

                      if (queryProducts.isNotEmpty) {
                        String pdCode = queryProducts.first['pd_code'];
                        String numericPart = pdCode.replaceAll(
                          RegExp(r'[^0-9]'),
                          '',
                        );
                        int nextNumber = int.parse(numericPart) + 1;
                        newCode = generateProductCode(nextNumber);
                      } else {
                        newCode = generateProductCode(1);
                      }

                      final query = await ProductDb.query(
                        "SELECT * FROM products where pd_code = '$newCode' ",
                      );

                      if (query.isEmpty) {
                        final insert = await db.insertProduct({
                          'barcode': barcodeController.text,
                          'pd_code': newCode,
                          'name': nameController.text,
                          'price': priceController.text,
                          'pd_stock': stockController.text,
                          'category': selectedCategory.value,
                          'description': detailController.text,
                          'image_path': base64Image,
                        });

                        print('insert = $insert');
                      }
                    } catch (e) {
                      print('e = $e');
                    }
                    // if (formKey.currentState!.validate()) {
                    //   ScaffoldMessenger.of(context).showSnackBar(
                    //     const SnackBar(content: Text('Saved Product Success')),
                    //   );
                    // }
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    textStyle: const TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String generateProductCode(int number) {
    return 'PD${number.toString().padLeft(5, '0')}';
  }

  void _modalBottomSheetMenu({
    required BuildContext context,
    required WidgetRef ref,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return Container(
          height: 250.0,
          color: Colors.transparent, //could change this to Color(0xFF737373),
          //so you don't have to change MaterialApp canvasColor
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(10.0),
                topRight: const Radius.circular(10.0),
              ),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                      // final gallery = await uploadImagePicker(
                      //   ImageSource.gallery,
                      // );
                      final picker = ImagePicker();
                      final pickedFile = await picker.pickImage(
                        source: ImageSource.camera,
                      );
                      ref.read(imageProvider.notifier).state = XFile(
                        pickedFile!.path,
                      );
                    },

                    child: Image.network(
                      'https://cdn-icons-png.flaticon.com/128/739/739249.png',
                    ),
                  ),
                  // GestureDetector(
                  //   onTap: () async {
                  //     Navigator.pop(context);
                  //     final camera = await uploadImagePicker(
                  //       ImageSource.camera,
                  //     );
                  //     ref.read(imageProvider.notifier).state = camera;
                  //   },
                  //   child: Image.network(
                  //     'https://cdn-icons-png.flaticon.com/128/45/45010.png',
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<XFile> uploadImagePicker(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);
    return image!;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    Widget? suffixIcon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,

      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator:
          (value) =>
              value == null || value.isEmpty ? 'Please Enter $label' : null,
    );
  }
}
