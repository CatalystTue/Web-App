import 'dart:typed_data';

import 'package:catalyst_flutter_app/Features/admin_auth/pick_admin_asset_file.dart';
import 'package:flutter/material.dart';

class AdminAssetAddButton extends StatelessWidget {
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

  Future<void> _pick() async {
    try {
      final picked = await pickAdminAssetFile();
      if (picked == null) return;
      await onPicked(picked.name, picked.bytes);
    } catch (_) {
      onFailed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Add asset',
      onPressed: enabled && !busy ? _pick : null,
      icon: busy
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.add),
    );
  }
}
