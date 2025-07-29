import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class Classifier {
  late Interpreter _interpreter;
  late List<String> _labels;

  static const int inputSize = 224;

  Future<void> loadModel() async {
    final dir =
        await getApplicationDocumentsDirectory(); // เปลี่ยนเป็น Documents
    final files = dir.listSync();

    // หาชื่อไฟล์ model (.tflite)
    final modelFile = files.firstWhere(
      (file) => file.path.endsWith('.tflite'),
      orElse: () => throw Exception('Model .tflite not found'),
    );

    // หาชื่อไฟล์ labels (.txt)
    final labelFile = files.firstWhere(
      (file) => file.path.endsWith('.txt'),
      orElse: () => throw Exception('Label .txt not found'),
    );

    // โหลดโมเดลจากเครื่อง
    _interpreter = Interpreter.fromFile(File(modelFile.path));

    // โหลด label จากไฟล์ .txt ในเครื่อง
    final labelData = await File(labelFile.path).readAsString();

    _labels =
        labelData
            .split('\n')
            .where((e) => e.trim().isNotEmpty)
            .map(
              (line) => line.split(' ').sublist(1).join(' '),
            ) // ตัดเลขหน้าออก
            .toList();
  }

  Future<String> classify(File imageFile) async {
    final image = img.decodeImage(imageFile.readAsBytesSync())!;
    final resizedImage = img.copyResize(
      image,
      width: inputSize,
      height: inputSize,
    );

    // สร้าง input (Uint32 grayscale)
    var input = imageToByteListFloat32(resizedImage);

    //  ใช้ double สำหรับโมเดล quantized
    var output = List.filled(_labels.length, 0).reshape([1, _labels.length]);

    // รันโมเดล
    _interpreter.run(input, output);

    // แปลงผลลัพธ์
    final prediction = (output[0] as List).cast<double>();

    final maxIndex = prediction.indexWhere(
      (e) => e == prediction.reduce((a, b) => a > b ? a : b),
    );

    print('5555');

    return _labels[maxIndex]; // เช่น "Person"
  }

  List<List<List<List<double>>>> imageToByteListFloat32(img.Image image) {
    final input = List.generate(
      inputSize,
      (y) => List.generate(inputSize, (x) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r.toDouble() / 255.0;
        final g = pixel.g.toDouble() / 255.0;
        final b = pixel.b.toDouble() / 255.0;
        return [r, g, b]; // RGB
      }),
    );
    return [input]; // shape: [1, 224, 224, 3]
  }
}
