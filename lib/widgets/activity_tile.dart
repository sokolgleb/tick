import 'package:flutter/material.dart';
import '../core/extensions.dart';
import '../models/activity.dart';

class ActivityTile extends StatelessWidget {
  final Activity activity;
  final int todayMinutes;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const ActivityTile({
    super.key,
    required this.activity,
    required this.todayMinutes,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(activity.color);
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                activity.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Text(
              todayMinutes.toTimeString(),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 7) buffer.write('FF');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
