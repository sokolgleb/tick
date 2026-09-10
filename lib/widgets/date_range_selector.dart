import 'package:flutter/material.dart';
import 'package:tick/l10n/app_localizations.dart';
import '../models/stat_period.dart';

class DateRangeSelector extends StatelessWidget {
  final StatPeriod selected;
  final ValueChanged<StatPeriod> onChanged;
  final ValueChanged<DateTimeRange>? onCustomRange;

  const DateRangeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
    this.onCustomRange,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context)!;
    final theme = Theme.of(context);

    final periods = [
      (StatPeriod.today, l10n.today),
      (StatPeriod.thisWeek, l10n.thisWeek),
      (StatPeriod.thisMonth, l10n.thisMonth),
      (StatPeriod.thisYear, l10n.thisYear),
      (StatPeriod.allTime, l10n.allTime),
      (StatPeriod.custom, l10n.custom),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: periods.map((entry) {
          final (period, label) = entry;
          final isSelected = selected == period;

          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () {
                if (period == StatPeriod.custom && onCustomRange != null) {
                  _showDatePicker(context);
                } else {
                  onChanged(period);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                  ),
                ),
                child: Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showDatePicker(BuildContext context) async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialEntryMode: DatePickerEntryMode.input,
      initialDateRange: DateTimeRange(
        start: now.subtract(const Duration(days: 7)),
        end: now,
      ),
    );
    if (range != null) {
      onChanged(StatPeriod.custom);
      onCustomRange?.call(range);
    }
  }
}
