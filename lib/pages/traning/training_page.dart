import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mlkit_store/pages/traning/list_traning_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class UploadModelPage extends StatefulWidget {
  const UploadModelPage({Key? key}) : super(key: key);

  @override
  State<UploadModelPage> createState() => _UploadModelPageState();
}

class _UploadModelPageState extends State<UploadModelPage> {
  File? _modelFile;
  File? _labelFile;
  Interpreter? interpreter;
  List<String> _labels = [];

  Future<void> pickModelFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null) {
      final file = File(result.files.single.path!);
      final appDir = await getApplicationDocumentsDirectory();
      final savedFile = await file.copy('${appDir.path}/model.tflite');
      setState(() => _modelFile = savedFile);
    }
  }

  Future<void> pickLabelFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null) {
      final file = File(result.files.single.path!);
      final appDir = await getApplicationDocumentsDirectory();
      final savedFile = await file.copy('${appDir.path}/labels.txt');
      setState(() => _labelFile = savedFile);
    }
  }

  Future<void> loadModel() async {
    try {
      if (_modelFile == null || _labelFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please Upload file model and labels')),
        );
        return;
      }

      interpreter = Interpreter.fromFile(_modelFile!);

      final labelText = await _labelFile!.readAsString();
      _labels =
          labelText.split('\n').where((e) => e.trim().isNotEmpty).toList();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Uploaded model Success')));
    } catch (e) {
      debugPrint('loadModel error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Upload model Failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Model (.tflite + .txt)'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              color: Colors.black,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ModelListPage()),
                );
              },
              icon: Icon(Icons.view_module_outlined),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: pickModelFile,
              icon: const Icon(Icons.upload_file),
              label: const Text('Select File .tflite'),
            ),
            if (_modelFile != null) Text('✔ File model: ${_modelFile!.path}'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: pickLabelFile,
              icon: const Icon(Icons.upload_file),
              label: const Text('Select File labels.txt'),
            ),
            if (_labelFile != null) Text('✔ File label: ${_labelFile!.path}'),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: loadModel,
              icon: const Icon(Icons.check),
              label: const Text('Load model'),
            ),
            const SizedBox(height: 16),
            if (_labels.isNotEmpty)
              Text('Uploaded label ${_labels.length} Items'),
          ],
        ),
      ),
    );
  }
}
