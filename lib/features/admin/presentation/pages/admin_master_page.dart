import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/app_state_widgets.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../data/repositories/admin_repository.dart';
import '../providers/admin_provider.dart';

class AdminMasterPage extends ConsumerWidget {
  const AdminMasterPage({super.key, required this.resource});

  final String resource;

  String get title => switch (resource) {
    'categories' => 'Kategori',
    'consultants' => 'Konsultan',
    'services' => 'Layanan',
    'schedules' => 'Jadwal',
    'bookings' => 'Booking',
    'users' => 'Pengguna',
    _ => resource,
  };

  String get description => switch (resource) {
    'categories' => 'Kelola topik konsultasi yang tampil di katalog pengguna.',
    'consultants' =>
      'Kelola profil konsultan, spesialisasi, dan status tampil.',
    'services' => 'Kelola paket layanan, durasi, dan harga konsultasi.',
    'schedules' => 'Kelola jadwal yang dapat dipilih saat booking.',
    'bookings' =>
      'Pantau transaksi booking dan ubah status sesuai proses layanan.',
    'users' => 'Lihat akun pengguna yang terdaftar di Konsulify.',
    _ => 'Kelola data Konsulify.',
  };

  bool get canDelete =>
      ['categories', 'consultants', 'services', 'schedules'].contains(resource);
  bool get canCreate => canDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(adminListProvider(resource));

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      floatingActionButton: canCreate
          ? FloatingActionButton.extended(
              onPressed: () => _showNotReady(context),
              icon: const Icon(Icons.add),
              label: const Text('Tambah'),
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(description, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 12),
                SearchBar(
                  hintText: 'Cari $title',
                  leading: const Icon(Icons.search),
                  onChanged: (value) =>
                      ref.read(adminSearchProvider(resource).notifier).state =
                          value,
                ),
              ],
            ),
          ),
          Expanded(
            child: list.when(
              data: (data) {
                if (data.items.isEmpty) {
                  return AppEmptyState(
                    title: 'Data kosong',
                    message: 'Belum ada data $title yang dapat ditampilkan.',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async =>
                      ref.invalidate(adminListProvider(resource)),
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      12,
                      20,
                      canCreate ? 88 : 20,
                    ),
                    itemBuilder: (context, index) => _AdminRow(
                      resource: resource,
                      item: data.items[index],
                      canDelete: canDelete,
                      onDelete: () =>
                          _confirmDelete(context, ref, data.items[index]),
                      onStatusChange: resource == 'bookings'
                          ? (status) => _updateBookingStatus(
                              context,
                              ref,
                              data.items[index],
                              status,
                            )
                          : null,
                    ),
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemCount: data.items.length,
                  ),
                );
              },
              error: (error, _) => AppErrorState(
                message: error.toString(),
                onRetry: () => ref.invalidate(adminListProvider(resource)),
              ),
              loading: () => const AppLoading(),
            ),
          ),
        ],
      ),
    );
  }

  void _showNotReady(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Form tambah/edit akan dibuat pada tahap berikutnya.'),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> item,
  ) async {
    final id = item['id'] as int?;
    if (id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Data'),
        content: const Text(
          'Data yang dihapus tidak dapat dikembalikan. Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);

    try {
      await ref.read(adminRepositoryProvider).delete(resource, id);
      ref.invalidate(adminListProvider(resource));
      messenger.showSnackBar(
        const SnackBar(content: Text('Data berhasil dihapus.')),
      );
    } on AppException catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _updateBookingStatus(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> item,
    String status,
  ) async {
    final id = item['id'] as int?;
    if (id == null) return;

    try {
      await ref.read(adminRepositoryProvider).updateBookingStatus(id, status);
      ref.invalidate(adminListProvider(resource));
      ref.invalidate(adminDashboardProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status booking berhasil diperbarui.')),
        );
      }
    } on AppException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }
}

class _AdminRow extends StatelessWidget {
  const _AdminRow({
    required this.resource,
    required this.item,
    required this.canDelete,
    required this.onDelete,
    this.onStatusChange,
  });

  final String resource;
  final Map<String, dynamic> item;
  final bool canDelete;
  final VoidCallback onDelete;
  final ValueChanged<String>? onStatusChange;

  @override
  Widget build(BuildContext context) {
    final status = item['status']?.toString();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primarySoft,
              foregroundColor: AppColors.primary,
              child: Text(_title.characters.first.toUpperCase()),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    _subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (status != null) ...[
                    const SizedBox(height: 8),
                    StatusBadge(status: status),
                  ],
                ],
              ),
            ),
            if (resource == 'bookings' && onStatusChange != null)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: onStatusChange,
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'pending', child: Text('Menunggu')),
                  PopupMenuItem(
                    value: 'confirmed',
                    child: Text('Dikonfirmasi'),
                  ),
                  PopupMenuItem(value: 'completed', child: Text('Selesai')),
                  PopupMenuItem(value: 'cancelled', child: Text('Dibatalkan')),
                ],
              )
            else if (canDelete)
              IconButton(
                tooltip: 'Hapus',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
              ),
          ],
        ),
      ),
    );
  }

  String get _title {
    return (item['name'] ??
            item['bookingCode'] ??
            item['email'] ??
            item['customerName'] ??
            'Data #${item['id']}')
        .toString();
  }

  String get _subtitle {
    final values = switch (resource) {
      'categories' => [
        item['description'],
        item['isActive'] == true ? 'Aktif' : 'Nonaktif',
      ],
      'consultants' => [item['specialization'], item['categoryName']],
      'services' => [item['consultantName'], 'Harga ${item['price']}'],
      'schedules' => [
        item['consultantName'],
        '${item['date']} ${item['startTime']} - ${item['endTime']}',
      ],
      'bookings' => [
        item['consultantName'],
        item['serviceName'],
        'Harga ${item['price']}',
      ],
      'users' => [item['email'], 'Role ${item['role']}'],
      _ =>
        item.entries
            .map((entry) => '${entry.key}: ${entry.value}')
            .take(2)
            .toList(),
    };

    return values
        .where((value) => value != null && value.toString().isNotEmpty)
        .join(' - ');
  }
}
