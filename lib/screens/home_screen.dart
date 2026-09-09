import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/activities_provider.dart';
import '../providers/time_entries_provider.dart';
import '../widgets/activity_tile.dart';
import '../widgets/add_activity_dialog.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(activitiesProvider);
    final totalsAsync = ref.watch(todayTotalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tick'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: activitiesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
            data: (activities) {
              final totals = totalsAsync.valueOrNull ?? {};
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (activities.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 20, top: 8, bottom: 4),
                      child: Text(
                        'Today',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  Expanded(
                    child: activities.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'No activities yet',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                const SizedBox(height: 16),
                                FilledButton.icon(
                                  onPressed: () => _showAddDialog(context, ref),
                                  icon: const Icon(Icons.add),
                                  label: const Text('New Activity'),
                                  style: FilledButton.styleFrom(
                                    minimumSize: const Size(200, 48),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              ref.invalidate(activitiesProvider);
                              ref.invalidate(todayTotalsProvider);
                            },
                            child: ListView.separated(
                              padding: EdgeInsets.zero,
                              itemCount: activities.length,
                              separatorBuilder: (_, __) => const Divider(indent: 48),
                              itemBuilder: (context, index) {
                                final activity = activities[index];
                                return ActivityTile(
                                  activity: activity,
                                  todayMinutes: totals[activity.id] ?? 0,
                                  onTap: () => context.push('/activity/${activity.id}'),
                                  onLongPress: () => _showOptions(context, ref, activity),
                                );
                              },
                            ),
                          ),
                  ),
                  if (activities.isNotEmpty)
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: TextButton.icon(
                            onPressed: () => _showAddDialog(context, ref),
                            icon: const Icon(Icons.add),
                            label: const Text('New Activity'),
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
      ref.invalidate(todayTotalsProvider);
    }
  }

  void _showOptions(BuildContext context, WidgetRef ref, activity) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
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
              title: const Text('Archive'),
              onTap: () async {
                Navigator.pop(ctx);
                await ref.read(activitiesProvider.notifier).updateActivity(
                      activity.id,
                      archived: true,
                    );
                ref.invalidate(todayTotalsProvider);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(ctx);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete activity?'),
                    content: const Text('This will also delete all time entries for this activity.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: FilledButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await ref.read(activitiesProvider.notifier).delete(activity.id);
                  ref.invalidate(todayTotalsProvider);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
