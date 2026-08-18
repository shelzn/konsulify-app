import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../data/models/booking_model.dart';

class BookingCard extends StatelessWidget {
  const BookingCard({super.key, required this.booking});

  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    booking.bookingCode,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                StatusBadge(status: booking.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              booking.consultantName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              booking.serviceName,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (booking.consultationDate != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.schedule_outlined, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${booking.consultationDate} ${booking.startTime?.substring(0, 5) ?? ''} - ${booking.endTime?.substring(0, 5) ?? ''}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                formatRupiah(booking.price),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
