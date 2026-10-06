import 'package:smarttravel_mobile/core/network/api_client.dart';
import 'package:smarttravel_mobile/features/destination/data/models/destination_model.dart';

class DestinationRepository {
  final ApiClient apiClient;

  DestinationRepository(this.apiClient);

  Future<List<DestinationModel>> getDestinations({String? category}) async {
    final Map<String, dynamic> queryParams = {};
    if (category != null && category.isNotEmpty && category != 'Tất cả') {
      queryParams['category'] = category;
    }

    final response = await apiClient.dio.get<Map<String, dynamic>>(
      '/destinations',
      queryParameters: queryParams,
    );

    final responseData = response.data;
    if (response.statusCode == 200 && responseData != null) {
      final data = responseData['data'] as List<dynamic>? ?? [];
      return data
          .map((item) => DestinationModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<DestinationModel?> getDestinationById(int id) async {
    final response = await apiClient.dio.get<Map<String, dynamic>>('/destinations/$id');
    final responseData = response.data;
    if (response.statusCode == 200 && responseData != null) {
      final data = responseData['data'] as Map<String, dynamic>?;
      if (data != null) {
        return DestinationModel.fromJson(data);
      }
    }
    return null;
  }
}
