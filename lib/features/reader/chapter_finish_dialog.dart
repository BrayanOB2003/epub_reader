import 'package:epub_reader/features/reader/contents.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// The chapter name to offer when the reader is about to close.
///
/// The locator title wins. Otherwise the index entry, or its place when
/// that entry has no title. Null when neither source has a name.
String? finishChapterTitle({
  required String? locatorTitle,
  required List<ContentsNode> roots,
  required String href,
  required String untitled,
  required String Function(int position) chapter,
}) {
  final direct = locatorTitle?.trim();
  if (direct != null && direct.isNotEmpty) return direct;
  final node = currentContentsNode(roots, href);
  if (node == null) return null;
  return contentsTitle(node, untitled: untitled, chapter: chapter);
}

String chapterFinishBody(
  AppLocalizations l10n, {
  required int minutes,
  String? chapterTitle,
}) {
  final title = chapterTitle?.trim();
  final named = title != null && title.isNotEmpty;
  if (minutes == 1) {
    return named
        ? l10n.chapterMinuteAlmostDoneNamed(title)
        : l10n.chapterMinuteAlmostDone;
  }
  return named
      ? l10n.chapterMinutesAlmostDoneNamed(minutes, title)
      : l10n.chapterMinutesAlmostDone(minutes);
}

/// Asks whether to stay when the chapter has only a few minutes left.
///
/// Pops true when the reader should leave. Anything else keeps it open.
class ChapterFinishDialog extends StatelessWidget {
  const ChapterFinishDialog({
    required this.minutes,
    this.chapterTitle,
    super.key,
  });

  final int minutes;
  final String? chapterTitle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.chapterFinishTitle),
      content: Text(
        chapterFinishBody(l10n, minutes: minutes, chapterTitle: chapterTitle),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n.leaveReader),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.keepReading),
        ),
      ],
    );
  }
}
