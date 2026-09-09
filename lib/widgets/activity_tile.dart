import 'package:flutter/material.dart';
import '../core/extensions.dart';
import '../models/activity.dart';

class ActivityTile extends StatelessWidget {
  final Activity activity;
  final ({double time, double count}) todayTotal;
  final bool hasChildren;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const ActivityTile({
    super.key,
    required this.activity,
    required this.todayTotal,
    this.hasChildren = false,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final color = parseHexColor(activity.color);

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
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Text(
              formatDualValue(context, todayTotal.time, todayTotal.count),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (hasChildren)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }
}
