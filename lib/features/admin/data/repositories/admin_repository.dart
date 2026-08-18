import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';

class AdminDashboardData {
  const AdminDashboardData({
    required this.summary,
    required this.latestBookings,
  });

  final Map<String, dynamic> summary;
  final List<Map<String, dynamic>> latestBookings;

  factory AdminDashboardData.fromJson(Map<String, dynamic> json) {
    return AdminDashboardData(
      summary: Map<String, dynamic>.from(json['summary'] as Map),
      latestBookings: (json['latestBookings'] as List<dynamic>)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(),
    );
  }
}

class AdminListData {
  const AdminListData({required this.items, this.meta});

  final List<Map<String, dynamic>> items;
  final Map<String, dynamic>? meta;
}

class AdminRepository {
  AdminRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<AdminDashboardData> dashboard() async {
    final response = await _apiClient.get(ApiEndpoints.admin);
    return AdminDashboardData.fromJson(
      response['data'] as Map<String, dynamic>,
    );
  }

  Future<AdminListData> list(String resource, {String? search}) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.admin}/$resource',
      query: {if (search != null && search.isNotEmpty) 'search': search},
    );
    final data = response['data'] as List<dynamic>;
    return AdminListData(
      items: data
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(),
      meta: response['meta'] == null
          ? null
          : Map<String, dynamic>.from(response['meta'] as Map),
    );
  }

  Future<void> delete(String resource, int id) async {
    await _apiClient.delete('${ApiEndpoints.admin}/$resource/$id');
  }

  Future<void> updateBookingStatus(int id, String status) async {
    await _apiClient.patch(
      '${ApiEndpoints.admin}/bookings/$id/status',
      data: {'status': status},
    );
  }
}

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(ref.watch(apiClientProvider));
});
