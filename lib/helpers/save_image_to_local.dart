// import 'dart:io';

// import 'package:path_provider/path_provider.dart';
// import 'package:uuid/uuid.dart';

// Future<String?> savePickedImageToAppDir(File pickedFile) async {
//   try {
//     final appDir = await getApplicationDocumentsDirectory();
//     final imageDir = Directory("${appDir.path}/product_images");

//     if (!await imageDir.exists()) {
//       await imageDir.create(recursive: true);
//     }

//     final uuid = const Uuid().v4();
//     final fileName = "$uuid.jpg";

//     final saveImage = File('${imageDir.path}/$fileName');
//     final newImage = await pickedFile.copy(saveImage.path);

//     return newImage.path; // << เก็บ path นี้ในฐานข้อมูล
//   } catch (e) {
//     print("❌ Error saving image: $e");
//     return null;
//   }
// }
