import 'package:go_router/go_router.dart';
import 'auth_service.dart';
import '../screens/auth/login_screen.dart';
import '../screens/dashboard/admin_dashboard_screen.dart';
import '../screens/dashboard/engineer_dashboard.dart';
import '../screens/dashboard/worker_dashboard.dart';
import '../screens/greenhouse/greenhouse_details.dart';
import '../screens/greenhouse/temperature_detail_screen.dart';
import '../screens/greenhouse/humidity_detail_screen.dart';
import '../screens/greenhouse/light_detail_screen.dart';
import '../screens/greenhouse/irrigation_detail_screen.dart';
import '../screens/ai/ai_hub_screen.dart';
import '../screens/dashboard/alerts_screen.dart';
import '../screens/auth/pending_approval_screen.dart';
import '../screens/dashboard/crop_settings_screen.dart';
import '../screens/main_layout.dart';

class AppRouter {
  static GoRouter createRouter(AuthService authService) {
    return GoRouter(
      initialLocation: '/login',
      refreshListenable: authService,
      redirect: (context, state) {
        final isAuthenticated = authService.isAuthenticated;
        final isPending = authService.isPending;
        final isLoginRoute = state.matchedLocation == '/login';
        final isPendingRoute = state.matchedLocation == '/pending-approval';

        if (isPending && !isPendingRoute) {
          return '/pending-approval';
        }

        if (!isAuthenticated && !isPending) {
          return (isLoginRoute || isPendingRoute) ? null : '/login';
        }

        if (isAuthenticated && (isLoginRoute || isPendingRoute)) {
          // If logged in, redirect based on role
          switch (authService.currentUser?.role) {
            case UserRole.superAdmin:
              return '/super-admin';
            case UserRole.engineer:
              return '/engineer';
            case UserRole.worker:
              return '/worker';
            default:
              return '/login';
          }
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/pending-approval',
          builder: (context, state) => const PendingApprovalScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) {
            return MainLayout(child: child);
          },
          routes: [
            GoRoute(
              path: '/super-admin',
              builder: (context, state) => const AdminDashboardScreen(),
              routes: [
                GoRoute(
                  path: 'crops',
                  builder: (context, state) => const CropSettingsScreen(),
                ),
              ],
            ),
            GoRoute(
              path: '/engineer',
              builder: (context, state) => const EngineerDashboard(),
            ),
            GoRoute(
              path: '/worker',
              builder: (context, state) => const WorkerDashboard(),
            ),
            GoRoute(
              path: '/ai-hub',
              builder: (context, state) => const AiHubScreen(),
            ),
            GoRoute(
              path: '/alerts',
              builder: (context, state) => const AlertsScreen(),
            ),
            GoRoute(
              path: '/greenhouse/:id',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return GreenhouseDetailsScreen(greenhouseId: id);
              },
              routes: [
                GoRoute(
                  path: 'temperature',
                  builder: (context, state) {
                    final id = state.pathParameters['id']!;
                    return TemperatureDetailScreen(greenhouseId: id);
                  },
                ),
                GoRoute(
                  path: 'humidity',
                  builder: (context, state) {
                    final id = state.pathParameters['id']!;
                    return HumidityDetailScreen(greenhouseId: id);
                  },
                ),
                GoRoute(
                  path: 'light',
                  builder: (context, state) {
                    final id = state.pathParameters['id']!;
                    return LightDetailScreen(greenhouseId: id);
                  },
                ),
                GoRoute(
                  path: 'irrigation',
                  builder: (context, state) {
                    final id = state.pathParameters['id']!;
                    return IrrigationDetailScreen(greenhouseId: id);
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
