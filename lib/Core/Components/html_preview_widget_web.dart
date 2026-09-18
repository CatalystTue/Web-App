import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';

import 'html_preview_lockup.dart';

Widget createHtmlPreview(String htmlContent, {Key? key}) {
  return _HtmlPreviewWeb(
    key: key,
    htmlContent: htmlContent,
  );
}

class _HtmlPreviewWeb extends StatefulWidget {
  final String htmlContent;

  const _HtmlPreviewWeb({
    super.key,
    required this.htmlContent,
  });

  @override
  State<_HtmlPreviewWeb> createState() => _HtmlPreviewWebState();
}

class _HtmlPreviewWebState extends State<_HtmlPreviewWeb> {
  late final String _viewType;
  late final html.IFrameElement _iframe;
  int _loadId = 0;

  @override
  void initState() {
    super.initState();
    _viewType = 'html-preview-${DateTime.now().microsecondsSinceEpoch}';
    _iframe = html.IFrameElement()
      ..style.border = '0'
      ..style.width = '100%'
      ..style.height = '100%';

    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      return _iframe;
    });
    _setHtml(widget.htmlContent);
  }

  @override
  void didUpdateWidget(covariant _HtmlPreviewWeb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.htmlContent != widget.htmlContent) {
      _setHtml(widget.htmlContent);
    }
  }

  Future<void> _setHtml(String htmlContent) async {
    final id = ++_loadId;
    final srcdoc = await htmlPreviewSrcdoc(htmlContent);
    if (!mounted || id != _loadId) return;
    _iframe.srcdoc = srcdoc;
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewType);
  }
}
