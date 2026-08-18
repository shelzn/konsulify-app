import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/booking_model.dart';
import '../../data/repositories/booking_repository.dart';

final bookingListProvider = FutureProvider<List<BookingModel>>((ref) {
  return ref.watch(bookingRepositoryProvider).listMine();
});

class BookingCreateState {
  const BookingCreateState({this.isSubmitting = false});

  final bool isSubmitting;
}

class BookingCreateController extends Notifier<BookingCreateState> {
  @override
  BookingCreateState build() => const BookingCreateState();

  Future<BookingModel> create({
    required int consultantId,
    required int serviceId,
    required int scheduleId,
    required String customerName,
    required String customerPhone,
    required String complaint,
    String? notes,
  }) async {
    state = const BookingCreateState(isSubmitting: true);
    try {
      final booking = await ref
          .read(bookingRepositoryProvider)
          .create(
            consultantId: consultantId,
            serviceId: serviceId,
            scheduleId: scheduleId,
            customerName: customerName,
            customerPhone: customerPhone,
            complaint: complaint,
            notes: notes,
          );
      ref.invalidate(bookingListProvider);
      state = const BookingCreateState();
      return booking;
    } catch (_) {
      state = const BookingCreateState();
      rethrow;
    }
  }
}

final bookingCreateProvider =
    NotifierProvider<BookingCreateController, BookingCreateState>(
      BookingCreateController.new,
    );
