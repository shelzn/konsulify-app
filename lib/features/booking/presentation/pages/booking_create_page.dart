import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_state_widgets.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../consultant/data/models/consultant_model.dart';
import '../../../consultant/presentation/providers/consultant_provider.dart';
import '../../../schedule/data/models/schedule_model.dart';
import '../../../schedule/presentation/providers/schedule_provider.dart';
import '../../../service/data/models/service_model.dart';
import '../../../service/presentation/providers/service_provider.dart';
import '../providers/booking_provider.dart';

class BookingCreatePage extends ConsumerStatefulWidget {
  const BookingCreatePage({super.key, this.initialConsultantId});

  final int? initialConsultantId;

  @override
  ConsumerState<BookingCreatePage> createState() => _BookingCreatePageState();
}

class _BookingCreatePageState extends ConsumerState<BookingCreatePage> {
  int? consultantId;
  int? serviceId;
  int? scheduleId;
  final customerNameController = TextEditingController();
  final customerPhoneController = TextEditingController();
  final complaintController = TextEditingController();
  final notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    consultantId = widget.initialConsultantId;
    final user = ref.read(authProvider).user;
    customerNameController.text = user?.name ?? '';
    customerPhoneController.text = user?.phone ?? '';
  }

  @override
  void dispose() {
    customerNameController.dispose();
    customerPhoneController.dispose();
    complaintController.dispose();
    notesController.dispose();
    super.dispose();
  }

  void _setConsultant(int? value) {
    setState(() {
      consultantId = value;
      serviceId = null;
      scheduleId = null;
    });
  }

  Future<void> _submit() async {
    final selectedConsultantId = consultantId;
    final selectedServiceId = serviceId;
    final selectedScheduleId = scheduleId;

    if (selectedConsultantId == null ||
        selectedServiceId == null ||
        selectedScheduleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Pilih konsultan, layanan, dan jadwal terlebih dahulu.',
          ),
        ),
      );
      return;
    }

    if (customerNameController.text.trim().isEmpty ||
        customerPhoneController.text.trim().isEmpty ||
        complaintController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama, no HP, dan keluhan wajib diisi.')),
      );
      return;
    }

    try {
      final booking = await ref
          .read(bookingCreateProvider.notifier)
          .create(
            consultantId: selectedConsultantId,
            serviceId: selectedServiceId,
            scheduleId: selectedScheduleId,
            customerName: customerNameController.text.trim(),
            customerPhone: customerPhoneController.text.trim(),
            complaint: complaintController.text.trim(),
            notes: notesController.text.trim(),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking ${booking.bookingCode} berhasil dibuat.'),
        ),
      );
      context.go('/bookings');
    } on AppException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final consultants = ref.watch(consultantListProvider);
    final selectedConsultantId = consultantId;
    final services = selectedConsultantId == null
        ? null
        : ref.watch(serviceProvider(selectedConsultantId));
    final schedules = selectedConsultantId == null
        ? null
        : ref.watch(scheduleProvider(selectedConsultantId));
    final createState = ref.watch(bookingCreateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Buat Booking')),
      body: consultants.when(
        data: (consultantItems) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _SectionTitle(title: 'Pilih Konsultan'),
            DropdownButtonFormField<int>(
              initialValue:
                  consultantItems.any((item) => item.id == consultantId)
                  ? consultantId
                  : null,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.people_outline),
              ),
              hint: const Text('Pilih Konsultan'),
              items: consultantItems.map(_consultantMenuItem).toList(),
              onChanged: _setConsultant,
            ),
            const SizedBox(height: 20),
            _SectionTitle(title: 'Pilih Layanan'),
            if (services == null)
              const _MutedBox(message: 'Pilih konsultan terlebih dahulu.')
            else
              services.when(
                data: (items) => DropdownButtonFormField<int>(
                  initialValue: items.any((item) => item.id == serviceId)
                      ? serviceId
                      : null,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.medical_services_outlined),
                  ),
                  hint: const Text('Pilih Layanan'),
                  items: items.map(_serviceMenuItem).toList(),
                  onChanged: (value) => setState(() => serviceId = value),
                ),
                error: (error, _) => AppErrorState(
                  message: error.toString(),
                  onRetry: () =>
                      ref.invalidate(serviceProvider(selectedConsultantId!)),
                ),
                loading: () => const SizedBox(height: 72, child: AppLoading()),
              ),
            const SizedBox(height: 20),
            _SectionTitle(title: 'Pilih Jadwal'),
            if (schedules == null)
              const _MutedBox(message: 'Pilih konsultan terlebih dahulu.')
            else
              schedules.when(
                data: (items) => DropdownButtonFormField<int>(
                  initialValue: items.any((item) => item.id == scheduleId)
                      ? scheduleId
                      : null,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.calendar_month_outlined),
                  ),
                  hint: const Text('Pilih Jadwal'),
                  items: items.map(_scheduleMenuItem).toList(),
                  onChanged: (value) => setState(() => scheduleId = value),
                ),
                error: (error, _) => AppErrorState(
                  message: error.toString(),
                  onRetry: () =>
                      ref.invalidate(scheduleProvider(selectedConsultantId!)),
                ),
                loading: () => const SizedBox(height: 72, child: AppLoading()),
              ),
            const SizedBox(height: 20),
            _SectionTitle(title: 'Data Customer'),
            AppTextField(
              label: 'Nama Customer',
              controller: customerNameController,
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'No HP',
              controller: customerPhoneController,
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Keluhan',
              controller: complaintController,
              prefixIcon: Icons.notes_outlined,
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Catatan',
              controller: notesController,
              prefixIcon: Icons.edit_note_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            AppButton(
              label: 'Booking Sekarang',
              icon: Icons.check_circle_outline,
              onPressed: _submit,
              isLoading: createState.isSubmitting,
            ),
          ],
        ),
        error: (error, _) => AppErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(consultantListProvider),
        ),
        loading: () => const AppLoading(),
      ),
    );
  }

  DropdownMenuItem<int> _consultantMenuItem(ConsultantModel item) {
    return DropdownMenuItem<int>(
      value: item.id,
      child: Text(item.name, overflow: TextOverflow.ellipsis),
    );
  }

  DropdownMenuItem<int> _serviceMenuItem(ServiceModel item) {
    return DropdownMenuItem<int>(
      value: item.id,
      child: Text(
        '${item.name} - ${formatRupiah(item.price)}',
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  DropdownMenuItem<int> _scheduleMenuItem(ScheduleModel item) {
    return DropdownMenuItem<int>(
      value: item.id,
      child: Text(
        '${item.date} | ${item.startTime.substring(0, 5)} - ${item.endTime.substring(0, 5)}',
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}

class _MutedBox extends StatelessWidget {
  const _MutedBox({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(padding: const EdgeInsets.all(14), child: Text(message)),
    );
  }
}
