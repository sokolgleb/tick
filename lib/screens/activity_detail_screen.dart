import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tick/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../core/extensions.dart';
import '../models/entry_sort.dart';
import '../models/stat_period.dart';
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
  bool _presetsExpanded = false;

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

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: _buildBreadcrumb(context, l10n, theme, ancestors, activity),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  children: [
                    // 1. Compact log input
                    if (activity != null) _buildCompactLog(context, l10n, theme),

                    const Divider(height: 32),

                    // 2. Children
                    childrenAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (children) {
                        if (children.isEmpty) return const SizedBox.shrink();
                        final totals = totalsAsync.valueOrNull ?? {};
                        return Column(
                          children: [
                            ChildActivitiesList(
                              children: children,
                              totals: totals,
                              onTap: (child) => context.push('/activity/${child.id}'),
                            ),
                            const Divider(height: 32),
                          ],
                        );
                      },
                    ),

                    // 3. Stats with dropdown period
                    statsAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Text(l10n.error(err.toString())),
                      data: (stats) {
                        if (activity == null) return const SizedBox.shrink();
                        final value = stats[_statsPeriod] ?? (time: 0.0, count: 0.0);
                        return _buildStatsSection(context, l10n, theme, value);
                      },
                    ),

                    const Divider(height: 32),

                    // 4. History — collapsed by default
                    _buildHistorySection(context, l10n, theme, entriesAsync),
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
            Text(
              activity.name,
              style: theme.textTheme.titleLarge,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactLog(BuildContext context, S l10n, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quick-action row: two buttons + expand toggle
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  _QuickLogButton(
                    label: l10n.logTime,
                    icon: Icons.schedule_outlined,
                    onTap: () => _showCustomDialog(context, isTimeOnly: true),
                  ),
                  const SizedBox(width: 8),
                  _QuickLogButton(
                    label: l10n.logCount,
                    icon: Icons.tag_outlined,
                    onTap: () => _showCustomDialog(context, isTimeOnly: false),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                _presetsExpanded ? Icons.expand_less : Icons.expand_more,
                color: theme.colorScheme.secondary,
              ),
              onPressed: () => setState(() => _presetsExpanded = !_presetsExpanded),
              tooltip: _presetsExpanded ? '' : '',
            ),
          ],
        ),
        // Expandable presets
        if (_presetsExpanded) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _ChipButton(label: '5m', onTap: () => _logEntry(context, 5, 0)),
              _ChipButton(label: '10m', onTap: () => _logEntry(context, 10, 0)),
              _ChipButton(label: '15m', onTap: () => _logEntry(context, 15, 0)),
              _ChipButton(label: '30m', onTap: () => _logEntry(context, 30, 0)),
              _ChipButton(label: '1h', onTap: () => _logEntry(context, 60, 0)),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _ChipButton(label: '+1', onTap: () => _logEntry(context, 0, 1)),
              _ChipButton(label: '+5', onTap: () => _logEntry(context, 0, 5)),
              _ChipButton(label: '+10', onTap: () => _logEntry(context, 0, 10)),
              _ChipButton(label: '+25', onTap: () => _logEntry(context, 0, 25)),
            ],
          ),
        ],
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

  void _showCustomDialog(BuildContext context, {required bool isTimeOnly}) {
    final l10n = S.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => _CustomValueDialog(
        title: isTimeOnly ? l10n.customDuration : l10n.customCount,
        showTimeField: isTimeOnly,
        showCountField: !isTimeOnly,
        timeSuffix: l10n.minutes,
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

  void _showAddChildDialog(BuildContext context, activity) async {
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

class _QuickLogButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickLogButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 10),
          side: BorderSide(color: theme.colorScheme.outline),
        ),
      ),
    );
  }
}

class _ChipButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ChipButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(label, style: theme.textTheme.labelLarge),
      ),
    );
  }
}

class _CustomValueDialog extends StatefulWidget {
  final String title;
  final bool showTimeField;
  final bool showCountField;
  final String? timeSuffix;
  final void Function({required double timeMinutes, required double countValue}) onSubmit;

  const _CustomValueDialog({
    required this.title,
    this.showTimeField = true,
    this.showCountField = false,
    this.timeSuffix,
    required this.onSubmit,
  });

  @override
  State<_CustomValueDialog> createState() => _CustomValueDialogState();
}

class _CustomValueDialogState extends State<_CustomValueDialog> {
  final _timeController = TextEditingController();
  final _countController = TextEditingController();

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
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showTimeField)
            TextField(
              controller: _timeController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(suffixText: widget.timeSuffix),
              onSubmitted: (_) => _submit(),
            ),
          if (widget.showCountField)
            TextField(
              controller: _countController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
          child: Text(l10n.add),
        ),
      ],
    );
  }

  void _submit() {
    final time = double.tryParse(_timeController.text.trim()) ?? 0;
    final count = double.tryParse(_countController.text.trim()) ?? 0;
    if (time <= 0 && count <= 0) return;
    Navigator.of(context).pop();
    widget.onSubmit(timeMinutes: time, countValue: count);
  }
}
