import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:xml/xml.dart';

class EpubMetadata {
  const EpubMetadata({required this.title, this.author, this.coverBytes, this.coverExtension});

  final String title;
  final String? author;
  final Uint8List? coverBytes;
  final String? coverExtension;
}

class EpubFormatException implements Exception {
  const EpubFormatException(this.message);

  final String message;

  @override
  String toString() => message;
}

EpubMetadata readEpubMetadata(Uint8List bytes, {String fallbackTitle = 'Sin título'}) {
  final archive = ZipDecoder().decodeBytes(bytes);
  final containerFile = _findEntry(archive, 'META-INF/container.xml');
  if (containerFile == null) {
    throw const EpubFormatException('El archivo no es un EPUB válido.');
  }

  final container = XmlDocument.parse(utf8.decode(containerFile.content));
  final rootfile = _firstLocal(container, 'rootfile');
  final opfPath = rootfile?.getAttribute('full-path');
  if (opfPath == null || opfPath.isEmpty) {
    throw const EpubFormatException('El EPUB no indica su archivo de contenido.');
  }

  final opfFile = _findEntry(archive, opfPath);
  if (opfFile == null) {
    throw const EpubFormatException('No se encontró el contenido del EPUB.');
  }

  final opf = XmlDocument.parse(utf8.decode(opfFile.content));
  final title = _textOf(opf, 'title')?.trim();
  final authors = _textsOf(opf, 'creator').map((value) => value.trim()).where((value) => value.isNotEmpty).toList();
  final cover = _readCover(archive, opf, opfPath);

  return EpubMetadata(
    title: (title == null || title.isEmpty) ? fallbackTitle : title,
    author: authors.isEmpty ? null : authors.join(', '),
    coverBytes: cover?.bytes,
    coverExtension: cover?.extension,
  );
}

class _Cover {
  const _Cover(this.bytes, this.extension);

  final Uint8List bytes;
  final String extension;
}

_Cover? _readCover(Archive archive, XmlDocument opf, String opfPath) {
  final items = opf.descendants.whereType<XmlElement>().where((element) => element.name.local == 'item');
  String? coverId;
  for (final meta in opf.descendants.whereType<XmlElement>()) {
    if (meta.name.local == 'meta' && meta.getAttribute('name') == 'cover') {
      coverId = meta.getAttribute('content');
      break;
    }
  }

  XmlElement? coverItem;
  for (final item in items) {
    final properties = item.getAttribute('properties') ?? '';
    if (properties.split(RegExp(r'\s+')).contains('cover-image')) {
      coverItem = item;
      break;
    }
  }
  if (coverItem == null && coverId != null) {
    for (final item in items) {
      if (item.getAttribute('id') == coverId) {
        coverItem = item;
        break;
      }
    }
  }
  final href = coverItem?.getAttribute('href');
  if (href == null || href.isEmpty) return null;

  final opfDir = p.posix.dirname(opfPath.replaceAll('\\', '/'));
  final coverPath = p.posix.normalize(p.posix.join(opfDir == '.' ? '' : opfDir, Uri.decodeFull(href)));
  final file = _findEntry(archive, coverPath);
  if (file == null || file.content.isEmpty) return null;

  final mediaType = coverItem?.getAttribute('media-type') ?? '';
  return _Cover(file.content, _extensionFor(coverPath, mediaType));
}

String _extensionFor(String path, String mediaType) {
  final fromPath = p.posix.extension(path).replaceFirst('.', '').toLowerCase();
  if (fromPath == 'jpg' || fromPath == 'jpeg' || fromPath == 'png' || fromPath == 'webp' || fromPath == 'gif') {
    return fromPath == 'jpeg' ? 'jpg' : fromPath;
  }
  return switch (mediaType) {
    'image/png' => 'png',
    'image/webp' => 'webp',
    'image/gif' => 'gif',
    _ => 'jpg',
  };
}

XmlElement? _firstLocal(XmlNode node, String local) {
  for (final element in node.descendants.whereType<XmlElement>()) {
    if (element.name.local == local) return element;
  }
  return null;
}

String? _textOf(XmlNode node, String local) {
  final values = _textsOf(node, local);
  return values.isEmpty ? null : values.first;
}

List<String> _textsOf(XmlNode node, String local) {
  return node.descendants
      .whereType<XmlElement>()
      .where((element) => element.name.local == local)
      .map((element) => element.innerText)
      .toList();
}

ArchiveFile? _findEntry(Archive archive, String path) {
  final normalized = path.replaceAll('\\', '/').replaceFirst(RegExp(r'^/'), '');
  for (final file in archive.files) {
    final name = file.name.replaceAll('\\', '/').replaceFirst(RegExp(r'^/'), '');
    if (name == normalized) return file;
  }
  final lower = normalized.toLowerCase();
  for (final file in archive.files) {
    final name = file.name.replaceAll('\\', '/').replaceFirst(RegExp(r'^/'), '').toLowerCase();
    if (name == lower) return file;
  }
  return null;
}
