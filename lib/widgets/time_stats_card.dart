import 'package:flutter/material.dart';
import 'package:tick/l10n/app_localizations.dart';
import '../core/extensions.dart';
import '../models/stat_period.dart';
import 'date_range_selector.dart';

class TimeStatsCard extends StatefulWidget {
  final Map<StatPeriod, ({double time, double count})> stats;

  const TimeStatsCard({
    super.key,
    required this.stats,
  });

  @override
  State<TimeStatsCard> createState() => _TimeStatsCardState();
}

class _TimeStatsCardState extends State<TimeStatsCard> {
  StatPeriod _selected = StatPeriod.allTime;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context)!;
    final theme = Theme.of(context);
    final value = widget.stats[_selected] ?? (time: 0.0, count: 0.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.summary, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        DateRangeSelector(
          selected: _selected,
          onChanged: (period) => setState(() => _selected = period),
        ),
        const SizedBox(height: 12),
        Text(
          formatDualValue(context, value.time, value.count),
          style: theme.textTheme.headlineLarge?.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
