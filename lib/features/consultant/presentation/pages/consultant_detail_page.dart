import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_state_widgets.dart';
import '../providers/consultant_provider.dart';

class ConsultantDetailPage extends ConsumerWidget {
  const ConsultantDetailPage({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consultant = ref.watch(consultantDetailProvider(id));

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Konsultan')),
      body: consultant.when(
        data: (item) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            CircleAvatar(
              radius: 42,
              child: Text(
                item.name.characters.first,
                style: const TextStyle(fontSize: 28),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${item.name}${item.title == null ? '' : ', ${item.title}'}',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(item.specialization, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tentang Konsultan',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.description ?? 'Informasi konsultan belum tersedia.',
                    ),
                    const SizedBox(height: 12),
                    Text('Pengalaman: ${item.experienceYears} tahun'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'Booking Sekarang',
              icon: Icons.calendar_month_outlined,
              onPressed: () =>
                  context.go('/bookings/create?consultantId=${item.id}'),
            ),
          ],
        ),
        error: (error, _) => AppErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(consultantDetailProvider(id)),
        ),
        loading: () => const AppLoading(),
      ),
    );
  }
}
