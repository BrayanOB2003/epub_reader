import 'package:flutter_readium/flutter_readium.dart';

/// Thin wrapper around [FlutterReadium] so the rest of the app does not
/// depend on the plugin singleton directly.
class ReadiumReadingEngine {
  ReadiumReadingEngine({FlutterReadium? readium}) : _readium = readium ?? FlutterReadium();

  final FlutterReadium _readium;

  Future<Publication> open(String filePath) => _readium.openPublication(filePath);

  Future<void> close() => _readium.closePublication();

  Stream<Locator> get onLocator => _readium.onTextLocatorChanged;
}
