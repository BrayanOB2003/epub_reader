import 'package:epub_reader/app/schedule_theme.dart';
import 'package:epub_reader/app/schedule_widgets.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The one payment. The profile only lists it; this page carries the
/// three sections and the price.
class PremiumPage extends StatefulWidget {
  const PremiumPage({super.key});

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  String? _issue;

  void _buy() {
    final message = AppLocalizations.of(context).premiumPurchaseUnavailable;
    if (_issue == message) return;
    setState(() => _issue = message);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = ScheduleColors.of(context);
    final issue = _issue;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          children: [
            ScheduleDetailTitle(
              title: l10n.premiumTitle,
              onBack: () => context.pop(),
            ),
            ColoredBox(
              color: colors.station,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Text(
                  l10n.premiumLead,
                  style: programTitle(
                    context,
                    typeOnStation(context),
                    size: 28,
                  ),
                ),
              ),
            ),
            _Feature(title: l10n.monthReading, body: l10n.premiumMonthBody),
            const ScheduleRule(),
            _Feature(title: l10n.readingByBook, body: l10n.premiumBooksBody),
            const ScheduleRule(),
            _Feature(title: l10n.appearance, body: l10n.premiumAppearanceBody),
            const ScheduleRule(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (issue != null) ...[
                    ScheduleIssue(message: issue),
                    const SizedBox(height: 12),
                  ],
                  ScheduleAction(label: l10n.premiumUnlock, onPressed: _buy),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colors = ScheduleColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: colors.muted),
          ),
        ],
      ),
    );
  }
}
