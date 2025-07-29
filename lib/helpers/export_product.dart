// import 'dart:io';
// import 'package:csv/csv.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';

// Future<void> exportProductsToCSV(List<Map<String, dynamic>> products) async {
//   try {
//     // ขอ permission (เฉพาะ Android)
//     await Permission.storage.request();

//     // แปลงข้อมูลเป็น List<List<String>> สำหรับ CSV
//     List<List<dynamic>> rows = [
//       ['ชื่อสินค้า', 'ราคา', 'หมวดหมู่', 'รายละเอียด'], // header
//     ];

//     for (var product in products) {
//       rows.add([
//         product['name'] ?? '',
//         product['price'] ?? '',
//         product['category'] ?? '',
//         product['description'] ?? '',
//       ]);
//     }

//     // แปลงเป็น CSV string
//     String csvData = const ListToCsvConverter().convert(rows);

//     // หาพาธเก็บไฟล์
//     final directory = await getApplicationDocumentsDirectory();
//     final path = '${directory.path}/products_export.csv';

//     // เขียนไฟล์
//     final file = File(path);
//     await file.writeAsString(csvData);

//     print("✅ บันทึกที่: $path");
//     // เพิ่มการแชร์ไฟล์ก็ได้ด้วย share_plus
//   } catch (e) {
//     print("❌ Export Failed: $e");
//   }
// }
