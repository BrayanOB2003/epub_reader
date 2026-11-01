import 'dart:io';

import 'package:epub_reader/app/schedule_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

final appFontStoreProvider = Provider<AppFontStore>((ref) {
  return AppFontStore();
});

final appFontProvider = AsyncNotifierProvider<AppFontController, AppFontId>(
  AppFontController.new,
);

class AppFontController extends AsyncNotifier<AppFontId> {
  @override
  Future<AppFontId> build() {
    return ref.watch(appFontStoreProvider).read();
  }

  Future<void> select(AppFontId id) async {
    await ref.read(appFontStoreProvider).write(id);
    state = AsyncData(id);
  }
}

class AppFontStore {
  AppFontStore({Future<Directory> Function()? documentsDirectory})
    : _documentsDirectory =
          documentsDirectory ?? getApplicationDocumentsDirectory;

  final Future<Directory> Function() _documentsDirectory;

  Future<AppFontId> read() async {
    try {
      final file = await _file();
      if (!file.existsSync()) return AppFontId.sistema;
      return AppFontId.byId(await file.readAsString());
    } catch (_) {
      return AppFontId.sistema;
    }
  }

  Future<void> write(AppFontId id) async {
    final file = await _file();
    await file.parent.create(recursive: true);
    await file.writeAsString(id.name, flush: true);
  }

  Future<File> _file() async {
    final docs = await _documentsDirectory();
    return File(p.join(docs.path, 'app_font.txt'));
  }
}
