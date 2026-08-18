import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../core/widgets/app_state_widgets.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../category/presentation/providers/category_provider.dart';
import '../../../category/presentation/widgets/category_card.dart';
import '../../../consultant/presentation/providers/consultant_provider.dart';
import '../../../consultant/presentation/widgets/consultant_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final categories = ref.watch(categoryProvider);
    final consultants = ref.watch(consultantListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Konsulify'),
        actions: [
          if (!auth.isAuthenticated)
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('Masuk'),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(categoryProvider);
          ref.invalidate(consultantListProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _HomeHeader(
              name: auth.user?.name,
              onBooking: () => context.go('/bookings/create'),
            ),
            const SizedBox(height: 18),
            SearchBar(
              hintText: 'Cari Konsultan',
              leading: const Icon(Icons.search),
              onTap: () => context.go('/consultants'),
            ),
            const SizedBox(height: 24),
            const _SectionHeader(
              title: 'Kategori Konsultasi',
              subtitle: 'Pilih topik yang paling sesuai dengan kebutuhan Anda.',
            ),
            const SizedBox(height: 12),
            categories.when(
              data: (items) => items.isEmpty
                  ? const AppEmptyState(
                      title: 'Kategori belum tersedia',
                      message: 'Admin belum menambahkan kategori konsultasi.',
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: items
                            .map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: CategoryCard(category: item),
                              ),
                            )
                            .toList(),
                      ),
                    ),
              error: (error, _) => SizedBox(
                height: 180,
                child: AppErrorState(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(categoryProvider),
                ),
              ),
              loading: () => const SizedBox(height: 80, child: AppLoading()),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Expanded(
                  child: _SectionHeader(
                    title: 'Konsultan Pilihan',
                    subtitle:
                        'Rekomendasi konsultan aktif untuk konsultasi online.',
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/consultants'),
                  child: const Text('Lihat Semua'),
                ),
              ],
            ),
            consultants.when(
              data: (items) => items.isEmpty
                  ? const AppEmptyState(
                      title: 'Konsultan belum tersedia',
                      message:
                          'Katalog akan tampil setelah admin menambahkan konsultan.',
                    )
                  : Column(
                      children: items
                          .take(5)
                          .map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: ConsultantCard(consultant: item),
                            ),
                          )
                          .toList(),
                    ),
              error: (error, _) => AppErrorState(
                message: error.toString(),
                onRetry: () => ref.invalidate(consultantListProvider),
              ),
              loading: () => const SizedBox(height: 160, child: AppLoading()),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.name, required this.onBooking});

  final String? name;
  final VoidCallback onBooking;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, ${name ?? 'Selamat datang'}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Temukan konsultan, pilih jadwal, dan buat booking dalam beberapa langkah.',
              style: TextStyle(color: Color(0xFFEFF6FF), height: 1.4),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onBooking,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
              ),
              icon: const Icon(Icons.calendar_month_outlined),
              label: const Text('Mulai Booking'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
