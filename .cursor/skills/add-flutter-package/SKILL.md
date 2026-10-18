---
name: add-flutter-package
description: >-
  Add a Flutter or Dart package in epub_reader and commit a pubspec.lock that
  still pins flutter_readium to the git fork. Use when adding, removing, or
  upgrading a pub dependency, editing pubspec.yaml, running flutter pub add or
  flutter pub get, or committing pubspec.lock. Also use when the user says
  agregar un paquete, nueva dependencia, or subir el lock.
---

# Add a Flutter package

`pubspec_overrides.yaml` is gitignored. It points `flutter_readium` at `../flutter_readium/flutter_readium`. While that file is present, `flutter pub get` rewrites `pubspec.lock` so `flutter_readium` and `flutter_readium_platform_interface` use `source: path`.

The lock that gets committed keeps the git pin from `pubspec.yaml`:

```yaml
flutter_readium:
  git:
    url: https://github.com/BrayanOB2003/flutter_readium.git
    ref: prod
    path: flutter_readium
```

CI then runs `flutter pub upgrade flutter_readium` and takes the latest `prod` commit. A path lock breaks that.

## Add a package

1. If `pubspec_overrides.yaml` exists, move it aside:
   `mv pubspec_overrides.yaml pubspec_overrides.yaml.bak`
2. Add the dependency in `pubspec.yaml` (or `flutter pub add <package>`).
3. Run `flutter pub get`. Prefer `fvm flutter` when `fvm` is on PATH.
4. In `pubspec.lock`, confirm both Readium packages still have `source: git`, ref `prod`, and url `https://github.com/BrayanOB2003/flutter_readium.git`, and that the new package is present. If either Readium package has `source: path`, stop. Do not stage the lock.
5. Restore local resolution:
   `mv pubspec_overrides.yaml.bak pubspec_overrides.yaml`
   then `flutter pub get`.
6. Leave that second lock change unstaged. It is the local path resolution.

## Commit the lock

Commit `pubspec.yaml` and `pubspec.lock` only when the user asks, and only the lock from step 4.

If the override was already restored, repeat steps 1–4, stage those two files, commit, then run step 5 again. Do not stage `pubspec.lock` after step 5.

Never commit `pubspec_overrides.yaml`.

The same steps apply when removing or upgrading a dependency: the committed lock includes that change and still has `source: git` for both Readium packages.
