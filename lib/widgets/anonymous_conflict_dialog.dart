import 'package:flutter/material.dart';
import 'package:tick/l10n/app_localizations.dart';

class AnonymousConflictDialog extends StatelessWidget {
  final int activityCount;

  const AnonymousConflictDialog({
    super.key,
    required this.activityCount,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context)!;
    return AlertDialog(
      title: Text(l10n.accountConflictTitle),
      content: Text(l10n.accountConflictMessage(activityCount)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          child: Text(l10n.signInAnyway),
        ),
      ],
    );
  }
}
