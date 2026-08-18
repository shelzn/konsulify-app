import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/booking_model.dart';

class BookingRepository {
  BookingRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<BookingModel>> listMine({String? status}) async {
    final response = await _apiClient.get(
      ApiEndpoints.bookings,
      query: {if (status != null && status != 'all') 'status': status},
    );
    final data = response['data'] as List<dynamic>;
    return data
        .map((item) => BookingModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<BookingModel> create({
    required int consultantId,
    required int serviceId,
    required int scheduleId,
    required String customerName,
    required String customerPhone,
    required String complaint,
    String? notes,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.bookings,
      data: {
        'consultantId': consultantId,
        'serviceId': serviceId,
        'scheduleId': scheduleId,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'complaint': complaint,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );
    return BookingModel.fromJson(response['data'] as Map<String, dynamic>);
  }
}

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository(ref.watch(apiClientProvider));
});
