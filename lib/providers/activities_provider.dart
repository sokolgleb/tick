import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity.dart';
import '../repositories/activities_repository.dart';
import 'auth_provider.dart';

final activitiesRepositoryProvider = Provider<ActivitiesRepository>(
  (ref) => ActivitiesRepository(ref.watch(supabaseClientProvider)),
);

/// Top-level activities (no parent)
final activitiesProvider = AsyncNotifierProvider<ActivitiesNotifier, List<Activity>>(
  ActivitiesNotifier.new,
);

class ActivitiesNotifier extends AsyncNotifier<List<Activity>> {
  @override
  Future<List<Activity>> build() async {
    return ref.read(activitiesRepositoryProvider).getActivities();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(activitiesRepositoryProvider).getActivities());
  }

  Future<void> create({
    required String name,
    required String color,
    String? parentId,
  }) async {
    await ref.read(activitiesRepositoryProvider).create(
          name: name,
          color: color,
          parentId: parentId,
        );
    await refresh();
  }

  Future<void> updateActivity(String id, {String? name, String? color, int? position, bool? archived}) async {
    await ref.read(activitiesRepositoryProvider).update(id, name: name, color: color, position: position, archived: archived);
    await refresh();
  }

  Future<void> delete(String id) async {
    await ref.read(activitiesRepositoryProvider).delete(id);
    await refresh();
  }
}

/// Child activities for a given parent
final childActivitiesProvider = FutureProvider.family<List<Activity>, String>((ref, parentId) {
  return ref.watch(activitiesRepositoryProvider).getChildren(parentId);
});

/// Single activity by ID
final activityProvider = FutureProvider.family<Activity?, String>((ref, id) {
  return ref.watch(activitiesRepositoryProvider).getActivityById(id);
});

/// Full ancestor chain for an activity (from root to current, excluding current)
final activityAncestorsProvider = FutureProvider.family<List<Activity>, String>((ref, activityId) async {
  final repo = ref.watch(activitiesRepositoryProvider);
  final activity = await repo.getActivityById(activityId);
  if (activity == null || activity.parentId == null) return [];

  final ancestors = <Activity>[];
  String? currentParentId = activity.parentId;
  while (currentParentId != null) {
    final parent = await repo.getActivityById(currentParentId);
    if (parent == null) break;
    ancestors.insert(0, parent);
    currentParentId = parent.parentId;
  }
  return ancestors;
});

/// Child counts for top-level activities: {activityId: count}
final activityChildCountsProvider = FutureProvider<Map<String, int>>((ref) async {
  final repo = ref.watch(activitiesRepositoryProvider);
  final activities = ref.watch(activitiesProvider).valueOrNull ?? [];
  final counts = <String, int>{};
  for (final activity in activities) {
    final children = await repo.getChildren(activity.id);
    counts[activity.id] = children.length;
  }
  return counts;
});
