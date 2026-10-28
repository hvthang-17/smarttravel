import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarttravel_mobile/core/network/api_client.dart';
import 'package:smarttravel_mobile/features/itinerary/data/models/itinerary_model.dart';

final itineraryRepositoryProvider = Provider<ItineraryRepository>((ref) {
  return ItineraryRepository(ref.read(dioProvider));
});

class ItineraryRepository {
  final Dio dio;

  ItineraryRepository(this.dio);

  Future<ItineraryResponseModel> generateItinerary(ItineraryRequestModel request) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/itineraries/generate',
        data: request.toJson(),
      );

      final responseData = response.data;
      if (responseData != null && responseData['data'] != null) {
        return ItineraryResponseModel.fromJson(
          responseData['data'] as Map<String, dynamic>,
        );
      }
      throw Exception('Không nhận được dữ liệu lịch trình từ máy chủ');
    } on DioException catch (e) {
      final errData = e.response?.data;
      if (errData is Map && errData['message'] != null) {
        throw Exception(errData['message']);
      }
      if (e.response?.statusCode == 401) {
        throw Exception('Vui lòng đăng nhập để tạo lịch trình');
      }
      throw Exception('Lỗi kết nối máy chủ: ${e.message}');
    } catch (e) {
      throw Exception('Tạo lịch trình thất bại: ${e.toString()}');
    }
  }

  Future<List<ItineraryResponseModel>> getMyItineraries() async {
    try {
      final response = await dio.get<Map<String, dynamic>>('/itineraries');
      final responseData = response.data;
      if (responseData != null && responseData['data'] != null) {
        final list = responseData['data'] as List<dynamic>;
        return list
            .map((item) => ItineraryResponseModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Không thể tải danh sách lịch trình: ${e.toString()}');
    }
  }

  Future<ItineraryResponseModel?> getItineraryById(int id) async {
    try {
      final response = await dio.get<Map<String, dynamic>>('/itineraries/$id');
      final responseData = response.data;
      if (responseData != null && responseData['data'] != null) {
        return ItineraryResponseModel.fromJson(
          responseData['data'] as Map<String, dynamic>,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Không thể tải chi tiết lịch trình: ${e.toString()}');
    }
  }

  Future<ItineraryResponseModel> updateActivities(
      int id, UpdateActivitiesRequestModel request) async {
    try {
      final response = await dio.put<Map<String, dynamic>>(
        '/itineraries/$id/activities',
        data: request.toJson(),
      );
      final responseData = response.data;
      if (responseData != null && responseData['data'] != null) {
        return ItineraryResponseModel.fromJson(
          responseData['data'] as Map<String, dynamic>,
        );
      }
      throw Exception('Không nhận được dữ liệu sau khi cập nhật');
    } catch (e) {
      throw Exception('Cập nhật lịch trình thất bại: ${e.toString()}');
    }
  }

  Future<Map<String, String>> shareItinerary(int id) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/itineraries/$id/share',
      );
      final responseData = response.data;
      if (responseData != null && responseData['data'] != null) {
        final data = responseData['data'] as Map<String, dynamic>;
        return {
          'shareToken': data['shareToken'] as String? ?? '',
          'shareUrl': data['shareUrl'] as String? ?? '',
        };
      }
      throw Exception('Không thể tạo liên kết chia sẻ');
    } catch (e) {
      throw Exception('Chia sẻ lịch trình thất bại: ${e.toString()}');
    }
  }

  Future<ItineraryResponseModel?> getSharedItinerary(String shareToken) async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        '/itineraries/shared/$shareToken',
      );
      final responseData = response.data;
      if (responseData != null && responseData['data'] != null) {
        return ItineraryResponseModel.fromJson(
          responseData['data'] as Map<String, dynamic>,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Không thể tải lịch trình chia sẻ: ${e.toString()}');
    }
  }
}
