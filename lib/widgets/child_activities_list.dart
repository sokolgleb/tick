import 'package:flutter/material.dart';
import 'package:tick/l10n/app_localizations.dart';
import '../core/extensions.dart';
import '../models/activity.dart';

class ChildActivitiesList extends StatelessWidget {
  final List<Activity> children;
  final Map<String, ({double time, double count})> totals;
  final void Function(Activity) onTap;

  const ChildActivitiesList({
    super.key,
    required this.children,
    required this.totals,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.subActivities, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        ...children.map((child) {
          final color = parseHexColor(child.color);
          final total = totals[child.id] ?? (time: 0.0, count: 0.0);

          return InkWell(
            onTap: () => onTap(child),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 2,
                    height: 20,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(child.name, style: theme.textTheme.titleMedium),
                  ),
                  Text(
                    formatDualValue(context, total.time, total.count),
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
