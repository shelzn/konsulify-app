import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/schedule_model.dart';

class ScheduleRepository {
  ScheduleRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<ScheduleModel>> listByConsultant(int consultantId) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.consultants}/$consultantId/schedules',
    );
    final data = response['data'] as List<dynamic>;
    return data
        .map((item) => ScheduleModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  return ScheduleRepository(ref.watch(apiClientProvider));
});
