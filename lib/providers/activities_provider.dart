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
