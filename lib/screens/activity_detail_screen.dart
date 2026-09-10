import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tick/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../core/extensions.dart';
import '../models/entry_sort.dart';
import '../models/stat_period.dart';
import '../models/time_entry.dart';
import '../providers/activities_provider.dart';
import '../providers/time_entries_provider.dart';
import '../widgets/add_activity_dialog.dart';
import '../widgets/child_activities_list.dart';
import '../widgets/time_entry_list.dart';

class ActivityDetailScreen extends ConsumerStatefulWidget {
  final String activityId;

  const ActivityDetailScreen({super.key, required this.activityId});

  @override
  ConsumerState<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends ConsumerState<ActivityDetailScreen> {
  EntrySort _sort = EntrySort.dateDesc;
  DateTimeRange? _customRange;
  StatPeriod _statsPeriod = StatPeriod.allTime;
  bool _historyExpanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context)!;
    final theme = Theme.of(context);
    final activityAsync = ref.watch(activityProvider(widget.activityId));
    final statsAsync = ref.watch(activitySubtreeStatsProvider(
      (activityId: widget.activityId, customRange: _customRange),
    ));
    final entriesAsync = ref.watch(activityEntriesProvider(
      (activityId: widget.activityId, sort: _sort),
    ));
    final childrenAsync = ref.watch(childActivitiesProvider(widget.activityId));
    final totalsAsync = ref.watch(todayTotalsProvider);
    final ancestorsAsync = ref.watch(activityAncestorsProvider(widget.activityId));

    final activity = activityAsync.valueOrNull;
    final ancestors = ancestorsAsync.valueOrNull ?? [];
    final cardColor = theme.colorScheme.surfaceContainerHighest;
    final cardRadius = BorderRadius.circular(10);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: _buildBreadcrumb(context, l10n, theme, ancestors, activity),
        actions: [
          if (activity != null) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: () => _editActivity(context, activity),
            ),
            IconButton(
              icon: const Icon(Icons.archive_outlined, size: 20),
              onPressed: () => _archiveActivity(context, l10n, activity),
            ),
          ],
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  children: [
                    // 1. Log input
                    if (activity != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: cardColor, borderRadius: cardRadius),
                        child: _buildLogButtons(context, l10n, theme),
                      ),

                    const SizedBox(height: 12),

                    // 2. Stats
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: cardColor, borderRadius: cardRadius),
                      child: statsAsync.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (err, _) => Text(l10n.error(err.toString())),
                        data: (stats) {
                          final value = stats[_statsPeriod] ?? (time: 0.0, count: 0.0);
                          return _buildStatsSection(context, l10n, theme, value);
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 3. Children
                    childrenAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (children) {
                        if (children.isEmpty) return const SizedBox.shrink();
                        final totals = totalsAsync.valueOrNull ?? {};
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: cardColor, borderRadius: cardRadius),
                            child: ChildActivitiesList(
                              children: children,
                              totals: totals,
                              onTap: (child) => context.push('/activity/${child.id}'),
                            ),
                          ),
                        );
                      },
                    ),

                    // 4. History
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: cardColor, borderRadius: cardRadius),
                      child: _buildHistorySection(context, l10n, theme, entriesAsync),
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
              if (activity != null)
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: TextButton.icon(
                        onPressed: () => _showAddChildDialog(context, activity),
                        icon: const Icon(Icons.add, size: 18),
                        label: Text(l10n.newActivity),
                        style: TextButton.styleFrom(splashFactory: NoSplash.splashFactory),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreadcrumb(BuildContext context, S l10n, ThemeData theme, List ancestors, dynamic activity) {
    final separatorStyle = theme.textTheme.titleLarge?.copyWith(
      color: theme.colorScheme.secondary,
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => context.go('/'),
            child: Text(l10n.appTitle, style: theme.textTheme.titleLarge),
          ),
          for (final ancestor in ancestors) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text('/', style: separatorStyle),
            ),
            GestureDetector(
              onTap: () => context.go('/activity/${ancestor.id}'),
              child: Text(
                ancestor.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ),
            ),
          ],
          if (activity != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text('/', style: separatorStyle),
            ),
            Text(activity.name, style: theme.textTheme.titleLarge),
          ],
        ],
      ),
    );
  }

  Widget _buildLogButtons(BuildContext context, S l10n, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _showLogDialog(context, isTimeOnly: true),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    l10n.logTime,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          width: 1,
          height: 24,
          color: theme.colorScheme.outlineVariant,
        ),
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _showLogDialog(context, isTimeOnly: false),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    l10n.logCount,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context, S l10n, ThemeData theme, ({double time, double count}) value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          formatDualValue(context, value.time, value.count),
          style: theme.textTheme.headlineLarge?.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        PopupMenuButton<StatPeriod>(
          onSelected: (period) {
            if (period == StatPeriod.custom) {
              _showDatePicker(context);
            } else {
              setState(() => _statsPeriod = period);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(value: StatPeriod.today, child: Text(l10n.today)),
            PopupMenuItem(value: StatPeriod.yesterday, child: Text(l10n.yesterday)),
            PopupMenuItem(value: StatPeriod.thisWeek, child: Text(l10n.thisWeek)),
            PopupMenuItem(value: StatPeriod.thisMonth, child: Text(l10n.thisMonth)),
            PopupMenuItem(value: StatPeriod.thisYear, child: Text(l10n.thisYear)),
            PopupMenuItem(value: StatPeriod.allTime, child: Text(l10n.allTime)),
            PopupMenuItem(value: StatPeriod.custom, child: Text(l10n.custom)),
          ],
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _periodLabel(l10n, _statsPeriod),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 2),
              Icon(Icons.arrow_drop_down, size: 20, color: theme.colorScheme.secondary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistorySection(BuildContext context, S l10n, ThemeData theme, AsyncValue entriesAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _historyExpanded = !_historyExpanded),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.history, style: theme.textTheme.headlineSmall),
              Icon(
                _historyExpanded ? Icons.expand_less : Icons.expand_more,
                color: theme.colorScheme.secondary,
              ),
            ],
          ),
        ),
        if (_historyExpanded) ...[
          const SizedBox(height: 8),
          entriesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text(l10n.error(err.toString())),
            data: (entries) => TimeEntryList(
              entries: entries,
              sort: _sort,
              onSortChanged: (sort) => setState(() => _sort = sort),
              onDelete: (entryId) => _deleteEntry(context, entryId),
              onEdit: (entry) => _editEntry(context, entry),
              showHeader: false,
            ),
          ),
        ],
      ],
    );
  }

  String _periodLabel(S l10n, StatPeriod period) {
    switch (period) {
      case StatPeriod.today:
        return l10n.today;
      case StatPeriod.yesterday:
        return l10n.yesterday;
      case StatPeriod.thisWeek:
        return l10n.thisWeek;
      case StatPeriod.thisMonth:
        return l10n.thisMonth;
      case StatPeriod.thisYear:
        return l10n.thisYear;
      case StatPeriod.allTime:
        return l10n.allTime;
      case StatPeriod.custom:
        return l10n.custom;
    }
  }

  void _showDatePicker(BuildContext context) async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialEntryMode: DatePickerEntryMode.input,
      initialDateRange: _customRange ?? DateTimeRange(
        start: now.subtract(const Duration(days: 7)),
        end: now,
      ),
    );
    if (range != null) {
      setState(() {
        _customRange = range;
        _statsPeriod = StatPeriod.custom;
      });
    }
  }

  // --- Log dialog with presets ---

  void _showLogDialog(BuildContext context, {required bool isTimeOnly}) {
    final l10n = S.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => _LogDialog(
        title: isTimeOnly ? l10n.logTime : l10n.logCount,
        isTime: isTimeOnly,
        onSubmit: ({required double timeMinutes, required double countValue}) {
          _logEntry(context, timeMinutes, countValue);
        },
      ),
    );
  }

  void _logEntry(BuildContext context, double timeMinutes, double countValue) async {
    final l10n = S.of(context)!;
    try {
      await ref.read(timeEntriesRepositoryProvider).addEntry(
            activityId: widget.activityId,
            timeMinutes: timeMinutes,
            countValue: countValue,
          );
      _invalidateAll();
      if (context.mounted) {
        final display = formatDualValue(context, timeMinutes, countValue);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.logged(display))),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.error(e.toString()))),
        );
      }
    }
  }

  // --- Entry edit/delete ---

  void _editEntry(BuildContext context, TimeEntry entry) async {
    final l10n = S.of(context)!;
    final result = await showDialog<({double time, double count})>(
      context: context,
      builder: (ctx) => _EditEntryDialog(entry: entry),
    );
    if (result == null) return;
    try {
      await ref.read(timeEntriesRepositoryProvider).updateEntry(
            entry.id,
            timeMinutes: result.time,
            countValue: result.count,
          );
      _invalidateAll();
      if (context.mounted) {
        final display = formatDualValue(context, result.time, result.count);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.updated(display))),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.error(e.toString()))),
        );
      }
    }
  }

  void _deleteEntry(BuildContext context, String entryId) async {
    final l10n = S.of(context)!;
    try {
      await ref.read(timeEntriesRepositoryProvider).deleteEntry(entryId);
      _invalidateAll();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.error(e.toString()))),
        );
      }
    }
  }

  // --- Activity edit/archive ---

  void _editActivity(BuildContext context, dynamic activity) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => AddActivityDialog(
        initialName: activity.name,
        initialColor: activity.color,
      ),
    );
    if (result != null) {
      await ref.read(activitiesProvider.notifier).updateActivity(
            activity.id,
            name: result['name'],
            color: result['color'],
          );
      ref.invalidate(activityProvider(widget.activityId));
      ref.invalidate(activityAncestorsProvider(widget.activityId));
    }
  }

  void _archiveActivity(BuildContext context, S l10n, dynamic activity) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.archiveActivity),
        content: Text(l10n.archiveActivityConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.archive),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(activitiesProvider.notifier).updateActivity(
            activity.id,
            archived: true,
          );
      ref.read(timeEntriesVersionProvider.notifier).state++;
      if (context.mounted) context.go('/');
    }
  }

  void _showAddChildDialog(BuildContext context, dynamic activity) async {
    if (activity == null) return;
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => AddActivityDialog(
        parentName: activity.name,
        initialColor: activity.color,
      ),
    );
    if (result != null) {
      await ref.read(activitiesProvider.notifier).create(
            name: result['name']!,
            color: result['color']!,
            parentId: widget.activityId,
          );
      ref.invalidate(childActivitiesProvider(widget.activityId));
      ref.invalidate(activityChildCountsProvider);
    }
  }

  void _invalidateAll() {
    ref.invalidate(activityEntriesProvider(
      (activityId: widget.activityId, sort: _sort),
    ));
    ref.read(timeEntriesVersionProvider.notifier).state++;
  }
}

// --- Log Dialog with presets + text field ---

enum _TimeUnit { seconds, minutes, hours, days }

class _LogDialog extends StatefulWidget {
  final String title;
  final bool isTime;
  final void Function({required double timeMinutes, required double countValue}) onSubmit;

  const _LogDialog({
    required this.title,
    required this.isTime,
    required this.onSubmit,
  });

  @override
  State<_LogDialog> createState() => _LogDialogState();
}

class _LogDialogState extends State<_LogDialog> {
  final _controller = TextEditingController();
  _TimeUnit _unit = _TimeUnit.minutes;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _toMinutes(double value) {
    switch (_unit) {
      case _TimeUnit.seconds:
        return value / 60;
      case _TimeUnit.minutes:
        return value;
      case _TimeUnit.hours:
        return value * 60;
      case _TimeUnit.days:
        return value * 1440;
    }
  }

  void _submit(double value) {
    if (value <= 0) return;
    Navigator.of(context).pop();
    if (widget.isTime) {
      widget.onSubmit(timeMinutes: _toMinutes(value), countValue: 0);
    } else {
      widget.onSubmit(timeMinutes: 0, countValue: value);
    }
  }

  void _submitField() {
    final value = double.tryParse(_controller.text.trim()) ?? 0;
    _submit(value);
  }

  List<(String, double)> _presetsForUnit() {
    switch (_unit) {
      case _TimeUnit.seconds:
        return [('15s', 15), ('30s', 30), ('45s', 45), ('60s', 60), ('90s', 90)];
      case _TimeUnit.minutes:
        return [('5m', 5), ('10m', 10), ('15m', 15), ('30m', 30), ('1h', 60)];
      case _TimeUnit.hours:
        return [('0.5h', 0.5), ('1h', 1), ('2h', 2), ('4h', 4), ('8h', 8)];
      case _TimeUnit.days:
        return [('1d', 1), ('2d', 2), ('3d', 3), ('5d', 5), ('7d', 7)];
    }
  }

  String _unitSuffix(S l10n) {
    switch (_unit) {
      case _TimeUnit.seconds:
        return l10n.seconds;
      case _TimeUnit.minutes:
        return l10n.minutes;
      case _TimeUnit.hours:
        return l10n.hours;
      case _TimeUnit.days:
        return l10n.days;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context)!;
    final theme = Theme.of(context);

    final presets = widget.isTime ? _presetsForUnit() : [('+1', 1.0), ('+5', 5.0), ('+10', 10.0), ('+25', 25.0), ('+50', 50.0), ('+100', 100.0)];

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      title: Text(widget.title),
      content: SizedBox(
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.isTime)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SegmentedButton<_TimeUnit>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(value: _TimeUnit.seconds, label: Text(l10n.seconds)),
                    ButtonSegment(value: _TimeUnit.minutes, label: Text(l10n.minutes)),
                    ButtonSegment(value: _TimeUnit.hours, label: Text(l10n.hours)),
                    ButtonSegment(value: _TimeUnit.days, label: Text(l10n.days)),
                  ],
                  selected: {_unit},
                  onSelectionChanged: (selected) {
                    setState(() => _unit = selected.first);
                  },
                ),
              ),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: presets.map((p) {
                return InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () => _submit(p.$2),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.colorScheme.outline),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(p.$1, style: theme.textTheme.labelLarge),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              autofocus: false,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                suffixText: widget.isTime ? _unitSuffix(l10n) : null,
                hintText: widget.isTime ? '45' : '3',
              ),
              onSubmitted: (_) => _submitField(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: _submitField,
          child: Text(l10n.add),
        ),
      ],
    );
  }
}

// --- Edit Entry Dialog ---

class _EditEntryDialog extends StatefulWidget {
  final TimeEntry entry;

  const _EditEntryDialog({required this.entry});

  @override
  State<_EditEntryDialog> createState() => _EditEntryDialogState();
}

class _EditEntryDialogState extends State<_EditEntryDialog> {
  late final TextEditingController _timeController;
  late final TextEditingController _countController;

  @override
  void initState() {
    super.initState();
    _timeController = TextEditingController(
      text: widget.entry.value > 0 ? widget.entry.value.toString() : '',
    );
    _countController = TextEditingController(
      text: widget.entry.countValue > 0 ? widget.entry.countValue.toString() : '',
    );
  }

  @override
  void dispose() {
    _timeController.dispose();
    _countController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context)!;
    return AlertDialog(
      title: Text(l10n.editEntry),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _timeController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.time,
              suffixText: l10n.minutes,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _countController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: l10n.count),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: _submit,
          child: Text(l10n.save),
        ),
      ],
    );
  }

  void _submit() {
    final time = double.tryParse(_timeController.text.trim()) ?? 0;
    final count = double.tryParse(_countController.text.trim()) ?? 0;
    Navigator.of(context).pop((time: time, count: count));
  }
}
