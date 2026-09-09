import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/extensions.dart';
import '../models/time_entry.dart';
import '../repositories/time_entries_repository.dart';
import 'auth_provider.dart';

final timeEntriesRepositoryProvider = Provider<TimeEntriesRepository>(
  (ref) => TimeEntriesRepository(ref.watch(supabaseClientProvider)),
);

/// Today's totals: map of activityId to totalMinutes
final todayTotalsProvider = FutureProvider<Map<String, int>>((ref) {
  final repo = ref.watch(timeEntriesRepositoryProvider);
  final now = DateTime.now();
  final today = now.startOfDay;
  return repo.getTotals(today, today);
});

/// Entries for a specific activity
final activityEntriesProvider = FutureProvider.family<List<TimeEntry>, String>((ref, activityId) {
  return ref.watch(timeEntriesRepositoryProvider).getEntries(activityId);
});

/// Stats for a specific activity: {period: totalMinutes}
final activityStatsProvider = FutureProvider.family<Map<String, int>, String>((ref, activityId) async {
  final repo = ref.watch(timeEntriesRepositoryProvider);
  final now = DateTime.now();
  final today = now.startOfDay;
  final yesterday = today.subtract(const Duration(days: 1));
  final weekStart = now.startOfWeek;
  final monthStart = now.startOfMonth;
  final yearStart = now.startOfYear;
  final allTimeStart = DateTime(2020);

  final results = await Future.wait([
    repo.getActivityTotal(activityId, today, today),
    repo.getActivityTotal(activityId, yesterday, yesterday),
    repo.getActivityTotal(activityId, weekStart, today),
    repo.getActivityTotal(activityId, monthStart, today),
    repo.getActivityTotal(activityId, yearStart, today),
    repo.getActivityTotal(activityId, allTimeStart, today),
  ]);

  return {
    'Today': results[0],
    'Yesterday': results[1],
    'This week': results[2],
    'This month': results[3],
    'This year': results[4],
    'All time': results[5],
  };
});
