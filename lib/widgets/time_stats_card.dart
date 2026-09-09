import 'package:flutter/material.dart';
import '../core/extensions.dart';

class TimeStatsCard extends StatelessWidget {
  final Map<String, int> stats;

  const TimeStatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: stats.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(entry.key, style: Theme.of(context).textTheme.bodyMedium),
              Text(
                entry.value.toTimeString(),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
