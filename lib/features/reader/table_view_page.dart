import 'package:epub_reader/features/reader/reader_preferences.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_readium/flutter_readium.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// The publication table, at the size it could not fit on the page.
///
/// Colors and type come from the reader at the moment the icon was tapped.
/// Pinch to zoom. JavaScript stays off, and publication images are not loaded.
class TableViewPage extends StatefulWidget {
  const TableViewPage({required this.event, super.key});

  final EpubTableOpenEvent event;

  @override
  State<TableViewPage> createState() => _TableViewPageState();
}

class _TableViewPageState extends State<TableViewPage> {
  late final WebViewController _controller;
  late final Color _background;
  late final Color _foreground;

  @override
  void initState() {
    super.initState();
    _background =
        tableViewColor(widget.event.backgroundColor) ?? readerLightBackground;
    _foreground = tableViewColor(widget.event.textColor) ?? readerLightText;
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.disabled)
      ..setBackgroundColor(_background)
      ..enableZoom(true)
      ..loadHtmlString(tableViewDocument(widget.event));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _foreground,
        elevation: 0,
        title: Text(l10n.tableView),
        leading: IconButton(
          tooltip: l10n.close,
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}

String tableViewDocument(EpubTableOpenEvent event) {
  final fontSize = event.fontSizePx ?? 16;
  final family = _cssValue(event.fontFamily);
  final text = _cssValue(event.textColor);
  final background = _cssValue(event.backgroundColor);
  final table = _stripActiveContent(event.html);
  return '''
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=5, user-scalable=yes">
<style>
  html { font-size: ${fontSize}px; }
  body {
    margin: 0;
    padding: 16px;
    color: $text;
    background: $background;
    font-family: $family;
  }
  table {
    border-collapse: collapse;
    width: max-content;
    min-width: 100%;
  }
  td, th {
    border: 1px solid currentColor;
    padding: 0.5em 0.65em;
    vertical-align: top;
    text-align: start;
  }
</style>
</head>
<body>$table</body>
</html>
''';
}

String _cssValue(String? value) => (value ?? '').replaceAll(RegExp('[<>]'), '');

String _stripActiveContent(String html) => html
    .replaceAll(
      RegExp('<script\\b[^>]*>[\\s\\S]*?</script>', caseSensitive: false),
      '',
    )
    .replaceAll(
      RegExp(
        '\\son\\w+\\s*=\\s*("[^"]*"|\'[^\']*\'|[^\\s>]+)',
        caseSensitive: false,
      ),
      '',
    );

Color? tableViewColor(String? value) {
  if (value == null || value.isEmpty) return null;
  final hex = RegExp(r'^#([0-9a-fA-F]{6})$').firstMatch(value.trim());
  if (hex != null) {
    return Color(int.parse('FF${hex.group(1)}', radix: 16));
  }
  final rgb = RegExp(r'rgba?\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)')
      .firstMatch(value);
  if (rgb == null) return null;
  return Color.fromARGB(
    255,
    int.parse(rgb.group(1)!),
    int.parse(rgb.group(2)!),
    int.parse(rgb.group(3)!),
  );
}
