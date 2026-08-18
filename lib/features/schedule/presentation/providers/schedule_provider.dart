import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/schedule_model.dart';
import '../../data/repositories/schedule_repository.dart';

final scheduleProvider = FutureProvider.family<List<ScheduleModel>, int>((
  ref,
  consultantId,
) {
  return ref.watch(scheduleRepositoryProvider).listByConsultant(consultantId);
});
