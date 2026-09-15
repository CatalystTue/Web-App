import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

Future<({String name, Uint8List bytes})?> pickAdminAssetFile() async {
  final input = html.FileUploadInputElement()..multiple = false;
  input.style.display = 'none';
  html.document.body!.append(input);

  final selected = Completer<html.File?>();
  void finish(html.File? file) {
    if (!selected.isCompleted) selected.complete(file);
  }

  final changeSub = input.onChange.listen((_) {
    final files = input.files;
    finish(files != null && files.isNotEmpty ? files.first : null);
  });
  final cancelSub = input.on['cancel'].listen((_) => finish(null));

  input.click();
  final file = await selected.future;
  await changeSub.cancel();
  await cancelSub.cancel();
  input.remove();
  if (file == null) return null;

  final reader = html.FileReader();
  final loaded = Completer<Uint8List>();
  reader.onLoadEnd.listen((_) {
    if (loaded.isCompleted) return;
    final result = reader.result;
    if (result is ByteBuffer) {
      loaded.complete(Uint8List.view(result));
    } else {
      loaded.completeError(StateError('Failed to read file'));
    }
  });
  reader.onError.listen((_) {
    if (!loaded.isCompleted) {
      loaded.completeError(StateError('Failed to read file'));
    }
  });
  reader.readAsArrayBuffer(file);
  final bytes = await loaded.future;
  return (name: file.name, bytes: bytes);
}
