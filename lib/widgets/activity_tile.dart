import 'package:flutter/material.dart';
import 'package:tick/l10n/app_localizations.dart';
import '../core/extensions.dart';
import '../models/activity.dart';

class ActivityTile extends StatelessWidget {
  final Activity activity;
  final ({double time, double count}) todayTotal;
  final int childCount;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const ActivityTile({
    super.key,
    required this.activity,
    required this.todayTotal,
    this.childCount = 0,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context)!;
    final color = parseHexColor(activity.color);
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 2,
              height: 32,
              margin: const EdgeInsets.only(left: 20),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                activity.name,
                style: theme.textTheme.titleMedium,
              ),
            ),
            Text(
              formatDualValue(context, todayTotal.time, todayTotal.count),
              style: theme.textTheme.bodyLarge,
            ),
            if (childCount > 0) ...[
              const SizedBox(width: 4),
              Text(
                l10n.activityCount(childCount),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: theme.colorScheme.secondary,
              ),
            ],
            const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }
}
