import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tick/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../core/preferences.dart';
import '../providers/auth_provider.dart';
import '../providers/activities_provider.dart';
import '../providers/preferences_provider.dart';
import '../providers/time_entries_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _supportedLocales = [
    (null, 'System'),
    (Locale('en'), 'English'),
    (Locale('ru'), 'Русский'),
    (Locale('it'), 'Italiano'),
    (Locale('tr'), 'Türkçe'),
    (Locale('es'), 'Español'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = S.of(context)!;
    final theme = Theme.of(context);
    final authRepo = ref.watch(authRepositoryProvider);
    final user = authRepo.currentUser;
    final isAnonymous = authRepo.isAnonymous;
    final themeMode = ref.watch(themeModeProvider);
    final viewMode = ref.watch(viewModeProvider);
    final locale = ref.watch(localeProvider);
    final coloredGrid = ref.watch(coloredGridProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Row(
          children: [
            GestureDetector(
              onTap: () => context.go('/'),
              child: Text(
                l10n.appTitle,
                style: theme.textTheme.titleLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '/',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ),
            ),
            Text(l10n.settings),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Account
              Text(l10n.account, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAnonymous
                                ? l10n.anonymousAccount
                                : (user?.email ?? l10n.signedIn),
                            style: theme.textTheme.titleMedium,
                          ),
                          if (isAnonymous)
                            Text(
                              l10n.linkAccountHint,
                              style: theme.textTheme.bodyMedium,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (isAnonymous)
                FilledButton(
                  onPressed: () => context.push('/auth'),
                  child: Text(l10n.linkAccount),
                ),

              const SizedBox(height: 28),

              // Appearance
              Text(l10n.appearance, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 12),

              // Theme
              _SettingsRow(
                label: l10n.theme,
                child: SegmentedButton<ThemeMode>(
                  segments: [
                    ButtonSegment(value: ThemeMode.system, label: Text(l10n.themeSystem)),
                    ButtonSegment(value: ThemeMode.light, label: Text(l10n.themeLight)),
                    ButtonSegment(value: ThemeMode.dark, label: Text(l10n.themeDark)),
                  ],
                  selected: {themeMode},
                  onSelectionChanged: (set) =>
                      ref.read(themeModeProvider.notifier).set(set.first),
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // View mode
              _SettingsRow(
                label: l10n.viewMode,
                child: SegmentedButton<ViewMode>(
                  segments: [
                    ButtonSegment(value: ViewMode.list, label: Text(l10n.viewList)),
                    ButtonSegment(value: ViewMode.grid, label: Text(l10n.viewGrid)),
                  ],
                  selected: {viewMode},
                  onSelectionChanged: (set) =>
                      ref.read(viewModeProvider.notifier).set(set.first),
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Colored grid
              _SettingsRow(
                label: l10n.coloredGrid,
                child: Switch(
                  value: coloredGrid,
                  onChanged: (value) =>
                      ref.read(coloredGridProvider.notifier).set(value),
                ),
              ),

              const SizedBox(height: 28),

              // Language
              Text(l10n.language, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 12),
              DropdownMenu<String>(
                initialSelection: locale?.languageCode ?? 'system',
                expandedInsets: EdgeInsets.zero,
                onSelected: (value) {
                  if (value == null) return;
                  final loc = value == 'system' ? null : Locale(value);
                  ref.read(localeProvider.notifier).set(loc);
                },
                dropdownMenuEntries: _supportedLocales.map((entry) {
                  final (loc, label) = entry;
                  return DropdownMenuEntry<String>(
                    value: loc?.languageCode ?? 'system',
                    label: label,
                  );
                }).toList(),
              ),

              if (!isAnonymous) ...[
                const SizedBox(height: 28),
                OutlinedButton(
                  onPressed: () => _signOut(context, ref),
                  child: Text(l10n.signOut),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => _deleteAccount(context, ref),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                  child: Text(l10n.deleteAccount),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _signOut(BuildContext context, WidgetRef ref) async {
    final l10n = S.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.signOutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.signOut),
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

  void _deleteAccount(BuildContext context, WidgetRef ref) async {
    final l10n = S.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteAccountConfirm),
        content: Text(l10n.deleteAccountWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(authRepositoryProvider).deleteAccount();
      await ref.read(authRepositoryProvider).signInAnonymously();
      ref.invalidate(activitiesProvider);
      ref.invalidate(todayTotalsProvider);
      if (context.mounted) context.go('/');
    }
  }
}

class _SettingsRow extends StatelessWidget {
  final String label;
  final Widget child;

  const _SettingsRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        child,
      ],
    );
  }
}
