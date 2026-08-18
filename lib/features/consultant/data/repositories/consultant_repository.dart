import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/consultant_model.dart';

class ConsultantRepository {
  ConsultantRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<ConsultantModel>> list({String? search, int? categoryId}) async {
    final response = await _apiClient.get(
      ApiEndpoints.consultants,
      query: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (categoryId != null) 'category': categoryId,
      },
    );
    final data = response['data'] as List<dynamic>;
    return data
        .map((item) => ConsultantModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ConsultantModel> detail(int id) async {
    final response = await _apiClient.get('${ApiEndpoints.consultants}/$id');
    return ConsultantModel.fromJson(response['data'] as Map<String, dynamic>);
  }
}

final consultantRepositoryProvider = Provider<ConsultantRepository>((ref) {
  return ConsultantRepository(ref.watch(apiClientProvider));
});
