import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/consultant_model.dart';
import '../../data/repositories/consultant_repository.dart';

final consultantListProvider = FutureProvider<List<ConsultantModel>>((ref) {
  return ref.watch(consultantRepositoryProvider).list();
});

final consultantDetailProvider = FutureProvider.family<ConsultantModel, int>((
  ref,
  id,
) {
  return ref.watch(consultantRepositoryProvider).detail(id);
});
