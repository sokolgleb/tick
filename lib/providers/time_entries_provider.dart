import 'package:flutter/material.dart';
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

/// Increment to trigger refresh of all time-entry stats providers globally
final timeEntriesVersionProvider = StateProvider<int>((ref) => 0);

/// Selected period on home screen
final homeSelectedPeriodProvider = StateProvider<StatPeriod>((ref) => StatPeriod.allTime);

/// Custom date range for home screen (when period == custom)
final homeCustomRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

/// Resolves a StatPeriod enum to (from, to) dates
({DateTime from, DateTime to}) periodToDateRange(StatPeriod period, {DateTimeRange? customRange}) {
  final now = DateTime.now();
  final today = now.startOfDay;

  switch (period) {
    case StatPeriod.today:
      return (from: today, to: today);
    case StatPeriod.yesterday:
      final yesterday = today.subtract(const Duration(days: 1));
      return (from: yesterday, to: yesterday);
    case StatPeriod.thisWeek:
      return (from: now.startOfWeek, to: today);
    case StatPeriod.thisMonth:
      return (from: now.startOfMonth, to: today);
    case StatPeriod.thisYear:
      return (from: now.startOfYear, to: today);
    case StatPeriod.allTime:
      return (from: DateTime(2020), to: today);
    case StatPeriod.custom:
      if (customRange != null) {
        return (from: customRange.start.startOfDay, to: customRange.end.startOfDay);
      }
      return (from: DateTime(2020), to: today);
  }
}

/// Today's totals: map of activityId to (time, count)
final todayTotalsProvider = FutureProvider<Map<String, ({double time, double count})>>((ref) {
  ref.watch(timeEntriesVersionProvider);
  final repo = ref.watch(timeEntriesRepositoryProvider);
  final now = DateTime.now();
  final today = now.startOfDay;
  return repo.getTotals(today, today);
});

/// Home screen totals: reactive to selected period + custom range
final homeTotalsProvider = FutureProvider<Map<String, ({double time, double count})>>((ref) {
  ref.watch(timeEntriesVersionProvider);
  final repo = ref.watch(timeEntriesRepositoryProvider);
  final period = ref.watch(homeSelectedPeriodProvider);
  final customRange = ref.watch(homeCustomRangeProvider);
  final range = periodToDateRange(period, customRange: customRange);
  return repo.getTotals(range.from, range.to);
});

/// Home screen subtree totals per activity: includes children
final homeSubtreeTotalsProvider = FutureProvider.family<
    ({double time, double count}),
    String>((ref, activityId) {
  ref.watch(timeEntriesVersionProvider);
  final repo = ref.watch(timeEntriesRepositoryProvider);
  final period = ref.watch(homeSelectedPeriodProvider);
  final customRange = ref.watch(homeCustomRangeProvider);
  final range = periodToDateRange(period, customRange: customRange);
  return repo.getSubtreeTotal(activityId, range.from, range.to).then(
    (r) => (time: r.timeTotal, count: r.countTotal),
  );
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
  ref.watch(timeEntriesVersionProvider);
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

/// Subtree stats for a parent activity (includes children), reactive to custom range
final activitySubtreeStatsProvider = FutureProvider.family<
    Map<StatPeriod, ({double time, double count})>,
    ({String activityId, DateTimeRange? customRange})>((ref, params) async {
  ref.watch(timeEntriesVersionProvider);
  final repo = ref.watch(timeEntriesRepositoryProvider);
  final now = DateTime.now();
  final today = now.startOfDay;
  final yesterday = today.subtract(const Duration(days: 1));
  final weekStart = now.startOfWeek;
  final monthStart = now.startOfMonth;
  final yearStart = now.startOfYear;
  final allTimeStart = DateTime(2020);

  final futures = <Future<({double timeTotal, double countTotal})>>[
    repo.getSubtreeTotal(params.activityId, today, today),
    repo.getSubtreeTotal(params.activityId, yesterday, yesterday),
    repo.getSubtreeTotal(params.activityId, weekStart, today),
    repo.getSubtreeTotal(params.activityId, monthStart, today),
    repo.getSubtreeTotal(params.activityId, yearStart, today),
    repo.getSubtreeTotal(params.activityId, allTimeStart, today),
  ];

  if (params.customRange != null) {
    final cr = params.customRange!;
    futures.add(repo.getSubtreeTotal(
      params.activityId,
      cr.start.startOfDay,
      cr.end.startOfDay,
    ));
  }

  final results = await Future.wait(futures);

  final map = <StatPeriod, ({double time, double count})>{
    StatPeriod.today: (time: results[0].timeTotal, count: results[0].countTotal),
    StatPeriod.yesterday: (time: results[1].timeTotal, count: results[1].countTotal),
    StatPeriod.thisWeek: (time: results[2].timeTotal, count: results[2].countTotal),
    StatPeriod.thisMonth: (time: results[3].timeTotal, count: results[3].countTotal),
    StatPeriod.thisYear: (time: results[4].timeTotal, count: results[4].countTotal),
    StatPeriod.allTime: (time: results[5].timeTotal, count: results[5].countTotal),
  };

  if (params.customRange != null) {
    map[StatPeriod.custom] = (time: results[6].timeTotal, count: results[6].countTotal);
  }

  return map;
});

/// Subtree total for a parent activity (time + count separately)
final subtreeTotalProvider = FutureProvider.family<({double timeTotal, double countTotal}), ({String activityId, DateTime from, DateTime to})>((ref, params) {
  return ref.watch(timeEntriesRepositoryProvider).getSubtreeTotal(
    params.activityId,
    params.from,
    params.to,
  );
});
