import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/activity_detail_screen.dart';
import '../screens/auth_screen.dart';
import '../screens/settings_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/activity/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ActivityDetailScreen(activityId: id);
      },
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
