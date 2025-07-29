import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ModelListPage extends StatefulWidget {
  const ModelListPage({super.key});

  @override
  State<ModelListPage> createState() => _ModelListPageState();
}

class _ModelListPageState extends State<ModelListPage> {
  List<FileSystemEntity> _modelFiles = [];

  @override
  void initState() {
    super.initState();
    _loadModelFiles();
  }

  Future<void> _loadModelFiles() async {
    final dir = await getApplicationDocumentsDirectory();

    final files =
        dir.listSync().where((file) {
          final ext = file.path.split('.').last.toLowerCase();
          return ext == 'tflite' || ext == 'txt';
        }).toList();

    setState(() => _modelFiles = files);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Model and label list')),
      body:
          _modelFiles.isEmpty
              ? const Center(child: Text('No files have been uploaded yet.'))
              : ListView.builder(
                itemCount: _modelFiles.length,
                itemBuilder: (context, index) {
                  final file = _modelFiles[index];
                  final filename = file.path.split('/').last;

                  return ListTile(
                    leading: const Icon(Icons.insert_drive_file),
                    title: Text(filename),
                    subtitle: Text(file.path),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await File(file.path).delete();
                        _loadModelFiles();
                      },
                    ),
                    onTap: () {
                      debugPrint('เลือกไฟล์: ${file.path}');
                    },
                  );
                },
              ),
    );
  }
}
