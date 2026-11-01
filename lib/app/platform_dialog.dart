import 'package:epub_reader/app/schedule_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A confirm step on the platform's own alert. [destructive] uses the
/// platform's destructive action so it does not look like cancel.
Future<bool> showPlatformConfirm(
  BuildContext context, {
  required String title,
  required String message,
  required String confirm,
  required String cancel,
  bool destructive = false,
}) async {
  final ios = Theme.of(context).platform == TargetPlatform.iOS;
  if (ios) {
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(message),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: destructive,
            isDefaultAction: !destructive,
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirm),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  final colors = ScheduleColors.of(context);
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(
            foregroundColor: destructive
                ? Theme.of(context).colorScheme.error
                : colors.station,
          ),
          child: Text(confirm),
        ),
      ],
    ),
  );
  return result ?? false;
}
