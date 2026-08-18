import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../features/admin/presentation/pages/admin_master_page.dart';
import '../features/auth/presentation/pages/forgot_password_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/booking/presentation/pages/booking_create_page.dart';
import '../features/booking/presentation/pages/booking_history_page.dart';
import '../features/consultant/presentation/pages/consultant_detail_page.dart';
import '../features/consultant/presentation/pages/consultant_list_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final location = state.uri.path;
      final isAuthRoute = [
        '/login',
        '/register',
        '/forgot-password',
      ].contains(location);
      final isAdminRoute = location.startsWith('/admin');
      final isBookingCreate = location == '/bookings/create';

      if (!auth.hasCheckedSession) {
        return null;
      }

      if (!auth.isAuthenticated &&
          (isBookingCreate || location == '/bookings' || isAdminRoute)) {
        return '/login';
      }

      if (auth.isAuthenticated && isAuthRoute) {
        return auth.isAdmin ? '/admin' : '/user/home';
      }

      if (auth.isAuthenticated && isAdminRoute && !auth.isAdmin) {
        return '/user/home';
      }

      if (auth.isAuthenticated && auth.isAdmin && location == '/') {
        return '/admin';
      }

      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) => UserShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomePage()),
          GoRoute(
            path: '/user/home',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/consultants',
            builder: (context, state) => const ConsultantListPage(),
          ),
          GoRoute(
            path: '/bookings',
            builder: (context, state) => const BookingHistoryPage(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/consultants/:id',
        builder: (context, state) =>
            ConsultantDetailPage(id: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/bookings/create',
        builder: (context, state) {
          final consultantId = int.tryParse(
            state.uri.queryParameters['consultantId'] ?? '',
          );
          return BookingCreatePage(initialConsultantId: consultantId);
        },
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardPage(),
      ),
      GoRoute(
        path: '/admin/:resource',
        builder: (context, state) =>
            AdminMasterPage(resource: state.pathParameters['resource']!),
      ),
    ],
  );
});

class UserShell extends StatelessWidget {
  const UserShell({super.key, required this.child});

  final Widget child;

  int _indexFor(String path) {
    if (path.startsWith('/consultants')) return 1;
    if (path.startsWith('/bookings')) return 2;
    if (path.startsWith('/profile')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indexFor(path),
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/user/home');
            case 1:
              context.go('/consultants');
            case 2:
              context.go('/bookings');
            case 3:
              context.go('/profile');
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Konsultan',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Booking',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
