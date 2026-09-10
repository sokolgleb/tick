import 'package:flutter/material.dart';
import 'package:tick/l10n/app_localizations.dart';
import '../core/extensions.dart';
import '../models/activity.dart';

class ActivityGridTile extends StatelessWidget {
  final Activity activity;
  final ({double time, double count}) todayTotal;
  final int childCount;
  final bool colored;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const ActivityGridTile({
    super.key,
    required this.activity,
    required this.todayTotal,
    this.childCount = 0,
    this.colored = false,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context)!;
    final activityColor = parseHexColor(activity.color);
    final theme = Theme.of(context);

    final bgColor = colored ? activityColor : theme.colorScheme.surfaceContainerHighest;
    final textColor = colored ? _contrastColor(activityColor) : null;
    final secondaryTextColor = colored
        ? textColor?.withAlpha(180)
        : theme.colorScheme.secondary;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!colored)
                  Row(
                    children: [
                      Container(
                        width: 2,
                        height: 16,
                        decoration: BoxDecoration(
                          color: activityColor,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          activity.name,
                          style: theme.textTheme.titleMedium?.copyWith(color: textColor),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    activity.name,
                    style: theme.textTheme.titleMedium?.copyWith(color: textColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (childCount > 0)
                  Padding(
                    padding: EdgeInsets.only(left: colored ? 0 : 10, top: 2),
                    child: Text(
                      l10n.activityCount(childCount),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: secondaryTextColor,
                      ),
                    ),
                  ),
              ],
            ),
            Text(
              formatDualValue(context, todayTotal.time, todayTotal.count),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 20,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Color _contrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.4 ? Colors.black : Colors.white;
  }
}
