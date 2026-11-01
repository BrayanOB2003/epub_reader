import 'package:epub_reader/app/schedule_theme.dart';
import 'package:epub_reader/app/schedule_widgets.dart';
import 'package:epub_reader/features/profile/pqrs.dart';
import 'package:epub_reader/features/profile/pqrs_store.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PqrsPage extends StatefulWidget {
  const PqrsPage({this.channel, super.key});

  /// When omitted, the message is written to Firestore.
  final PqrsChannel? channel;

  @override
  State<PqrsPage> createState() => _PqrsPageState();
}

class _PqrsPageState extends State<PqrsPage> {
  final _message = TextEditingController();
  final _email = TextEditingController();
  PqrsKind? _kind;
  PqrsDraft? _held;
  PqrsCheck _check = const PqrsCheck({});
  bool _attempted = false;
  bool _sending = false;
  bool _questionsOpen = false;
  int? _openQuestion;

  @override
  void dispose() {
    _message.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = ScheduleColors.of(context);
    final questions = _questions(l10n);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScheduleDetailTitle(
              title: l10n.pqrs,
              onBack: () => context.pop(),
            ),
            Expanded(
              child: Theme(
                data: Theme.of(context).copyWith(
                  textSelectionTheme: TextSelectionThemeData(
                    cursorColor: colors.station,
                    selectionColor: colors.station.withValues(alpha: 0.24),
                    selectionHandleColor: colors.station,
                  ),
                ),
                child: ListView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                      child: Text(
                        l10n.pqrsIntro,
                        style: Theme.of(context).textTheme.bodyLarge
                            ?.copyWith(color: colors.muted),
                      ),
                    ),
                    _SectionTitle(title: l10n.pqrsWrite),
                    const ScheduleRule(),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeOut,
                      child: _held == null
                          ? _WriteForm(
                              key: const ValueKey('write'),
                              kind: _kind,
                              message: _message,
                              email: _email,
                              check: _attempted ? _check : const PqrsCheck({}),
                              sending: _sending,
                              onKind: _selectKind,
                              onChanged: _refresh,
                              onSend: _send,
                            )
                          : _HeldNote(
                              key: const ValueKey('held'),
                              draft: _held!,
                              onAnother: _writeAnother,
                            ),
                    ),
                    _QuestionsToggle(
                      title: l10n.pqrsQuestions,
                      open: _questionsOpen,
                      onTap: () => setState(() {
                        _questionsOpen = !_questionsOpen;
                        if (!_questionsOpen) _openQuestion = null;
                      }),
                    ),
                    if (_questionsOpen)
                      for (var index = 0; index < questions.length; index++)
                        _Question(
                          key: ValueKey(questions[index].$1),
                          question: questions[index].$1,
                          answer: questions[index].$2,
                          open: _openQuestion == index,
                          onTap: () => _toggle(index),
                        ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggle(int index) {
    setState(() => _openQuestion = _openQuestion == index ? null : index);
  }

  void _selectKind(PqrsKind kind) {
    setState(() {
      _kind = kind;
      if (_attempted) _check = _currentCheck();
    });
  }

  void _refresh() {
    if (!_attempted) return;
    final next = _currentCheck();
    if (next.issues.length == _check.issues.length &&
        next.issues.containsAll(_check.issues)) {
      return;
    }
    setState(() => _check = next);
  }

  PqrsCheck _currentCheck() {
    return checkPqrs(kind: _kind, message: _message.text, email: _email.text);
  }

  Future<void> _send() async {
    if (_sending) return;
    final check = _currentCheck();
    final draft = draftFrom(
      kind: _kind,
      message: _message.text,
      email: _email.text,
    );
    if (draft == null) {
      setState(() {
        _attempted = true;
        _check = check;
      });
      return;
    }
    final locale = Localizations.localeOf(context).languageCode;
    setState(() => _sending = true);
    FocusManager.instance.primaryFocus?.unfocus();
    try {
      await _channel.submit(draft, locale: locale);
      if (!mounted) return;
      setState(() {
        _sending = false;
        _held = draft;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).pqrsSendFailed)),
      );
    }
  }

  PqrsChannel get _channel => widget.channel ?? const FirestorePqrsChannel();

  void _writeAnother() {
    _message.clear();
    _email.clear();
    setState(() {
      _kind = null;
      _held = null;
      _attempted = false;
      _check = const PqrsCheck({});
    });
  }
}

List<(String, String)> _questions(AppLocalizations l10n) {
  return [
    (l10n.pqrsFaqAccount, l10n.pqrsFaqAccountAnswer),
    (l10n.pqrsFaqAdd, l10n.pqrsFaqAddAnswer),
    (l10n.pqrsFaqOffline, l10n.pqrsFaqOfflineAnswer),
    (l10n.pqrsFaqHabit, l10n.pqrsFaqHabitAnswer),
    (l10n.pqrsFaqTime, l10n.pqrsFaqTimeAnswer),
    (l10n.pqrsFaqReader, l10n.pqrsFaqReaderAnswer),
    (l10n.pqrsFaqDelete, l10n.pqrsFaqDeleteAnswer),
  ];
}

String pqrsKindLabel(AppLocalizations l10n, PqrsKind kind) {
  return switch (kind) {
    PqrsKind.petition => l10n.pqrsKindPetition,
    PqrsKind.complaint => l10n.pqrsKindComplaint,
    PqrsKind.claim => l10n.pqrsKindClaim,
    PqrsKind.suggestion => l10n.pqrsKindSuggestion,
  };
}

class _QuestionsToggle extends StatelessWidget {
  const _QuestionsToggle({
    required this.title,
    required this.open,
    required this.onTap,
  });

  final String title;
  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = ScheduleColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          expanded: open,
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.labelLarge
                            ?.copyWith(color: colors.muted),
                      ),
                    ),
                    Icon(
                      open ? Icons.expand_less : Icons.expand_more,
                      color: colors.muted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const ScheduleRule(),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
    );
  }
}

class _Question extends StatelessWidget {
  const _Question({
    required this.question,
    required this.answer,
    required this.open,
    required this.onTap,
    super.key,
  });

  final String question;
  final String answer;
  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = ScheduleColors.of(context);
    final text = Theme.of(context).textTheme;
    return ColoredBox(
      color: colors.paper,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            button: true,
            expanded: open,
            child: InkWell(
              onTap: onTap,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          question,
                          style: text.bodyLarge?.copyWith(
                            color: colors.ink,
                            fontWeight: open
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                      Icon(
                        open ? Icons.expand_less : Icons.expand_more,
                        color: colors.muted,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: open
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: Text(
                      answer,
                      style: text.bodyLarge?.copyWith(
                        color: colors.ink,
                        height: 1.5,
                      ),
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
          const ScheduleRule(),
        ],
      ),
    );
  }
}

class _WriteForm extends StatelessWidget {
  const _WriteForm({
    required this.kind,
    required this.message,
    required this.email,
    required this.check,
    required this.sending,
    required this.onKind,
    required this.onChanged,
    required this.onSend,
    super.key,
  });

  final PqrsKind? kind;
  final TextEditingController message;
  final TextEditingController email;
  final PqrsCheck check;
  final bool sending;
  final ValueChanged<PqrsKind> onKind;
  final VoidCallback onChanged;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = ScheduleColors.of(context);
    final messageError = check.has(PqrsIssue.messageEmpty)
        ? l10n.pqrsMessageRequired
        : check.has(PqrsIssue.messageTooLong)
        ? l10n.pqrsMessageTooLong
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _KindGrid(
          selected: kind,
          invalid: check.has(PqrsIssue.kind),
          label: (id) => pqrsKindLabel(l10n, id),
          onKind: onKind,
        ),
        if (check.has(PqrsIssue.kind))
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: _KindIssue(),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Text(
            l10n.pqrsMessage,
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(color: colors.muted),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: _LogField(
            controller: message,
            hint: l10n.pqrsMessageHint,
            error: messageError,
            minLines: 4,
            maxLines: 8,
            textCapitalization: TextCapitalization.sentences,
            onChanged: onChanged,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: ListenableBuilder(
            listenable: message,
            builder: (context, _) {
              final count = message.text.characters.length;
              final over = count > pqrsMessageLimit;
              return Text(
                l10n.pqrsMessageCount(count, pqrsMessageLimit),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: over ? colors.ink : colors.muted,
                  fontWeight: over ? FontWeight.w600 : FontWeight.w400,
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Text(
            l10n.pqrsEmail,
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(color: colors.muted),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: _LogField(
            controller: email,
            hint: l10n.pqrsEmailHint,
            error: check.has(PqrsIssue.email) ? l10n.pqrsEmailInvalid : null,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            onChanged: onChanged,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: ScheduleAction(
            label: sending ? l10n.pqrsSending : l10n.pqrsSend,
            onPressed: sending ? null : onSend,
          ),
        ),
      ],
    );
  }
}

class _KindIssue extends StatelessWidget {
  const _KindIssue();

  @override
  Widget build(BuildContext context) {
    return ScheduleIssue(
      message: AppLocalizations.of(context).pqrsKindRequired,
    );
  }
}

class _KindGrid extends StatelessWidget {
  const _KindGrid({
    required this.selected,
    required this.invalid,
    required this.label,
    required this.onKind,
  });

  final PqrsKind? selected;
  final bool invalid;
  final String Function(PqrsKind id) label;
  final ValueChanged<PqrsKind> onKind;

  @override
  Widget build(BuildContext context) {
    final colors = ScheduleColors.of(context);
    final radius = scheduleRadius(context);
    final border = invalid ? colors.ink : colors.rule;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(color: border),
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Column(
            children: [
              _KindRow(
                left: PqrsKind.petition,
                right: PqrsKind.complaint,
                selected: selected,
                label: label,
                onKind: onKind,
              ),
              ColoredBox(
                color: colors.rule,
                child: const SizedBox(height: 1, width: double.infinity),
              ),
              _KindRow(
                left: PqrsKind.claim,
                right: PqrsKind.suggestion,
                selected: selected,
                label: label,
                onKind: onKind,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KindRow extends StatelessWidget {
  const _KindRow({
    required this.left,
    required this.right,
    required this.selected,
    required this.label,
    required this.onKind,
  });

  final PqrsKind left;
  final PqrsKind right;
  final PqrsKind? selected;
  final String Function(PqrsKind id) label;
  final ValueChanged<PqrsKind> onKind;

  @override
  Widget build(BuildContext context) {
    final rule = ScheduleColors.of(context).rule;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _KindCell(
              label: label(left),
              selected: left == selected,
              onTap: () => onKind(left),
            ),
          ),
          ColoredBox(color: rule, child: const SizedBox(width: 1)),
          Expanded(
            child: _KindCell(
              label: label(right),
              selected: right == selected,
              onTap: () => onKind(right),
            ),
          ),
        ],
      ),
    );
  }
}

class _KindCell extends StatelessWidget {
  const _KindCell({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = ScheduleColors.of(context);
    final ink = selected ? typeOnStation(context) : colors.ink;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? colors.station : colors.paper,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Center(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(color: ink),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LogField extends StatelessWidget {
  const _LogField({
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.error,
    this.minLines = 1,
    this.maxLines = 1,
    this.keyboardType,
    this.autofillHints,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController controller;
  final String hint;
  final String? error;
  final int minLines;
  final int maxLines;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final TextCapitalization textCapitalization;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = ScheduleColors.of(context);
    final text = Theme.of(context).textTheme;
    final borderColor = error == null ? colors.rule : colors.ink;
    OutlineInputBorder border(Color color) {
      return OutlineInputBorder(
        borderRadius: scheduleRadius(context),
        borderSide: BorderSide(color: color),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          minLines: minLines,
          maxLines: maxLines,
          keyboardType: keyboardType,
          autofillHints: autofillHints,
          textCapitalization: textCapitalization,
          cursorColor: colors.station,
          style: text.bodyLarge?.copyWith(color: colors.ink),
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: text.bodyLarge?.copyWith(color: colors.muted),
            filled: true,
            fillColor: colors.paper,
            contentPadding: const EdgeInsets.all(16),
            border: border(borderColor),
            enabledBorder: border(borderColor),
            focusedBorder: border(colors.station),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 8),
          ScheduleIssue(message: error!),
        ],
      ],
    );
  }
}

class _HeldNote extends StatelessWidget {
  const _HeldNote({required this.draft, required this.onAnother, super.key});

  final PqrsDraft draft;
  final VoidCallback onAnother;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = ScheduleColors.of(context);
    final text = Theme.of(context).textTheme;
    final kind = pqrsKindLabel(l10n, draft.kind).toLowerCase();
    final email = draft.email;
    return ColoredBox(
      color: colors.station,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.pqrsHeldTitle,
              style: text.headlineSmall?.copyWith(
                color: typeOnStation(context),
                height: 1.05,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.pqrsHeldBody(kind),
              style: text.bodyLarge?.copyWith(
                color: colors.onStationMuted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              draft.message,
              style: text.bodyLarge?.copyWith(
                color: typeOnStation(context),
                height: 1.5,
              ),
            ),
            if (email != null) ...[
              const SizedBox(height: 8),
              Text(
                email,
                style: text.bodyMedium?.copyWith(color: colors.onStationMuted),
              ),
            ],
            const SizedBox(height: 8),
            TextButton(
              onPressed: onAnother,
              style: TextButton.styleFrom(
                foregroundColor: typeOnStation(context),
                minimumSize: const Size(48, 48),
                padding: const EdgeInsets.symmetric(horizontal: 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(l10n.pqrsAnother),
            ),
          ],
        ),
      ),
    );
  }
}
