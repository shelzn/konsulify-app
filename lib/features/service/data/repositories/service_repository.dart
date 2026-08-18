import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/service_model.dart';

class ServiceRepository {
  ServiceRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<ServiceModel>> listByConsultant(int consultantId) async {
    final response = await _apiClient.get(
      ApiEndpoints.services,
      query: {'consultantId': consultantId},
    );
    final data = response['data'] as List<dynamic>;
    return data
        .map((item) => ServiceModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}

final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  return ServiceRepository(ref.watch(apiClientProvider));
});
