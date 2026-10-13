import 'package:epub_reader/app/schedule_theme.dart';
import 'package:epub_reader/features/reader/contents.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_readium/flutter_readium.dart';

/// The book index, kept inside the reader's dialog.
///
/// The row for [currentHref] is the one on air. The dialog stays open until
/// [onOpen] reports that the chapter actually opened.
class ContentsDialog extends StatefulWidget {
  const ContentsDialog({
    required this.roots,
    required this.onOpen,
    this.currentHref,
    super.key,
  });

  final List<ContentsNode> roots;
  final String? currentHref;
  final Future<bool> Function(Link link) onOpen;

  @override
  State<ContentsDialog> createState() => _ContentsDialogState();
}

class _ContentsDialogState extends State<ContentsDialog> {
  final _currentKey = GlobalKey();
  late final ScrollController _scroll;
  late final TextEditingController _search;
  late final Set<int> _expanded;
  late final ContentsNode? _current;

  var _query = '';
  var _revealTries = 0;
  var _revealed = false;
  int? _jumping;
  ContentsNode? _failed;
  String? _failedTitle;

  @override
  void initState() {
    super.initState();
    _current = currentContentsNode(widget.roots, widget.currentHref);
    _expanded = expandedContents(widget.roots, _current);
    final rows = visibleContents(
      roots: widget.roots,
      expanded: _expanded,
      query: '',
      titleOf: (node) => node.link.title ?? '',
    );
    _scroll = ScrollController(
      initialScrollOffset: contentsScrollOffset(rows, _current?.position),
    );
    _search = TextEditingController();
    if (_current != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _revealCurrent());
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  String _titleOf(AppLocalizations l10n, ContentsNode node) {
    return contentsTitle(
      node,
      untitled: l10n.untitled,
      chapter: l10n.chapterLabel,
    );
  }

  void _onQuery(String value) {
    if (value == _query) return;
    setState(() => _query = value);
  }

  void _toggle(ContentsNode node) {
    setState(() {
      if (_expanded.contains(node.position)) {
        _expanded.remove(node.position);
      } else {
        _expanded.add(node.position);
      }
    });
  }

  Future<void> _open(ContentsNode node) async {
    if (_jumping != null) return;
    final l10n = AppLocalizations.of(context);
    final title = _titleOf(l10n, node);
    setState(() {
      _jumping = node.position;
      _failed = null;
      _failedTitle = null;
    });
    var opened = false;
    try {
      opened = await widget.onOpen(node.link);
    } catch (_) {
      opened = false;
    }
    if (!mounted) return;
    if (opened) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      _jumping = null;
      _failed = node;
      _failedTitle = title;
    });
  }

  Future<void> _retry() async {
    final node = _failed;
    if (node == null) return;
    await _open(node);
  }

  void _revealCurrent() {
    if (!mounted || _revealed) return;
    final target = _currentKey.currentContext;
    if (target != null) {
      _revealed = true;
      final reduceMotion = MediaQuery.disableAnimationsOf(context);
      Scrollable.ensureVisible(
        target,
        alignment: 0.15,
        duration: reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
      return;
    }
    if (_revealTries++ > 3 || !_scroll.hasClients) return;
    final rows = visibleContents(
      roots: widget.roots,
      expanded: _expanded,
      query: _query,
      titleOf: (node) => node.link.title ?? '',
    );
    final offset = contentsScrollOffset(rows, _current?.position);
    final max = _scroll.position.maxScrollExtent;
    _scroll.jumpTo(offset.clamp(0.0, max));
    WidgetsBinding.instance.addPostFrameCallback((_) => _revealCurrent());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = ScheduleColors.of(context);
    final rows = visibleContents(
      roots: widget.roots,
      expanded: _expanded,
      query: _query,
      titleOf: (node) => _titleOf(l10n, node),
    );
    final height = widget.roots.isEmpty
        ? null
        : MediaQuery.sizeOf(context).height * 0.6;

    return AlertDialog(
      title: Text(l10n.contents),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
      content: SizedBox(
        width: double.maxFinite,
        height: height,
        child: widget.roots.isEmpty
            ? _EmptyContents(colors: colors, l10n: l10n)
            : Column(
                children: [
                  if (contentsShowsSearch(widget.roots))
                    _ContentsSearch(
                      controller: _search,
                      colors: colors,
                      hint: l10n.contentsSearch,
                      onChanged: _onQuery,
                    ),
                  if (_failedTitle != null)
                    _ContentsFailure(
                      message: l10n.chapterOpenFailed(_failedTitle!),
                      retry: l10n.retry,
                      colors: colors,
                      onRetry: _jumping == null ? _retry : null,
                    ),
                  Expanded(
                    child: rows.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                            child: Text(
                              l10n.contentsNoMatches,
                              style: TextStyle(
                                color: colors.muted,
                                fontSize: 16,
                                height: 1.4,
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: _scroll,
                            padding: EdgeInsets.zero,
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            itemCount: rows.length,
                            itemBuilder: (context, index) {
                              final node = rows[index];
                              final current =
                                  node.position == _current?.position;
                              return _ContentsRow(
                                key: current
                                    ? _currentKey
                                    : ValueKey(node.position),
                                node: node,
                                title: _titleOf(l10n, node),
                                current: current,
                                jumping: _jumping == node.position,
                                enabled: _jumping == null,
                                searching: _query.trim().isNotEmpty,
                                expanded: _expanded.contains(node.position),
                                colors: colors,
                                showChapters: l10n.showChapters,
                                hideChapters: l10n.hideChapters,
                                onOpen: () => _open(node),
                                onToggle: () => _toggle(node),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.back),
        ),
      ],
    );
  }
}

class _EmptyContents extends StatelessWidget {
  const _EmptyContents({required this.colors, required this.l10n});

  final ScheduleColors colors;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.noContents,
            style: TextStyle(color: colors.ink, fontSize: 16, height: 1.4),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.contentsKeepReading,
            style: TextStyle(color: colors.muted, fontSize: 16, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _ContentsSearch extends StatelessWidget {
  const _ContentsSearch({
    required this.controller,
    required this.colors,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ScheduleColors colors;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final rule = BorderSide(color: colors.rule);
    return TextField(
      controller: controller,
      cursorColor: colors.station,
      style: TextStyle(color: colors.ink, fontSize: 16, height: 1.4),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: colors.muted, fontSize: 16),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        border: UnderlineInputBorder(borderSide: rule),
        enabledBorder: UnderlineInputBorder(borderSide: rule),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: colors.station),
        ),
      ),
      onChanged: onChanged,
    );
  }
}

class _ContentsFailure extends StatelessWidget {
  const _ContentsFailure({
    required this.message,
    required this.retry,
    required this.colors,
    required this.onRetry,
  });

  final String message;
  final String retry;
  final ScheduleColors colors;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            liveRegion: true,
            child: Text(
              message,
              style: TextStyle(color: colors.ink, fontSize: 16, height: 1.4),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              minimumSize: const Size(48, 48),
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.zero,
            ),
            onPressed: onRetry,
            child: Text(retry),
          ),
        ],
      ),
    );
  }
}

class _ContentsRow extends StatelessWidget {
  const _ContentsRow({
    required this.node,
    required this.title,
    required this.current,
    required this.jumping,
    required this.enabled,
    required this.searching,
    required this.expanded,
    required this.colors,
    required this.showChapters,
    required this.hideChapters,
    required this.onOpen,
    required this.onToggle,
    super.key,
  });

  final ContentsNode node;
  final String title;
  final bool current;
  final bool jumping;
  final bool enabled;
  final bool searching;
  final bool expanded;
  final ScheduleColors colors;
  final String showChapters;
  final String hideChapters;
  final VoidCallback onOpen;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final part = node.hasChildren;
    final ink = current ? colors.onStation : colors.ink;
    final depth = node.depth < 0 ? 0 : (node.depth > 3 ? 3 : node.depth);
    final indent = 20.0 + depth * 16;
    return Material(
      color: current ? colors.station : Colors.transparent,
      child: part ? _part(indent: indent) : _chapter(ink: ink, indent: indent),
    );
  }

  Widget _part({required double indent}) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: Padding(
        padding: EdgeInsets.only(left: indent, top: 12, bottom: 4),
        child: Row(
          children: [
            Expanded(
              child: Semantics(
                button: true,
                selected: current,
                child: InkWell(
                  onTap: enabled ? onOpen : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: programFace,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        height: 1.15,
                        letterSpacing: -0.36,
                        color: current ? colors.onStation : colors.muted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (searching)
              const SizedBox(width: 20)
            else if (jumping)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: _wait(current ? colors.onStation : colors.station),
              )
            else
              IconButton(
                tooltip: expanded ? hideChapters : showChapters,
                onPressed: enabled ? onToggle : null,
                icon: Icon(
                  expanded ? Icons.expand_less : Icons.expand_more,
                  color: current ? colors.onStation : colors.muted,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _chapter({required Color ink, required double indent}) {
    return Semantics(
      button: true,
      selected: current,
      child: InkWell(
        onTap: enabled ? onOpen : null,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: EdgeInsets.fromLTRB(indent, 8, 16, 8),
          decoration: BoxDecoration(
            border: current
                ? null
                : Border(bottom: BorderSide(color: colors.rule)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: ink,
                    fontSize: 16,
                    height: 1.4,
                    fontWeight: current ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              if (jumping) _wait(current ? colors.onStation : colors.station),
            ],
          ),
        ),
      ),
    );
  }

  Widget _wait(Color color) {
    return SizedBox(
      width: 16,
      height: 16,
      child: CircularProgressIndicator(strokeWidth: 2, color: color),
    );
  }
}
