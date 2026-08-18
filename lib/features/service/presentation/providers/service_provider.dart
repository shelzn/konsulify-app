import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/service_model.dart';
import '../../data/repositories/service_repository.dart';

final serviceProvider = FutureProvider.family<List<ServiceModel>, int>((
  ref,
  consultantId,
) {
  return ref.watch(serviceRepositoryProvider).listByConsultant(consultantId);
});
