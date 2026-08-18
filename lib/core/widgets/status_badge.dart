import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'confirmed' || 'available' => const Color(0xFF16A34A),
      'completed' => const Color(0xFF2563EB),
      'cancelled' || 'unavailable' => const Color(0xFFDC2626),
      'booked' => const Color(0xFF7C3AED),
      _ => const Color(0xFFF59E0B),
    };
    final label = switch (status) {
      'pending' => 'Menunggu',
      'confirmed' => 'Dikonfirmasi',
      'completed' => 'Selesai',
      'cancelled' => 'Dibatalkan',
      'available' => 'Tersedia',
      'booked' => 'Dipesan',
      'unavailable' => 'Tidak Tersedia',
      _ => status,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
