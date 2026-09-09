import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/activities_provider.dart';
import '../providers/time_entries_provider.dart';
import '../widgets/anonymous_conflict_dialog.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text('Tick', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 8),
              Text(
                'Track your time, simply.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 40),
              FilledButton.icon(
                onPressed: _loading ? null : _signInWithGoogle,
                icon: const Icon(Icons.login),
                label: const Text('Sign in with Google'),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('or', style: Theme.of(context).textTheme.bodyMedium),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'Email'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(hintText: 'Password'),
                onSubmitted: (_) => _signInWithEmail(),
              ),
              const SizedBox(height: 16),
              if (_error != null) ...[
                Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 14)),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _loading ? null : _signUpWithEmail,
                      child: const Text('Sign up'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _loading ? null : _signInWithEmail,
                      child: const Text('Sign in'),
                    ),
                  ),
                ],
              ),
              if (_loading) ...[
                const SizedBox(height: 24),
                const Center(child: CircularProgressIndicator()),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() { _loading = true; _error = null; });
    try {
      final authRepo = ref.read(authRepositoryProvider);
      if (authRepo.isAnonymous) {
        try {
          await authRepo.linkWithGoogle();
          _onSuccess();
          return;
        } catch (_) {
          await _handleConflict(() => authRepo.signInWithGoogle());
        }
      } else {
        await authRepo.signInWithGoogle();
        _onSuccess();
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) return;

    setState(() { _loading = true; _error = null; });
    try {
      final authRepo = ref.read(authRepositoryProvider);
      if (authRepo.isAnonymous) {
        try {
          await authRepo.linkWithEmail(email, password);
          _onSuccess();
          return;
        } catch (_) {
          await _handleConflict(() => authRepo.signInWithEmail(email, password));
        }
      } else {
        await authRepo.signInWithEmail(email, password);
        _onSuccess();
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signUpWithEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) return;

    setState(() { _loading = true; _error = null; });
    try {
      final authRepo = ref.read(authRepositoryProvider);
      if (authRepo.isAnonymous) {
        await authRepo.linkWithEmail(email, password);
      } else {
        await authRepo.signUpWithEmail(email, password);
      }
      _onSuccess();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleConflict(Future<void> Function() signIn) async {
    final authRepo = ref.read(authRepositoryProvider);
    final hasData = await authRepo.hasData();

    if (!hasData) {
      await authRepo.signOut();
      await signIn();
      _onSuccess();
      return;
    }

    if (!mounted) return;

    final activities = ref.read(activitiesProvider).valueOrNull ?? [];
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AnonymousConflictDialog(activityCount: activities.length),
    );

    if (confirm == true) {
      await authRepo.deleteAnonymousData();
      await authRepo.signOut();
      await signIn();
      _onSuccess();
    }
  }

  void _onSuccess() {
    ref.invalidate(activitiesProvider);
    ref.invalidate(todayTotalsProvider);
    if (mounted) context.go('/');
  }
}
