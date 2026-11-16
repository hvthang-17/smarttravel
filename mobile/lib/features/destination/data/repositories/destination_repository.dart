import 'package:dio/dio.dart';
import 'package:smarttravel_mobile/core/network/api_client.dart';
import 'package:smarttravel_mobile/features/destination/data/models/destination_model.dart';
import 'package:smarttravel_mobile/core/utils/destination_categories.dart';
import '../models/discovery_models.dart';

class DestinationRepository {
  final ApiClient apiClient;

  DestinationRepository(this.apiClient);

  Future<DiscoveryPage> discover(DiscoveryQuery query) async {
    final response = await apiClient.dio.get<Map<String, dynamic>>('/destinations/discover', queryParameters: {
      if (query.search.isNotEmpty) 'search': query.search,
      if (query.category != null) 'category': query.category,
      if (query.minPrice != null) 'minPriceVnd': query.minPrice,
      if (query.maxPrice != null) 'maxPriceVnd': query.maxPrice,
      'page': query.page,
    });
    final data = response.data!['data'] as Map<String, dynamic>;
    return DiscoveryPage(_destinations(data['items']), data['hasNext'] == true);
  }

  Future<List<DestinationCategory>> categories() async {
    final response = await apiClient.dio.get<Map<String, dynamic>>('/categories', queryParameters: {'status': 'ACTIVE'});
    final rows = response.data!['data'] as List<dynamic>;
    return rows.whereType<Map<String, dynamic>>()
        .where((row) => row['status'] == 'ACTIVE' && destinationCategoryLabels.containsKey(row['code']))
        .map((row) => DestinationCategory(row['code'] as String, row['name'] as String, row['nameEn'] as String?))
        .toList();
  }

  Future<List<DestinationModel>> getFavorites(String token) async {
    final response = await apiClient.dio.get<Map<String, dynamic>>('/favorites', options: _session(token));
    return _destinations(response.data!['data']);
  }

  Future<DestinationModel> addFavorite(int id, String token) async {
    try {
      final response = await apiClient.dio.put<Map<String, dynamic>>('/favorites/$id', options: _session(token));
      return DestinationModel.fromJson(response.data!['data'] as Map<String, dynamic>);
    } on DioException catch (error) {
      throw Exception(_message(error, 'Không thể lưu địa điểm'));
    }
  }

  Future<void> removeFavorite(int id, String token) async {
    try {
      await apiClient.dio.delete<Map<String, dynamic>>('/favorites/$id', options: _session(token));
    } on DioException catch (error) {
      throw Exception(_message(error, 'Không thể bỏ lưu địa điểm'));
    }
  }

  Options _session(String token) => Options(headers: {'Authorization': 'Bearer $token'});

  List<DestinationModel> _destinations(Object? items) => (items as List<dynamic>)
      .map((item) => DestinationModel.fromJson(item as Map<String, dynamic>)).toList();

  String _message(DioException error, String fallback) {
    final body = error.response?.data;
    return body is Map && body['message'] is String ? body['message'] as String : fallback;
  }

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
    try {
      final response = await apiClient.dio.get<Map<String, dynamic>>('/destinations/discover/$id');
      return DestinationModel.fromJson(response.data!['data'] as Map<String, dynamic>);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) return null;
      rethrow;
    }
  }
}
