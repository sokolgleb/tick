import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/activities_provider.dart';
import '../providers/time_entries_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authRepo = ref.watch(authRepositoryProvider);
    final user = authRepo.currentUser;
    final isAnonymous = authRepo.isAnonymous;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('Account', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isAnonymous ? Icons.person_outline : Icons.person,
                          color: const Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isAnonymous
                                    ? 'Anonymous account'
                                    : (user?.email ?? 'Signed in'),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              if (isAnonymous)
                                Text(
                                  'Link an account to keep your data across devices',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (isAnonymous)
                FilledButton(
                  onPressed: () => context.push('/auth'),
                  child: const Text('Link Account'),
                )
              else
                OutlinedButton(
                  onPressed: () => _signOut(context, ref),
                  child: const Text('Sign Out'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _signOut(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(authRepositoryProvider).signOut();
      await ref.read(authRepositoryProvider).signInAnonymously();
      ref.invalidate(activitiesProvider);
      ref.invalidate(todayTotalsProvider);
      if (context.mounted) context.go('/');
    }
  }
}
