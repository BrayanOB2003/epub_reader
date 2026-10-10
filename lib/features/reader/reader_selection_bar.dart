import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class ReaderSelectionBar extends StatelessWidget {
  const ReaderSelectionBar({
    required this.onCopy,
    required this.onShare,
    required this.onSave,
    this.shareButtonKey,
    super.key,
  });

  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback onSave;
  final Key? shareButtonKey;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      color: const Color(0xF2F4F7FB),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFD5DBE3))),
        ),
        child: IconTheme(
          data: const IconThemeData(color: Color(0xFF0E1A2B)),
          child: Row(
            children: [
              Expanded(
                child: IconButton(
                  tooltip: l10n.copy,
                  onPressed: onCopy,
                  icon: const Icon(Icons.content_copy),
                ),
              ),
              Expanded(
                child: IconButton(
                  key: shareButtonKey,
                  tooltip: l10n.share,
                  onPressed: onShare,
                  icon: const Icon(Icons.share),
                ),
              ),
              Expanded(
                child: IconButton(
                  tooltip: l10n.saveQuote,
                  onPressed: onSave,
                  icon: const Icon(Icons.bookmark_add_outlined),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
