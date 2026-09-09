import 'package:flutter/material.dart';
import '../core/extensions.dart';
import '../models/time_entry.dart';

class TimeEntryList extends StatelessWidget {
  final List<TimeEntry> entries;
  final void Function(String entryId) onDelete;

  const TimeEntryList({
    super.key,
    required this.entries,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'No entries yet',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    // Group entries by date
    final grouped = <DateTime, List<TimeEntry>>{};
    for (final entry in entries) {
      final dateKey = entry.date.startOfDay;
      grouped.putIfAbsent(dateKey, () => []).add(entry);
    }

    final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('History', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        ...sortedDates.map((date) {
          final dayEntries = grouped[date]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Text(
                  date.toDateString(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              ...dayEntries.map((entry) => Dismissible(
                    key: Key(entry.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: Colors.red,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) => onDelete(entry.id),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          Text(
                            entry.durationMinutes.toTimeString(),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          if (entry.note != null && entry.note!.isNotEmpty) ...[
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                entry.note!,
                                style: Theme.of(context).textTheme.bodyMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )),
            ],
          );
        }),
      ],
    );
  }
}
