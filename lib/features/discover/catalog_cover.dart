import 'dart:typed_data';

import 'package:epub_reader/app/schedule_widgets.dart';
import 'package:epub_reader/features/discover/data/cover_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CatalogCover extends ConsumerStatefulWidget {
  const CatalogCover({
    required this.bookId,
    required this.url,
    required this.width,
    required this.height,
    required this.title,
    super.key,
  });

  final String bookId;
  final String? url;
  final double width;
  final double height;
  final String title;

  @override
  ConsumerState<CatalogCover> createState() => _CatalogCoverState();
}

class _CatalogCoverState extends ConsumerState<CatalogCover> {
  Uint8List? _bytes;
  var _ticket = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(CatalogCover oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bookId != widget.bookId || oldWidget.url != widget.url) {
      _load();
    }
  }

  Future<void> _load() async {
    final ticket = ++_ticket;
    final bytes = await ref
        .read(coverCacheProvider)
        .load(id: widget.bookId, url: widget.url);
    if (!mounted || ticket != _ticket) return;
    setState(() => _bytes = bytes);
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _bytes;
    if (bytes == null || bytes.isEmpty) {
      return ScheduleCoverPlaceholder(
        width: widget.width,
        height: widget.height,
        title: widget.title,
      );
    }
    return ScheduleCover(
      bytes: bytes,
      width: widget.width,
      height: widget.height,
      title: widget.title,
    );
  }
}
