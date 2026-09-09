import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tick/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../core/extensions.dart';
import '../models/entry_sort.dart';
import '../providers/activities_provider.dart';
import '../providers/time_entries_provider.dart';
import '../widgets/add_activity_dialog.dart';
import '../widgets/child_activities_list.dart';
import '../widgets/log_time_widget.dart';
import '../widgets/time_stats_card.dart';
import '../widgets/time_entry_list.dart';

class ActivityDetailScreen extends ConsumerStatefulWidget {
  final String activityId;

  const ActivityDetailScreen({super.key, required this.activityId});

  @override
  ConsumerState<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends ConsumerState<ActivityDetailScreen> {
  EntrySort _sort = EntrySort.dateDesc;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context)!;
    final activityAsync = ref.watch(activityProvider(widget.activityId));
    final statsAsync = ref.watch(activityStatsProvider(widget.activityId));
    final entriesAsync = ref.watch(activityEntriesProvider(
      (activityId: widget.activityId, sort: _sort),
    ));
    final childrenAsync = ref.watch(childActivitiesProvider(widget.activityId));
    final totalsAsync = ref.watch(todayTotalsProvider);

    final activity = activityAsync.valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(activity?.name ?? ''),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // 1. Input — both time and count
              if (activity != null)
                LogTimeWidget(
                  onLog: ({required double timeMinutes, required double countValue}) =>
                      _logEntry(context, timeMinutes, countValue),
                ),
              const SizedBox(height: 24),

              // 2. Children
              childrenAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (children) {
                  if (children.isEmpty) return const SizedBox.shrink();
                  final totals = totalsAsync.valueOrNull ?? {};
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: ChildActivitiesList(
                      children: children,
                      totals: totals,
                      onTap: (child) => context.push('/activity/${child.id}'),
                      onAdd: () => _showAddChildDialog(context, activity),
                    ),
                  );
                },
              ),

              // Add sub-activity button if no children yet
              if (activity != null)
                childrenAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (children) {
                    if (children.isNotEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: TextButton.icon(
                        onPressed: () => _showAddChildDialog(context, activity),
                        icon: const Icon(Icons.add, size: 16),
                        label: Text(l10n.addSubActivity),
                      ),
                    );
                  },
                ),

              // 3. Stats
              statsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Text(l10n.error(err.toString())),
                data: (stats) {
                  if (activity == null) return const SizedBox.shrink();
                  return TimeStatsCard(stats: stats);
                },
              ),
              const SizedBox(height: 24),

              // 4. History
              entriesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Text(l10n.error(err.toString())),
                data: (entries) => TimeEntryList(
                  entries: entries,
                  sort: _sort,
                  onSortChanged: (sort) => setState(() => _sort = sort),
                  onDelete: (entryId) => _deleteEntry(context, entryId),
                ),
              ),
            ],
          ),
        ),
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
      builder: (_) => AddActivityDialog(parentName: activity.name),
    );
    if (result != null) {
      await ref.read(activitiesProvider.notifier).create(
            name: result['name']!,
            color: result['color']!,
            parentId: widget.activityId,
          );
      ref.invalidate(childActivitiesProvider(widget.activityId));
    }
  }

  void _invalidateAll() {
    ref.invalidate(activityEntriesProvider(
      (activityId: widget.activityId, sort: _sort),
    ));
    ref.invalidate(activityStatsProvider(widget.activityId));
    ref.invalidate(todayTotalsProvider);
  }
}
