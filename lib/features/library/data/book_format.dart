import 'dart:typed_data';

/// A PDF header may sit anywhere in the first 1024 bytes.
bool looksLikePdf(Uint8List bytes) {
  final limit = bytes.length < 1024 ? bytes.length : 1024;
  for (var index = 0; index <= limit - 5; index++) {
    if (bytes[index] == 0x25 &&
        bytes[index + 1] == 0x50 &&
        bytes[index + 2] == 0x44 &&
        bytes[index + 3] == 0x46 &&
        bytes[index + 4] == 0x2D) {
      return true;
    }
  }
  return false;
}
