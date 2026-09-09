import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/extensions.dart';
import '../providers/activities_provider.dart';
import '../providers/time_entries_provider.dart';
import '../widgets/log_time_widget.dart';
import '../widgets/time_stats_card.dart';
import '../widgets/time_entry_list.dart';

class ActivityDetailScreen extends ConsumerWidget {
  final String activityId;

  const ActivityDetailScreen({super.key, required this.activityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(activitiesProvider);
    final statsAsync = ref.watch(activityStatsProvider(activityId));
    final entriesAsync = ref.watch(activityEntriesProvider(activityId));

    final activity = activitiesAsync.valueOrNull?.where((a) => a.id == activityId).firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(activity?.name ?? ''),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              LogTimeWidget(
                onLog: (minutes) => _logTime(context, ref, minutes),
              ),
              const SizedBox(height: 32),
              statsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Text('Error: $err'),
                data: (stats) => TimeStatsCard(stats: stats),
              ),
              const SizedBox(height: 32),
              entriesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Text('Error: $err'),
                data: (entries) => TimeEntryList(
                  entries: entries,
                  onDelete: (entryId) => _deleteEntry(context, ref, entryId),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _logTime(BuildContext context, WidgetRef ref, int minutes) async {
    try {
      await ref.read(timeEntriesRepositoryProvider).addEntry(
            activityId: activityId,
            durationMinutes: minutes,
          );
      ref.invalidate(activityEntriesProvider(activityId));
      ref.invalidate(activityStatsProvider(activityId));
      ref.invalidate(todayTotalsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logged ${minutes.toTimeString()}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _deleteEntry(BuildContext context, WidgetRef ref, String entryId) async {
    try {
      await ref.read(timeEntriesRepositoryProvider).deleteEntry(entryId);
      ref.invalidate(activityEntriesProvider(activityId));
      ref.invalidate(activityStatsProvider(activityId));
      ref.invalidate(todayTotalsProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
