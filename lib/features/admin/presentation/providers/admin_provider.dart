import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../data/repositories/admin_repository.dart';

final adminDashboardProvider = FutureProvider<AdminDashboardData>((ref) {
  return ref.watch(adminRepositoryProvider).dashboard();
});

final adminSearchProvider = StateProvider.family<String, String>(
  (ref, resource) => '',
);

final adminListProvider = FutureProvider.family<AdminListData, String>((
  ref,
  resource,
) {
  final search = ref.watch(adminSearchProvider(resource));
  return ref.watch(adminRepositoryProvider).list(resource, search: search);
});
