import 'dart:io';

import 'package:epub_reader/app/providers.dart';
import 'package:epub_reader/app/schedule_theme.dart';
import 'package:epub_reader/app/schedule_widgets.dart';
import 'package:epub_reader/features/library/data/book_repository.dart';
import 'package:epub_reader/features/quotes/quote_background_store.dart';
import 'package:epub_reader/features/quotes/quote_card_layout.dart';
import 'package:epub_reader/features/quotes/quote_card_model.dart';
import 'package:epub_reader/features/quotes/quote_card_render.dart';
import 'package:epub_reader/features/quotes/quote_card_view.dart';
import 'package:epub_reader/features/quotes/quote_contrast.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class QuoteExportPage extends ConsumerStatefulWidget {
  const QuoteExportPage({required this.quoteId, super.key});

  final int quoteId;

  @override
  ConsumerState<QuoteExportPage> createState() => _QuoteExportPageState();
}

class _QuoteExportPageState extends ConsumerState<QuoteExportPage> {
  QuoteCardStyle _style = QuoteCardStyle.initial;
  List<StoredQuoteBackground> _imported = const [];
  String _backgroundId = bundledQuoteBackgroundIds.first;
  bool _importedBackground = false;
  QuoteBackgroundSample? _sample;
  bool _sampleError = false;
  bool _suggestionReady = false;
  bool _ready = false;
  bool _busy = false;
  bool _importing = false;
  int _sampleToken = 0;
  ImageProvider? _preview;
  String? _previewKey;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final style = await ref.read(quoteCardStyleStoreProvider).read();
    final imported = await ref.read(quoteBackgroundStoreProvider).list();
    if (!mounted) return;
    setState(() {
      _style = style;
      _imported = imported;
      _ready = true;
      _suggestionReady = !style.inkAutomatic;
    });
    await _selectBackground(
      bundledQuoteBackgroundIds.first,
      imported: false,
      suggest: style.inkAutomatic,
    );
  }

  Future<void> _selectBackground(
    String id, {
    required bool imported,
    required bool suggest,
  }) async {
    final token = ++_sampleToken;
    setState(() {
      _backgroundId = id;
      _importedBackground = imported;
      _sampleError = false;
      if (suggest) {
        _style = _style.copyWith(inkAutomatic: true);
        _suggestionReady = false;
      }
    });
    try {
      final bytes = await ref
          .read(quoteBackgroundStoreProvider)
          .load(id: id, imported: imported);
      final sample = await sampleQuoteBackground(bytes);
      if (!mounted || token != _sampleToken) return;
      setState(() {
        _sample = sample;
        _sampleError = false;
      });
      if (_style.inkAutomatic) _applySuggestion(raiseVeil: true);
      _persist();
    } catch (_) {
      if (!mounted || token != _sampleToken) return;
      setState(() {
        _sample = null;
        _sampleError = true;
        _suggestionReady = !_style.inkAutomatic;
      });
    }
  }

  void _applySuggestion({required bool raiseVeil}) {
    final sample = _sample;
    if (sample == null || !mounted) return;
    final pick = raiseVeil
        ? suggestQuoteInk(
            sample: sample,
            cardAspect: _aspect(),
            veil: _style.veil,
          )
        : bestQuoteInk(
            sample: sample,
            cardAspect: _aspect(),
            veil: _style.veil,
          );
    setState(() {
      _style = _style.copyWith(
        inkId: pick.inkId,
        veil: pick.veil,
        inkAutomatic: true,
      );
      _suggestionReady = true;
    });
  }

  double _aspect() {
    return quoteCardAspect(
      _style.format,
      MediaQuery.sizeOf(context).aspectRatio,
    );
  }

  void _persist() {
    ref.read(quoteCardStyleStoreProvider).write(_style);
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _import() async {
    final l10n = AppLocalizations.of(context);
    final picked = await FilePicker.pickFile(
      type: FileType.image,
      dialogTitle: l10n.importQuoteBackground,
    );
    if (picked == null || !mounted) return;
    setState(() => _importing = true);
    try {
      final bytes = await picked.readAsBytes();
      if (bytes.length > quoteBackgroundMaxBytes) {
        _showMessage(l10n.quoteImageTooLarge);
        return;
      }
      final stored = await ref
          .read(quoteBackgroundStoreProvider)
          .importBytes(bytes);
      if (!mounted) return;
      setState(() {
        _imported = [
          stored,
          for (final item in _imported)
            if (item.id != stored.id) item,
        ];
      });
      await _selectBackground(stored.id, imported: true, suggest: true);
    } on QuoteBackgroundException catch (error) {
      _showMessage(
        error.tooLarge ? l10n.quoteImageTooLarge : l10n.quoteImageImportFailed,
      );
    } catch (_) {
      _showMessage(l10n.quoteImageImportFailed);
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  Future<void> _removeImported() async {
    if (!_importedBackground) return;
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.removeQuoteBackground),
        content: Text(l10n.removeQuoteBackgroundBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final id = _backgroundId;
    await ref.read(quoteBackgroundStoreProvider).delete(id);
    if (!mounted) return;
    setState(() {
      _imported = [
        for (final item in _imported)
          if (item.id != id) item,
      ];
    });
    await _selectBackground(
      bundledQuoteBackgroundIds.first,
      imported: false,
      suggest: true,
    );
  }

  Future<void> _share(ReadingQuote quote, String attribution) {
    return _export(quote, attribution, save: false);
  }

  Future<void> _save(ReadingQuote quote, String attribution) {
    return _export(quote, attribution, save: true);
  }

  Future<void> _export(
    ReadingQuote quote,
    String attribution, {
    required bool save,
  }) async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final bytes = await ref
          .read(quoteBackgroundStoreProvider)
          .load(id: _backgroundId, imported: _importedBackground);
      final png = await renderQuoteCard(
        background: bytes,
        style: _style,
        aspect: _aspect(),
        passage: quote.text,
        attribution: attribution,
      );
      final file = await ref.read(quoteImageExportProvider).writePng(png);
      if (!mounted) return;
      if (save) {
        await ref.read(quoteImageExportProvider).saveToPhotos(file.path);
        _showMessage(l10n.quoteImageSaved);
      } else {
        final box = context.findRenderObject() as RenderBox?;
        final origin = box == null
            ? null
            : box.localToGlobal(Offset.zero) & box.size;
        await ref
            .read(quoteImageExportProvider)
            .share(file.path, origin: origin);
      }
    } catch (_) {
      _showMessage(
        save ? l10n.quoteImageSaveFailed : l10n.quoteImageShareFailed,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  ImageProvider _backgroundImage(double cacheWidth) {
    final key = '$_importedBackground:$_backgroundId:${cacheWidth.round()}';
    final current = _preview;
    if (_previewKey == key && current != null) return current;
    final ImageProvider source;
    if (_importedBackground) {
      final path = _imported
          .where((item) => item.id == _backgroundId)
          .map((item) => item.path)
          .firstOrNull;
      source = path == null
          ? AssetImage('assets/backgrounds/${bundledQuoteBackgroundIds.first}')
          : FileImage(File(path));
    } else {
      source = AssetImage('assets/backgrounds/$_backgroundId');
    }
    final provider = ResizeImage(source, width: cacheWidth.round());
    _preview = provider;
    _previewKey = key;
    return provider;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final quotes = ref.watch(savedQuotesProvider);
    return Scaffold(
      body: SafeArea(
        child: quotes.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                l10n.quotesLoadFailed('$error'),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          data: (items) {
            ReadingQuote? quote;
            for (final item in items) {
              if (item.id == widget.quoteId) quote = item;
            }
            if (quote == null) {
              return _MissingQuote(message: l10n.quoteImageMissing);
            }
            if (!_ready) {
              return const Center(child: CircularProgressIndicator());
            }
            return _Editor(
              quote: quote,
              style: _style,
              imported: _imported,
              backgroundId: _backgroundId,
              importedBackground: _importedBackground,
              sampleError: _sampleError,
              showCopy: _suggestionReady || !_style.inkAutomatic,
              busy: _busy,
              importing: _importing,
              backgroundOf: _backgroundImage,
              onBack: () => context.pop(),
              onImport: _import,
              onSelectBundled: (id) =>
                  _selectBackground(id, imported: false, suggest: true),
              onSelectImported: (id) =>
                  _selectBackground(id, imported: true, suggest: true),
              onRemove: _removeImported,
              onFormat: (format) {
                if (format == _style.format) return;
                setState(() {
                  _style = _style.copyWith(format: format, inkAutomatic: true);
                  _suggestionReady = _sample != null;
                });
                _applySuggestion(raiseVeil: true);
                _persist();
              },
              onFont: (font) {
                if (font == _style.font) return;
                setState(() => _style = _style.copyWith(font: font));
                _persist();
              },
              onInk: (id) {
                setState(() {
                  _style = _style.copyWith(inkId: id, inkAutomatic: false);
                  _suggestionReady = true;
                });
                _persist();
              },
              onScale: (scale, persist) {
                setState(() => _style = _style.copyWith(textScale: scale));
                if (persist) _persist();
              },
              onVeil: (veil, persist) {
                final sample = _sample;
                var style = _style.copyWith(veil: veil);
                if (style.inkAutomatic && sample != null) {
                  final pick = bestQuoteInk(
                    sample: sample,
                    cardAspect: _aspect(),
                    veil: veil,
                  );
                  style = style.copyWith(inkId: pick.inkId);
                }
                setState(() => _style = style);
                if (persist) _persist();
              },
              onShare: () => _share(
                quote!,
                quoteAttribution(
                  title: quote.bookTitle,
                  author: quote.author,
                  untitled: l10n.untitled,
                ),
              ),
              onSave: () => _save(
                quote!,
                quoteAttribution(
                  title: quote.bookTitle,
                  author: quote.author,
                  untitled: l10n.untitled,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MissingQuote extends StatelessWidget {
  const _MissingQuote({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          tooltip: AppLocalizations.of(context).back,
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Text(message, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ],
    );
  }
}

class _Editor extends StatelessWidget {
  const _Editor({
    required this.quote,
    required this.style,
    required this.imported,
    required this.backgroundId,
    required this.importedBackground,
    required this.sampleError,
    required this.showCopy,
    required this.busy,
    required this.importing,
    required this.backgroundOf,
    required this.onBack,
    required this.onImport,
    required this.onSelectBundled,
    required this.onSelectImported,
    required this.onRemove,
    required this.onFormat,
    required this.onFont,
    required this.onInk,
    required this.onScale,
    required this.onVeil,
    required this.onShare,
    required this.onSave,
  });

  final ReadingQuote quote;
  final QuoteCardStyle style;
  final List<StoredQuoteBackground> imported;
  final String backgroundId;
  final bool importedBackground;
  final bool sampleError;
  final bool showCopy;
  final bool busy;
  final bool importing;
  final ImageProvider Function(double cacheWidth) backgroundOf;
  final VoidCallback onBack;
  final VoidCallback onImport;
  final ValueChanged<String> onSelectBundled;
  final ValueChanged<String> onSelectImported;
  final VoidCallback onRemove;
  final ValueChanged<QuoteCardFormat> onFormat;
  final ValueChanged<QuoteCardFont> onFont;
  final ValueChanged<String> onInk;
  final void Function(double scale, bool persist) onScale;
  final void Function(double veil, bool persist) onVeil;
  final VoidCallback onShare;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = ScheduleColors.of(context);
    final aspect = quoteCardAspect(
      style.format,
      MediaQuery.sizeOf(context).aspectRatio,
    );
    final pixels = quoteExportPixels(aspect);
    final attribution = quoteAttribution(
      title: quote.bookTitle,
      author: quote.author,
      untitled: l10n.untitled,
    );
    final measure = measureQuoteCard(
      passage: quote.text,
      attribution: attribution,
      cardWidth: pixels.$1.toDouble(),
      cardHeight: pixels.$2.toDouble(),
      font: style.font,
      textScale: style.textScale,
      color: Color(0xFF000000 | style.ink.rgb),
    );
    final enabled =
        measure.fits && !busy && !sampleError && showCopy && !importing;
    final notice = sampleError
        ? l10n.quoteBackgroundFailed
        : measure.fits
        ? null
        : l10n.quoteImageTooLong;
    final screen = MediaQuery.sizeOf(context);
    final previewHeight = (screen.height * 0.36).clamp(180.0, 420.0);
    final previewWidth = screen.width - 40;
    return Column(
      children: [
        SizedBox(
          height: 48,
          child: Row(
            children: [
              IconButton(
                tooltip: l10n.back,
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back),
              ),
              Expanded(
                child: Text(
                  l10n.quoteImageTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: colors.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: previewHeight,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Center(
              child: _PreviewFrame(
                aspect: aspect,
                maxWidth: previewWidth,
                maxHeight: previewHeight - 12,
                child: QuoteCardView(
                  background: backgroundOf(previewWidth),
                  style: style,
                  passage: showCopy ? quote.text : '',
                  attribution: showCopy ? attribution : '',
                  measure: measure,
                  exportWidth: pixels.$1.toDouble(),
                ),
              ),
            ),
          ),
        ),
        const ScheduleRule(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            children: [
              _BackgroundStrip(
                imported: imported,
                backgroundId: backgroundId,
                importedBackground: importedBackground,
                importing: importing,
                onImport: onImport,
                onSelectBundled: onSelectBundled,
                onSelectImported: onSelectImported,
              ),
              if (importedBackground)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: onRemove,
                    child: Text(l10n.removeImportedBackground),
                  ),
                ),
              const SizedBox(height: 8),
              _ChoiceRow(
                labels: [
                  l10n.quoteFormatStory,
                  l10n.quoteFormatPost,
                  l10n.quoteFormatSquare,
                  l10n.quoteFormatScreen,
                ],
                selected: style.format.index,
                onSelected: (index) => onFormat(QuoteCardFormat.values[index]),
              ),
              const SizedBox(height: 8),
              _ChoiceRow(
                labels: [
                  l10n.quoteFontSerif,
                  l10n.quoteFontCondensed,
                  l10n.quoteFontPlain,
                ],
                families: [quoteSerifFace, programFace, null],
                selected: style.font.index,
                onSelected: (index) => onFont(QuoteCardFont.values[index]),
              ),
              const SizedBox(height: 8),
              _InkRow(selectedId: style.inkId, onSelected: onInk),
              _SliderRow(
                label: l10n.quoteTextSize,
                value: style.textScale,
                min: quoteTextScaleMin,
                max: quoteTextScaleMax,
                onChanged: (value) => onScale(value, false),
                onChangeEnd: (value) => onScale(value, true),
              ),
              _SliderRow(
                label: l10n.quoteVeil,
                value: style.veil,
                min: 0,
                max: quoteVeilMax,
                onChanged: (value) => onVeil(value, false),
                onChangeEnd: (value) => onVeil(value, true),
              ),
              if (notice != null) ...[
                const SizedBox(height: 8),
                Text(
                  notice,
                  style: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(color: colors.ink),
                ),
              ],
              const SizedBox(height: 16),
              if (busy) ...[
                const LinearProgressIndicator(),
                const SizedBox(height: 12),
              ],
              ScheduleAction(
                label: l10n.share,
                onPressed: enabled ? onShare : null,
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: 48,
                width: double.infinity,
                child: TextButton(
                  onPressed: enabled ? onSave : null,
                  child: Text(l10n.saveToPhotos),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PreviewFrame extends StatelessWidget {
  const _PreviewFrame({
    required this.aspect,
    required this.maxWidth,
    required this.maxHeight,
    required this.child,
  });

  final double aspect;
  final double maxWidth;
  final double maxHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    var width = maxWidth;
    var height = width / aspect;
    if (height > maxHeight) {
      height = maxHeight;
      width = height * aspect;
    }
    return SizedBox(width: width, height: height, child: child);
  }
}

class _BackgroundStrip extends StatelessWidget {
  const _BackgroundStrip({
    required this.imported,
    required this.backgroundId,
    required this.importedBackground,
    required this.importing,
    required this.onImport,
    required this.onSelectBundled,
    required this.onSelectImported,
  });

  final List<StoredQuoteBackground> imported;
  final String backgroundId;
  final bool importedBackground;
  final bool importing;
  final VoidCallback onImport;
  final ValueChanged<String> onSelectBundled;
  final ValueChanged<String> onSelectImported;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final count = 1 + bundledQuoteBackgroundIds.length + imported.length;
    return SizedBox(
      height: 64,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemExtent: 72,
        itemCount: count,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _Thumb(
              label: l10n.importQuoteBackground,
              selected: false,
              onTap: importing ? null : onImport,
              child: importing
                  ? const Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : const Icon(Icons.add),
            );
          }
          final bundledIndex = index - 1;
          if (bundledIndex < bundledQuoteBackgroundIds.length) {
            final id = bundledQuoteBackgroundIds[bundledIndex];
            return _Thumb(
              label: l10n.quoteImageTitle,
              selected: !importedBackground && backgroundId == id,
              onTap: () => onSelectBundled(id),
              child: Image(
                image: ResizeImage(
                  AssetImage('assets/backgrounds/$id'),
                  width: 128,
                ),
                fit: BoxFit.cover,
                gaplessPlayback: true,
                excludeFromSemantics: true,
              ),
            );
          }
          final item =
              imported[bundledIndex - bundledQuoteBackgroundIds.length];
          return _Thumb(
            key: ValueKey(item.id),
            label: l10n.importQuoteBackground,
            selected: importedBackground && backgroundId == item.id,
            onTap: () => onSelectImported(item.id),
            child: Image(
              image: ResizeImage(FileImage(File(item.path)), width: 128),
              fit: BoxFit.cover,
              gaplessPlayback: true,
              excludeFromSemantics: true,
            ),
          );
        },
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.child,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = ScheduleColors.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 64,
            height: 64,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  color: selected ? colors.station : colors.rule,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: ClipRect(child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.labels,
    required this.selected,
    required this.onSelected,
    this.families,
  });

  final List<String> labels;
  final List<String?>? families;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < labels.length; index++)
          Expanded(
            child: _Choice(
              label: labels[index],
              fontFamily: families == null ? null : families![index],
              selected: selected == index,
              onTap: () => onSelected(index),
            ),
          ),
      ],
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.selected,
    required this.onTap,
    this.fontFamily,
  });

  final String label;
  final String? fontFamily;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = ScheduleColors.of(context);
    final background = selected ? colors.station : Colors.transparent;
    final foreground = selected ? colors.onStation : colors.ink;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: ColoredBox(
            color: background,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Center(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: foreground,
                    fontFamily: fontFamily,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InkRow extends StatelessWidget {
  const _InkRow({required this.selectedId, required this.onSelected});

  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        for (final ink in quoteInks)
          Expanded(
            child: _InkDot(
              ink: ink,
              label: _inkLabel(l10n, ink.id),
              selected: selectedId == ink.id,
              onTap: () => onSelected(ink.id),
            ),
          ),
      ],
    );
  }
}

class _InkDot extends StatelessWidget {
  const _InkDot({
    required this.ink,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final QuoteInk ink;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = ScheduleColors.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 48,
          child: Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFF000000 | ink.rgb),
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? colors.station : colors.rule,
                  width: selected ? 3 : 1,
                ),
              ),
              child: const SizedBox(width: 28, height: 28),
            ),
          ),
        ),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.onChangeEnd,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  @override
  Widget build(BuildContext context) {
    final colors = ScheduleColors.of(context);
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(color: colors.ink),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: colors.station,
              thumbColor: colors.station,
              inactiveTrackColor: colors.rule,
              overlayColor: colors.station.withValues(alpha: 0.12),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              label: label,
              onChanged: onChanged,
              onChangeEnd: onChangeEnd,
            ),
          ),
        ),
      ],
    );
  }
}

String _inkLabel(AppLocalizations l10n, String id) {
  return switch (id) {
    'paper' => l10n.quoteInkPaper,
    'white' => l10n.quoteInkWhite,
    'cream' => l10n.quoteInkCream,
    'black' => l10n.quoteInkBlack,
    'station' => l10n.quoteInkStation,
    _ => l10n.quoteInkInk,
  };
}
