import 'package:flutter/material.dart';
import 'package:tick/l10n/app_localizations.dart';
import '../core/extensions.dart';
import '../models/activity.dart';

class ActivityGridTile extends StatelessWidget {
  final Activity activity;
  final ({double time, double count}) todayTotal;
  final int childCount;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const ActivityGridTile({
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

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 2,
                      height: 16,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        activity.name,
                        style: theme.textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (childCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(left: 10, top: 2),
                    child: Text(
                      l10n.activityCount(childCount),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ),
              ],
            ),
            Text(
              formatDualValue(context, todayTotal.time, todayTotal.count),
              style: theme.textTheme.bodyLarge?.copyWith(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
