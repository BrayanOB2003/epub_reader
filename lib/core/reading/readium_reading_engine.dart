import 'dart:typed_data';

import 'package:flutter_readium/flutter_readium.dart';

/// Thin wrapper around [FlutterReadium] so the rest of the app does not
/// depend on the plugin singleton directly.
class ReadiumReadingEngine {
  ReadiumReadingEngine({FlutterReadium? readium})
    : _readium = readium ?? FlutterReadium();

  final FlutterReadium _readium;

  Future<Publication> open(String filePath) =>
      _readium.openPublication(filePath);

  Future<Publication> load(String filePath) =>
      _readium.loadPublication(filePath);

  /// PNG cover. For a PDF this is the first page. Null when there is none.
  Future<Uint8List?> cover(String filePath) =>
      _readium.publicationCover(filePath);

  Future<void> close() => _readium.closePublication();

  Future<void> goForward() => _readium.goForward();

  Future<void> goBackward() => _readium.goBackward();

  Future<bool> goToLocator(Locator locator) => _readium.goToLocator(locator);

  Future<void> setPreferences(EPUBPreferences preferences) =>
      _readium.setEPUBPreferences(preferences);

  Future<void> setPdfPreferences(PDFPreferences preferences) =>
      _readium.setPDFPreferences(preferences);

  Future<void> applyDecorations(
    String id,
    List<ReaderDecoration> decorations,
  ) => _readium.applyDecorations(id, decorations);

  Stream<Locator> get onLocator => _readium.onTextLocatorChanged;
}
