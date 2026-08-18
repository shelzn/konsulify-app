import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_state_widgets.dart';
import '../providers/booking_provider.dart';
import '../widgets/booking_card.dart';

class BookingHistoryPage extends ConsumerWidget {
  const BookingHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(bookingListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Saya'),
        actions: [
          IconButton(
            onPressed: () => context.go('/bookings/create'),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: bookings.when(
        data: (items) {
          if (items.isEmpty) {
            return const AppEmptyState(
              title: 'Belum ada booking',
              message: 'Booking konsultasi Anda akan tampil di sini.',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(bookingListProvider),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: items
                  .map((item) => BookingCard(booking: item))
                  .toList(),
            ),
          );
        },
        error: (error, _) => AppErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(bookingListProvider),
        ),
        loading: () => const AppLoading(),
      ),
    );
  }
}
