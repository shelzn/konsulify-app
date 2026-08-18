import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_state_widgets.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_menu_card.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(adminDashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dasbor Admin'),
        actions: [
          IconButton(
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          dashboard.when(
            data: (data) => _SummaryGrid(summary: data.summary),
            error: (error, _) => AppErrorState(
              message: error.toString(),
              onRetry: () => ref.invalidate(adminDashboardProvider),
            ),
            loading: () => const SizedBox(height: 140, child: AppLoading()),
          ),
          const SizedBox(height: 16),
          Text('Kelola Data', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Pantau transaksi dan kelola katalog layanan konsultasi.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          const AdminMenuCard(
            title: 'Kategori',
            icon: Icons.category_outlined,
            path: '/admin/categories',
          ),
          const AdminMenuCard(
            title: 'Konsultan',
            icon: Icons.people_outline,
            path: '/admin/consultants',
          ),
          const AdminMenuCard(
            title: 'Layanan',
            icon: Icons.medical_services_outlined,
            path: '/admin/services',
          ),
          const AdminMenuCard(
            title: 'Jadwal',
            icon: Icons.calendar_month_outlined,
            path: '/admin/schedules',
          ),
          const AdminMenuCard(
            title: 'Booking',
            icon: Icons.receipt_long_outlined,
            path: '/admin/bookings',
          ),
          const AdminMenuCard(
            title: 'Pengguna',
            icon: Icons.person_search_outlined,
            path: '/admin/users',
          ),
        ],
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.summary});

  final Map<String, dynamic> summary;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Pengguna', summary['totalUser']),
      ('Konsultan', summary['totalConsultant']),
      ('Layanan', summary['totalService']),
      ('Booking', summary['totalBooking']),
      ('Menunggu', summary['pendingBooking']),
      ('Selesai', summary['completedBooking']),
    ];

    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 2.5,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: items.map((item) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(item.$1, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(
                  '${item.$2 ?? 0}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
