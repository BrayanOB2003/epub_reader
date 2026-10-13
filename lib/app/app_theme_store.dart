import 'dart:io';

import 'package:epub_reader/app/schedule_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

final appThemeStoreProvider = Provider<AppThemeStore>((ref) {
  return AppThemeStore();
});

final appThemeProvider = AsyncNotifierProvider<AppThemeController, AppThemeId>(
  AppThemeController.new,
);

class AppThemeController extends AsyncNotifier<AppThemeId> {
  @override
  Future<AppThemeId> build() {
    return ref.watch(appThemeStoreProvider).read();
  }

  Future<void> select(AppThemeId id) async {
    await ref.read(appThemeStoreProvider).write(id);
    state = AsyncData(id);
  }
}

class AppThemeStore {
  AppThemeStore({Future<Directory> Function()? documentsDirectory})
    : _documentsDirectory =
          documentsDirectory ?? getApplicationDocumentsDirectory;

  final Future<Directory> Function() _documentsDirectory;

  Future<AppThemeId> read() async {
    try {
      final file = await _file();
      if (!file.existsSync()) return AppThemeId.programa;
      return AppThemeId.byId(await file.readAsString());
    } catch (_) {
      return AppThemeId.programa;
    }
  }

  Future<void> write(AppThemeId id) async {
    final file = await _file();
    await file.parent.create(recursive: true);
    await file.writeAsString(id.name, flush: true);
  }

  Future<File> _file() async {
    final docs = await _documentsDirectory();
    return File(p.join(docs.path, 'app_theme.txt'));
  }
}
