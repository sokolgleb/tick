import 'package:flutter/material.dart';
import 'package:tick/l10n/app_localizations.dart';
import '../models/entry_sort.dart';

class SortSelector extends StatelessWidget {
  final EntrySort value;
  final ValueChanged<EntrySort> onChanged;

  const SortSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context)!;
    final theme = Theme.of(context);

    return PopupMenuButton<EntrySort>(
      initialValue: value,
      onSelected: onChanged,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sort, size: 16, color: theme.colorScheme.secondary),
          const SizedBox(width: 4),
          Text(
            _label(l10n, value),
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
      itemBuilder: (ctx) => [
        PopupMenuItem(value: EntrySort.dateDesc, child: Text(l10n.sortByDate)),
        PopupMenuItem(value: EntrySort.valueAsc, child: Text(l10n.sortByValueAsc)),
        PopupMenuItem(value: EntrySort.valueDesc, child: Text(l10n.sortByValueDesc)),
      ],
    );
  }

  String _label(S l10n, EntrySort sort) {
    return switch (sort) {
      EntrySort.dateDesc || EntrySort.dateAsc => l10n.sortByDate,
      EntrySort.valueAsc => l10n.sortByValueAsc,
      EntrySort.valueDesc => l10n.sortByValueDesc,
    };
  }
}
