import 'package:flutter/material.dart';
import 'package:tick/l10n/app_localizations.dart';
import '../core/extensions.dart';
import '../models/entry_sort.dart';
import '../models/time_entry.dart';
import 'sort_selector.dart';

class TimeEntryList extends StatelessWidget {
  final List<TimeEntry> entries;
  final EntrySort sort;
  final ValueChanged<EntrySort> onSortChanged;
  final void Function(String entryId) onDelete;
  final bool showHeader;

  const TimeEntryList({
    super.key,
    required this.entries,
    required this.sort,
    required this.onSortChanged,
    required this.onDelete,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.history, style: theme.textTheme.headlineSmall),
              SortSelector(value: sort, onChanged: onSortChanged),
            ],
          ),
        if (!showHeader && entries.isNotEmpty)
          Align(
            alignment: Alignment.centerRight,
            child: SortSelector(value: sort, onChanged: onSortChanged),
          ),
        const SizedBox(height: 8),
        if (entries.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(l10n.noEntriesYet, style: theme.textTheme.bodyMedium),
            ),
          )
        else
          ..._buildGrouped(context),
      ],
    );
  }

  List<Widget> _buildGrouped(BuildContext context) {
    final theme = Theme.of(context);
    final grouped = <DateTime, List<TimeEntry>>{};
    for (final entry in entries) {
      final dateKey = entry.date.startOfDay;
      grouped.putIfAbsent(dateKey, () => []).add(entry);
    }

    final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    final widgets = <Widget>[];

    for (final date in sortedDates) {
      final dayEntries = grouped[date]!;
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 4),
          child: Text(
            date.toLocalizedDateString(context),
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      );
      for (final entry in dayEntries) {
        widgets.add(
          Dismissible(
            key: Key(entry.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              color: theme.colorScheme.error,
              child: Icon(Icons.delete_outline, color: theme.colorScheme.onError),
            ),
            onDismissed: (_) => onDelete(entry.id),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text(
                    formatDualValue(context, entry.value, entry.countValue),
                    style: theme.textTheme.bodyLarge,
                  ),
                  if (entry.note != null && entry.note!.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.note!,
                        style: theme.textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }
    }
    return widgets;
  }
}
