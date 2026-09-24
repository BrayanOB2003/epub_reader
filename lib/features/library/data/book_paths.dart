import 'dart:io';

import 'package:path/path.dart' as p;

/// Path stored on the library row. Files inside the documents directory are
/// stored relative to it, so a new iOS container still finds them.
String portableBookPath(String stored, String documentsPath) {
  if (!p.isAbsolute(stored)) return p.normalize(stored);
  if (p.isWithin(documentsPath, stored)) return p.relative(stored, from: documentsPath);

  final name = p.basename(stored);
  final parent = p.basename(p.dirname(stored));
  final folder = parent == 'books' || parent == 'covers' ? parent : 'books';
  final recovered = p.join(documentsPath, folder, name);
  if (File(recovered).existsSync()) return p.join(folder, name);
  if (File(stored).existsSync()) return stored;
  return p.join(folder, name);
}

String absoluteBookPath(String stored, String documentsPath) {
  if (p.isAbsolute(stored)) return stored;
  return p.normalize(p.join(documentsPath, stored));
}
