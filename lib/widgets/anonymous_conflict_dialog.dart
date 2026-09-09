import 'package:flutter/material.dart';

class AnonymousConflictDialog extends StatelessWidget {
  final int activityCount;

  const AnonymousConflictDialog({
    super.key,
    required this.activityCount,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Account already exists'),
      content: Text(
        'Your current data ($activityCount ${activityCount == 1 ? "activity" : "activities"}) '
        'will be deleted when you sign in to the existing account.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: const Text('Sign in anyway'),
        ),
      ],
    );
  }
}
