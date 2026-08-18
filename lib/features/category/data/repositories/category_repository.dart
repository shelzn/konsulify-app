import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/category_model.dart';

class CategoryRepository {
  CategoryRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<CategoryModel>> list() async {
    final response = await _apiClient.get(ApiEndpoints.categories);
    final data = response['data'] as List<dynamic>;
    return data
        .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(ref.watch(apiClientProvider));
});
