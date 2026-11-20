import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarttravel_mobile/core/network/api_client.dart';
import '../models/weather_model.dart';

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return WeatherRepository(ref.read(dioProvider));
});

class WeatherRepository {
  final Dio _dio;
  WeatherRepository(this._dio);

  Future<WeatherData> getDaNangWeather({double? lat, double? lon, String locale = 'vi'}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/weather/current', queryParameters: {
        'timezone': 'Asia/Ho_Chi_Minh',
        'locale': locale,
        if (lat != null && lon != null) ...{'lat': lat, 'lon': lon},
      });
      final data = response.data?['data'];
      if (data is Map<String, dynamic>) {
        return WeatherData.fromJson(data, isFromGps: lat != null && lon != null);
      }
    } catch (_) {
      return const WeatherData.unavailable();
    }
    return const WeatherData.unavailable();
  }
}
