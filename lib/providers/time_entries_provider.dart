import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/extensions.dart';
import '../models/entry_sort.dart';
import '../models/stat_period.dart';
import '../models/time_entry.dart';
import '../repositories/time_entries_repository.dart';
import 'auth_provider.dart';

final timeEntriesRepositoryProvider = Provider<TimeEntriesRepository>(
  (ref) => TimeEntriesRepository(ref.watch(supabaseClientProvider)),
);

/// Today's totals: map of activityId to (time, count)
final todayTotalsProvider = FutureProvider<Map<String, ({double time, double count})>>((ref) {
  final repo = ref.watch(timeEntriesRepositoryProvider);
  final now = DateTime.now();
  final today = now.startOfDay;
  return repo.getTotals(today, today);
});

/// Entries for a specific activity with sort
final activityEntriesProvider = FutureProvider.family<List<TimeEntry>, ({String activityId, EntrySort sort})>((ref, params) {
  return ref.watch(timeEntriesRepositoryProvider).getEntries(
    params.activityId,
    sort: params.sort,
  );
});

/// Stats for a specific activity: {StatPeriod: (time, count)}
final activityStatsProvider = FutureProvider.family<Map<StatPeriod, ({double time, double count})>, String>((ref, activityId) async {
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
    StatPeriod.today: results[0],
    StatPeriod.yesterday: results[1],
    StatPeriod.thisWeek: results[2],
    StatPeriod.thisMonth: results[3],
    StatPeriod.thisYear: results[4],
    StatPeriod.allTime: results[5],
  };
});

/// Subtree total for a parent activity (time + count separately)
final subtreeTotalProvider = FutureProvider.family<({double timeTotal, double countTotal}), ({String activityId, DateTime from, DateTime to})>((ref, params) {
  return ref.watch(timeEntriesRepositoryProvider).getSubtreeTotal(
    params.activityId,
    params.from,
    params.to,
  );
});
