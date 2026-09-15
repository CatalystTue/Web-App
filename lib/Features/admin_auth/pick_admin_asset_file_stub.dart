import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

Future<({String name, Uint8List bytes})?> pickAdminAssetFile() async {
  final picked = await FilePicker.platform.pickFiles(withData: true);
  if (picked == null || picked.files.isEmpty) return null;
  final file = picked.files.first;
  final bytes = file.bytes;
  if (bytes == null) {
    throw StateError('Failed to read file');
  }
  return (name: file.name, bytes: bytes);
}
