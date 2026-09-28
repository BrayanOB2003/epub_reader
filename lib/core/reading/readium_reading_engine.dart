import 'package:flutter_readium/flutter_readium.dart';

/// Thin wrapper around [FlutterReadium] so the rest of the app does not
/// depend on the plugin singleton directly.
class ReadiumReadingEngine {
  ReadiumReadingEngine({FlutterReadium? readium})
    : _readium = readium ?? FlutterReadium();

  final FlutterReadium _readium;

  Future<Publication> open(String filePath) =>
      _readium.openPublication(filePath);

  Future<void> close() => _readium.closePublication();

  Future<void> goForward() => _readium.goForward();

  Future<void> goBackward() => _readium.goBackward();

  Future<bool> goToLocator(Locator locator) => _readium.goToLocator(locator);

  Future<void> setPreferences(EPUBPreferences preferences) =>
      _readium.setEPUBPreferences(preferences);

  Stream<Locator> get onLocator => _readium.onTextLocatorChanged;
}
