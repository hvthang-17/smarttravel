import 'package:dio/dio.dart';
import '../models/destination_review.dart';

class DestinationReviewRepository {
  final Dio dio;
  DestinationReviewRepository(this.dio);

  Future<ReviewPage> list(int destination, int page) async {
    final data =
        await _request('GET', _path(destination), query: {'page': page});
    final result = data as Map<String, dynamic>;
    return (
      items: (result['items'] as List)
          .map((item) =>
              DestinationReview.fromJson(item as Map<String, dynamic>))
          .toList(),
      hasNext: result['hasNext'] == true,
    );
  }

  Future<DestinationReview?> mine(int destination, String token) async {
    final data =
        await _request('GET', '${_path(destination)}/mine', token: token);
    return data == null
        ? null
        : DestinationReview.fromJson(data as Map<String, dynamic>);
  }

  Future<void> save(int destination, String token, ReviewInput input,
      {required bool existing}) async {
    await _request(existing ? 'PUT' : 'POST',
        existing ? '${_path(destination)}/mine' : _path(destination),
        token: token, body: {'rating': input.rating, 'comment': input.comment});
  }

  Future<void> delete(int destination, String token) async {
    await _request('DELETE', '${_path(destination)}/mine', token: token);
  }

  Future<void> report(
      int destination, int review, String token, String reason) async {
    await _request('POST', '${_path(destination)}/$review/reports',
        token: token, body: {'reason': reason});
  }

  String _path(int id) => '/destinations/$id/reviews';

  Future<Object?> _request(String method, String path,
      {String? token,
      Map<String, Object?>? body,
      Map<String, Object>? query}) async {
    try {
      final result = await dio.request<Map<String, dynamic>>(path,
          data: body,
          queryParameters: query,
          options: Options(method: method, headers: {
            if (token != null) 'Authorization': 'Bearer $token',
          }));
      if (result.data?['success'] != true) {
        throw StateError('Máy chủ chưa xác nhận thao tác');
      }
      return result.data?['data'];
    } on DioException catch (error) {
      final data = error.response?.data;
      throw Exception(data is Map && data['message'] is String
          ? data['message']
          : 'Không thể kết nối. Hãy thử lại.');
    }
  }
}
