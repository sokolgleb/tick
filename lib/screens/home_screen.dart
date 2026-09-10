import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tick/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../core/preferences.dart';
import '../models/stat_period.dart';
import '../providers/activities_provider.dart';
import '../providers/preferences_provider.dart';
import '../providers/time_entries_provider.dart';
import '../widgets/activity_tile.dart';
import '../widgets/activity_grid_tile.dart';
import '../widgets/add_activity_dialog.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = S.of(context)!;
    final theme = Theme.of(context);
    final activitiesAsync = ref.watch(activitiesProvider);
    final viewMode = ref.watch(viewModeProvider);
    final selectedPeriod = ref.watch(homeSelectedPeriodProvider);
    final childCounts = ref.watch(activityChildCountsProvider).valueOrNull ?? {};

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => context.go('/'),
              child: Text(l10n.appTitle),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(viewMode == ViewMode.list ? Icons.apps_outlined : Icons.view_agenda_outlined),
              onPressed: () {
                final next = viewMode == ViewMode.list ? ViewMode.grid : ViewMode.list;
                ref.read(viewModeProvider.notifier).set(next);
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: viewMode == ViewMode.list ? 600 : double.infinity),
          child: activitiesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text(l10n.error(err.toString()))),
            data: (activities) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (activities.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 20, top: 4, bottom: 2, right: 20),
                      child: _PeriodSelector(
                        selected: selectedPeriod,
                        onChanged: (period) {
                          ref.read(homeSelectedPeriodProvider.notifier).state = period;
                        },
                        onCustomRange: (range) {
                          ref.read(homeCustomRangeProvider.notifier).state = range;
                          ref.read(homeSelectedPeriodProvider.notifier).state = StatPeriod.custom;
                        },
                      ),
                    ),
                  Expanded(
                    child: activities.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  l10n.noActivitiesYet,
                                  style: theme.textTheme.bodyLarge,
                                ),
                                const SizedBox(height: 16),
                                TextButton.icon(
                                  onPressed: () => _showAddDialog(context, ref),
                                  icon: const Icon(Icons.add),
                                  label: Text(l10n.newActivity),
                                  style: TextButton.styleFrom(splashFactory: NoSplash.splashFactory),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              ref.invalidate(activitiesProvider);
                              ref.invalidate(activityChildCountsProvider);
                              ref.read(timeEntriesVersionProvider.notifier).state++;
                            },
                            child: viewMode == ViewMode.list
                                ? _buildList(context, ref, activities, childCounts)
                                : _buildGrid(context, ref, activities, childCounts),
                          ),
                  ),
                  if (activities.isNotEmpty)
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: TextButton.icon(
                            onPressed: () => _showAddDialog(context, ref),
                            icon: const Icon(Icons.add, size: 18),
                            label: Text(l10n.newActivity),
                            style: TextButton.styleFrom(splashFactory: NoSplash.splashFactory),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, WidgetRef ref, List activities, Map<String, int> childCounts) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: activities.length,
      separatorBuilder: (_, __) => Divider(indent: 36, endIndent: 20),
      itemBuilder: (context, index) {
        final activity = activities[index];
        final subtreeAsync = ref.watch(homeSubtreeTotalsProvider(activity.id));
        final total = subtreeAsync.valueOrNull ?? (time: 0.0, count: 0.0);
        return ActivityTile(
          activity: activity,
          todayTotal: total,
          childCount: childCounts[activity.id] ?? 0,
          onTap: () => context.push('/activity/${activity.id}'),
          onLongPress: () => _showOptions(context, ref, activity),
        );
      },
    );
  }

  Widget _buildGrid(BuildContext context, WidgetRef ref, List activities, Map<String, int> childCounts) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.4,
      ),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        final subtreeAsync = ref.watch(homeSubtreeTotalsProvider(activity.id));
        final total = subtreeAsync.valueOrNull ?? (time: 0.0, count: 0.0);
        return ActivityGridTile(
          activity: activity,
          todayTotal: total,
          childCount: childCounts[activity.id] ?? 0,
          onTap: () => context.push('/activity/${activity.id}'),
          onLongPress: () => _showOptions(context, ref, activity),
        );
      },
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const AddActivityDialog(),
    );
    if (result != null) {
      await ref.read(activitiesProvider.notifier).create(
            name: result['name']!,
            color: result['color']!,
          );
      ref.invalidate(activityChildCountsProvider);
      ref.read(timeEntriesVersionProvider.notifier).state++;
    }
  }

  void _showOptions(BuildContext context, WidgetRef ref, activity) {
    final l10n = S.of(context)!;
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(l10n.edit),
              onTap: () async {
                Navigator.pop(ctx);
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
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive_outlined),
              title: Text(l10n.archive),
              onTap: () async {
                Navigator.pop(ctx);
                await ref.read(activitiesProvider.notifier).updateActivity(
                      activity.id,
                      archived: true,
                    );
                ref.read(timeEntriesVersionProvider.notifier).state++;
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: theme.colorScheme.error),
              title: Text(l10n.delete, style: TextStyle(color: theme.colorScheme.error)),
              onTap: () async {
                Navigator.pop(ctx);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(l10n.deleteActivity),
                    content: Text(l10n.deleteActivityConfirm),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(l10n.cancel),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                        ),
                        child: Text(l10n.delete),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await ref.read(activitiesProvider.notifier).delete(activity.id);
                  ref.read(timeEntriesVersionProvider.notifier).state++;
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  final StatPeriod selected;
  final ValueChanged<StatPeriod> onChanged;
  final ValueChanged<DateTimeRange> onCustomRange;

  const _PeriodSelector({
    required this.selected,
    required this.onChanged,
    required this.onCustomRange,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context)!;
    final theme = Theme.of(context);

    return PopupMenuButton<StatPeriod>(
      onSelected: (period) {
        if (period == StatPeriod.custom) {
          _showDatePicker(context);
        } else {
          onChanged(period);
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
            _periodLabel(l10n, selected),
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 4),
          Icon(Icons.arrow_drop_down, size: 20, color: theme.colorScheme.secondary),
        ],
      ),
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
      initialDateRange: DateTimeRange(
        start: now.subtract(const Duration(days: 7)),
        end: now,
      ),
    );
    if (range != null) {
      onCustomRange(range);
    }
  }
}
