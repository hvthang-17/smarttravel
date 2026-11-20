import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarttravel_mobile/core/network/api_client.dart';
import 'package:smarttravel_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:smarttravel_mobile/features/itinerary/data/models/itinerary_model.dart';
import 'package:smarttravel_mobile/features/itinerary/data/models/trip_management_models.dart';

final itineraryRepositoryProvider = Provider<ItineraryRepository>((ref) {
  final token = ref.watch(authNotifierProvider.select((session) => session.token));
  return ItineraryRepository(ref.read(dioProvider), sessionToken: token);
});

class ItineraryConflictException implements Exception {
  const ItineraryConflictException();
  @override
  String toString() => 'Lịch trình đã thay đổi trên máy chủ. Bản sửa của bạn vẫn được giữ.';
}

class ItineraryRepository {
  final Dio dio;
  final String? sessionToken;
  List<ItineraryResponseModel>? _savedTrips;
  final _savedDetails = <int, ItineraryResponseModel>{};
  final _cachedTripReads = <int>{};
  final _tripPages = <(String, String, int), SavedTripPage>{};
  bool usedCachedList = false;

  ItineraryRepository(this.dio, {this.sessionToken});

  Options _privateOptions([String? method]) => Options(
    method: method,
    headers: {if (sessionToken != null) 'Authorization': 'Bearer $sessionToken'},
  );

  Future<SavedTripPage> getSavedPage(String search, String period, int page) async {
    final key = (search, period, page);
    try {
      final response = await dio.get<Map<String, dynamic>>('/itineraries/mine',
        options: _privateOptions(),
        queryParameters: {'search': search, 'period': period, 'page': page});
      final result = SavedTripPage.fromJson(response.data!['data'] as Map<String, dynamic>);
      _tripPages.remove(key);
      _tripPages[key] = result;
      if (_tripPages.length > 16) _tripPages.remove(_tripPages.keys.first);
      for (final trip in result.items) {
        _savedDetails[trip.id] = trip;
      }
      return result;
    } on DioException catch (error) {
      final cached = _tripPages[key];
      if (_allowsOfflineFallback(error) && cached != null) {
        return SavedTripPage(cached.items, cached.hasNext, cached.total, cached: true);
      }
      if ([401, 403].contains(error.response?.statusCode)) _tripPages.clear();
      throw Exception(_message(error, 'Không tải được danh sách chuyến đi.'));
    }
  }

  Future<ItineraryResponseModel> renameTrip(int id, String title) =>
      _changeTrip('PUT', '/itineraries/$id/title', data: {'title': title});

  Future<ItineraryResponseModel> copyTrip(int id) =>
      _changeTrip('POST', '/itineraries/$id/copy');

  Future<void> deleteTrip(int id) async {
    try {
      final response = await dio.delete<Map<String, dynamic>>('/itineraries/$id', options: _privateOptions());
      if (response.data?['success'] != true) throw StateError('Máy chủ chưa xác nhận đã xóa');
      _savedDetails.remove(id);
      _cachedTripReads.remove(id);
      _savedTrips = _savedTrips?.where((trip) => trip.id != id).toList();
      _tripPages.clear();
    } on DioException catch (error) {
      throw Exception(_message(error, 'Không thể xóa lịch trình.'));
    }
  }

  Future<ItineraryResponseModel> _changeTrip(String method, String path, {Object? data}) async {
    try {
      final response = await dio.request<Map<String, dynamic>>(path, data: data, options: _privateOptions(method));
      final body = response.data;
      if (body?['success'] != true) throw StateError('Máy chủ chưa xác nhận thay đổi');
      final trip = ItineraryResponseModel.fromJson(body!['data'] as Map<String, dynamic>);
      _rememberDetail(trip);
      _tripPages.clear();
      return trip;
    } on DioException catch (error) {
      throw Exception(_message(error, 'Không thể cập nhật lịch trình.'));
    }
  }

  String _message(DioException error, String fallback) {
    final body = error.response?.data;
    return body is Map && body['message'] is String ? body['message'] as String : fallback;
  }

  bool usedCachedTrip(int id) => _cachedTripReads.contains(id);

  static bool _allowsOfflineFallback(DioException error) =>
      (error.response?.statusCode ?? 0) >= 500 ||
      (error.response == null &&
          error.type != DioExceptionType.cancel &&
          error.type != DioExceptionType.badCertificate);

  void _rememberDetail(ItineraryResponseModel trip) {
    if (trip.status != 'SAVED') return;
    _cachedTripReads.remove(trip.id);
    _savedDetails[trip.id] = trip;
    final trips = _savedTrips;
    if (trips == null) return;
    _savedTrips = List.unmodifiable(trips.any((saved) => saved.id == trip.id)
        ? trips.map((saved) => saved.id == trip.id ? trip : saved)
        : [trip, ...trips]);
  }

  Future<List<ItineraryResponseModel>> getDrafts(String token) async {
    final response = await dio.get<Map<String, dynamic>>('/itineraries/drafts',
      options: Options(headers: {'Authorization': 'Bearer $token'}));
    final items = response.data?['data'] as List<dynamic>?;
    if (items == null) throw const FormatException('Không đọc được bản nháp');
    return items.whereType<Map<String, dynamic>>().map(ItineraryResponseModel.fromJson).toList();
  }

  Future<ItineraryResponseModel> saveDraft(int id, String token) async {
    try {
      final response = await dio.put<Map<String, dynamic>>('/itineraries/$id/save',
        options: Options(headers: {'Authorization': 'Bearer $token'}));
      final item = response.data?['data'] as Map<String, dynamic>?;
      if (item == null || item['id'] != id || item['status'] != 'SAVED') {
        throw const FormatException('Máy chủ chưa xác nhận đã lưu lịch trình');
      }
      final trip = ItineraryResponseModel.fromJson(item);
      _rememberDetail(trip);
      _tripPages.clear();
      return trip;
    } on DioException catch (error) {
      final body = error.response?.data;
      throw Exception(body is Map ? body['message'] ?? 'Không thể lưu lịch trình' : 'Không thể kết nối máy chủ');
    }
  }

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
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Quá thời gian kết nối tới máy chủ. Vui lòng thử lại sau.');
      }
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('Không thể kết nối tới máy chủ backend. Vui lòng kiểm tra kết nối mạng.');
      }
      throw Exception('Lỗi kết nối máy chủ: ${e.message}');
    } catch (e) {
      throw Exception('Tạo lịch trình thất bại: ${e.toString()}');
    }
  }

  Future<List<ItineraryResponseModel>> getMyItineraries() async {
    usedCachedList = false;
    try {
      final response = await dio.get<Map<String, dynamic>>('/itineraries');
      final responseData = response.data;
      if (responseData != null && responseData['data'] != null) {
        final list = responseData['data'] as List<dynamic>;
        final trips = list
            .map((item) => ItineraryResponseModel.fromJson(item as Map<String, dynamic>))
            .toList();
        _savedTrips = List.unmodifiable(trips.where((trip) => trip.status == 'SAVED'));
        _savedDetails
          ..clear()
          ..addEntries(_savedTrips!.map((trip) => MapEntry(trip.id, trip)));
        return trips;
      }
      return [];
    } on DioException catch (e) {
      if (_allowsOfflineFallback(e) && _savedTrips != null) {
        usedCachedList = true;
        return _savedTrips!;
      }
      if ([401, 403].contains(e.response?.statusCode)) {
        _savedTrips = null;
        _savedDetails.clear();
        _cachedTripReads.clear();
      }
      final errData = e.response?.data;
      if (errData is Map && errData['message'] != null) {
        throw Exception(errData['message']);
      }
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw Exception('Phiên đăng nhập đã hết hạn hoặc chưa đăng nhập. Vui lòng đăng nhập lại.');
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Quá thời gian chờ phản hồi từ máy chủ (Timeout). Vui lòng kiểm tra kết nối mạng hoặc đảm bảo backend đang chạy.');
      }
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('Không thể kết nối tới máy chủ backend. Vui lòng kiểm tra mạng hoặc địa chỉ API.');
      }
      throw Exception('Lỗi kết nối máy chủ (${e.response?.statusCode ?? 'mạng'}): ${e.message}');
    } catch (e) {
      throw Exception('Không thể tải danh sách lịch trình: ${e.toString()}');
    }
  }

  Future<ItineraryResponseModel?> getItineraryById(int id) async {
    _cachedTripReads.remove(id);
    try {
      final response = await dio.get<Map<String, dynamic>>('/itineraries/$id');
      final responseData = response.data;
      if (responseData != null && responseData['data'] != null) {
        final trip = ItineraryResponseModel.fromJson(
          responseData['data'] as Map<String, dynamic>,
        );
        _rememberDetail(trip);
        return trip;
      }
      return null;
    } on DioException catch (e) {
      final saved = _savedDetails[id];
      if (_allowsOfflineFallback(e) && saved != null) {
        _cachedTripReads.add(id);
        return saved;
      }
      if ([401, 403, 404].contains(e.response?.statusCode)) {
        _savedDetails.remove(id);
        _savedTrips = _savedTrips?.where((trip) => trip.id != id).toList();
      }
      throw Exception('Không thể tải chi tiết lịch trình: ${e.toString()}');
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
        options: _privateOptions(),
      );
      final responseData = response.data;
      if (responseData != null && responseData['data'] != null) {
        final trip = ItineraryResponseModel.fromJson(
          responseData['data'] as Map<String, dynamic>,
        );
        _rememberDetail(trip);
        _tripPages.clear();
        return trip;
      }
      throw Exception('Không nhận được dữ liệu sau khi cập nhật');
    } on DioException catch (e) {
      final body = e.response?.data;
      final codes = body is Map ? body['errors'] : null;
      if (e.response?.statusCode == 409 &&
          (codes is! List || !codes.contains('ITINERARY_CONSTRAINT_CONFLICT'))) {
        throw const ItineraryConflictException();
      }
      throw Exception(e.response?.data is Map ? e.response?.data['message'] ?? 'Không thể lưu lịch trình' : 'Không thể kết nối máy chủ');
    } catch (e) {
      throw Exception('Cập nhật lịch trình thất bại: ${e.toString()}');
    }
  }

  Future<TripShareLink> shareStatus(int id) => _shareRequest(id, 'GET');
  Future<TripShareLink> shareItinerary(int id, {bool rotate = false}) =>
      _shareRequest(id, 'POST', rotate: rotate);
  Future<TripShareLink> revokeShare(int id) => _shareRequest(id, 'DELETE');

  Future<TripShareLink> _shareRequest(int id, String method, {bool rotate = false}) async {
    try {
      final response = await dio.request<Map<String, dynamic>>('/itineraries/$id/share',
        options: _privateOptions(method), queryParameters: {if (rotate) 'rotate': true});
      return TripShareLink.fromJson(response.data!['data'] as Map<String, dynamic>, dio.options.baseUrl);
    } on DioException catch (error) {
      throw Exception(_message(error, 'Không thể cập nhật liên kết chia sẻ.'));
    }
  }

  Future<SharedTrip> getSharedItinerary(String token) async {
    if (!RegExp(r'^(?:[0-9a-f]{16}|[0-9a-f]{32})$').hasMatch(token)) {
      throw const SharedTripUnavailable(expired: false);
    }
    try {
      final response = await dio.get<Map<String, dynamic>>('/itineraries/shared/$token');
      return SharedTrip.fromJson(response.data!['data'] as Map<String, dynamic>);
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if (status == 404 || status == 410) throw SharedTripUnavailable(expired: status == 410);
      throw Exception(_message(error, 'Không thể tải lịch trình được chia sẻ.'));
    }
  }
}
