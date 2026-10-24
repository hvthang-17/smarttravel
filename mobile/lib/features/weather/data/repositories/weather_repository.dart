import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarttravel_mobile/core/network/api_client.dart';
import 'package:smarttravel_mobile/features/weather/data/models/weather_model.dart';

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return WeatherRepository(ref.read(dioProvider));
});

class WeatherRepository {
  final Dio _dio;
  final Dio _directDio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 4),
      receiveTimeout: const Duration(seconds: 4),
    ),
  );

  WeatherRepository(this._dio);

  Future<WeatherData> getDaNangWeather({double? lat, double? lon}) async {
    final targetLat = lat ?? 16.0544;
    final targetLon = lon ?? 108.2022;

    // 1. Try backend API first with query parameters
    try {
      final queryParams = <String, dynamic>{};
      if (lat != null && lon != null) {
        queryParams['lat'] = lat;
        queryParams['lon'] = lon;
      }

      final response = await _dio.get<Map<String, dynamic>>(
        '/weather/current',
        queryParameters: queryParams,
      );
      final data = response.data;
      if (data != null && data['data'] != null) {
        final weather = WeatherData.fromJson(data['data'] as Map<String, dynamic>);
        return weather.copyWith(isFromGps: lat != null && lon != null);
      }
    } catch (_) {
      // Backend not running or unreachable, fall through to direct API
    }

    // 2. Direct fallback to Open-Meteo with exact coordinates
    try {
      final openMeteoUrl =
          'https://api.open-meteo.com/v1/forecast?latitude=$targetLat&longitude=$targetLon&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,weather_code,wind_speed_10m&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max&timezone=Asia%2FBangkok';

      final directResponse = await _directDio.get<Map<String, dynamic>>(openMeteoUrl);
      if (directResponse.data != null) {
        final weather = WeatherData.fromOpenMeteoJson(
          directResponse.data!,
          locationName: _resolveLocationName(targetLat, targetLon),
        );
        return weather.copyWith(isFromGps: lat != null && lon != null);
      }
    } catch (_) {
      // Offline fallback
    }

    // 3. Resilient offline fallback
    return WeatherData.fallback(isFromGps: lat != null && lon != null);
  }

  static String _resolveLocationName(double lat, double lon) {
    if ((lat - 15.9988).abs() < 0.05 && (lon - 107.9880).abs() < 0.05) {
      return 'Bà Nà Hills, Đà Nẵng';
    }
    if ((lat - 16.1150).abs() < 0.04 && (lon - 108.2750).abs() < 0.04) {
      return 'Bán đảo Sơn Trà, Đà Nẵng';
    }
    if ((lat - 16.0590).abs() < 0.03 && (lon - 108.2430).abs() < 0.03) {
      return 'Biển Mỹ Khê, Đà Nẵng';
    }
    if ((lat - 16.0040).abs() < 0.03 && (lon - 108.2630).abs() < 0.03) {
      return 'Ngũ Hành Sơn, Đà Nẵng';
    }
    return 'Đà Nẵng';
  }
}
