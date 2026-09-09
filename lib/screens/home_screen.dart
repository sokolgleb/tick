import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tick/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../core/preferences.dart';
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
    final totalsAsync = ref.watch(todayTotalsProvider);
    final viewMode = ref.watch(viewModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: Icon(viewMode == ViewMode.list ? Icons.grid_view : Icons.view_list),
            onPressed: () {
              final next = viewMode == ViewMode.list ? ViewMode.grid : ViewMode.list;
              ref.read(viewModeProvider.notifier).set(next);
            },
          ),
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
            error: (err, _) => Center(child: Text(l10n.error(err.toString()))),
            data: (activities) {
              final totals = totalsAsync.valueOrNull ?? {};
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (activities.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 20, top: 4, bottom: 2),
                      child: Text(
                        l10n.today,
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
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
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              ref.invalidate(activitiesProvider);
                              ref.invalidate(todayTotalsProvider);
                            },
                            child: viewMode == ViewMode.list
                                ? _buildList(context, ref, activities, totals)
                                : _buildGrid(context, ref, activities, totals),
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

  Widget _buildList(BuildContext context, WidgetRef ref, List activities, Map<String, ({double time, double count})> totals) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: activities.length,
      separatorBuilder: (_, __) => Divider(indent: 36, endIndent: 20),
      itemBuilder: (context, index) {
        final activity = activities[index];
        return ActivityTile(
          activity: activity,
          todayTotal: totals[activity.id] ?? (time: 0.0, count: 0.0),
          onTap: () => context.push('/activity/${activity.id}'),
          onLongPress: () => _showOptions(context, ref, activity),
        );
      },
    );
  }

  Widget _buildGrid(BuildContext context, WidgetRef ref, List activities, Map<String, ({double time, double count})> totals) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.4,
      ),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return ActivityGridTile(
          activity: activity,
          todayTotal: totals[activity.id] ?? (time: 0.0, count: 0.0),
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
      ref.invalidate(todayTotalsProvider);
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
                ref.invalidate(todayTotalsProvider);
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
