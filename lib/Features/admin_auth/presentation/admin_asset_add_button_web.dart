import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

class AdminAssetAddButton extends StatefulWidget {
  const AdminAssetAddButton({
    super.key,
    required this.enabled,
    required this.busy,
    required this.onPicked,
    required this.onFailed,
  });

  final bool enabled;
  final bool busy;
  final Future<void> Function(String name, Uint8List bytes) onPicked;
  final VoidCallback onFailed;

  @override
  State<AdminAssetAddButton> createState() => _AdminAssetAddButtonState();
}

class _AdminAssetAddButtonState extends State<AdminAssetAddButton> {
  late final String _viewType;

  @override
  void initState() {
    super.initState();
    _viewType = 'admin-asset-add-${identityHashCode(this)}';
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final input = html.FileUploadInputElement()
        ..multiple = false
        ..title = 'Add asset';
      input.style
        ..width = '100%'
        ..height = '100%'
        ..opacity = '0'
        ..cursor = 'pointer'
        ..border = '0'
        ..padding = '0'
        ..margin = '0'
        ..display = 'block';
      input.onChange.listen((_) => unawaited(_onInputChange(input)));
      return input;
    });
  }

  Future<void> _onInputChange(html.FileUploadInputElement input) async {
    final files = input.files;
    input.value = '';
    if (files == null || files.isEmpty) return;
    final file = files.first;
    try {
      final bytes = await _readBytes(file);
      await widget.onPicked(file.name, bytes);
    } catch (_) {
      widget.onFailed();
    }
  }

  Future<Uint8List> _readBytes(html.File file) {
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
    return loaded.future;
  }

  @override
  Widget build(BuildContext context) {
    final canPick = widget.enabled && !widget.busy;
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          IconButton(
            tooltip: 'Add asset',
            onPressed: canPick ? () {} : null,
            icon: widget.busy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add),
          ),
          if (canPick)
            Positioned.fill(
              child: HtmlElementView(viewType: _viewType),
            ),
        ],
      ),
    );
  }
}
