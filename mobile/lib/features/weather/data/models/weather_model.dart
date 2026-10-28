import 'package:flutter/material.dart';

class DailyForecast {
  final String date;
  final double minTemp;
  final double maxTemp;
  final int precipitationProbability;
  final int weatherCode;
  final String condition;
  final String icon;

  const DailyForecast({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.precipitationProbability,
    required this.weatherCode,
    required this.condition,
    required this.icon,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      date: json['date'] as String? ?? '',
      minTemp: (json['minTemp'] as num?)?.toDouble() ?? 24.0,
      maxTemp: (json['maxTemp'] as num?)?.toDouble() ?? 30.0,
      precipitationProbability: (json['precipitationProbability'] as num?)?.toInt() ?? 0,
      weatherCode: (json['weatherCode'] as num?)?.toInt() ?? 0,
      condition: json['condition'] as String? ?? 'Nắng ráo',
      icon: json['icon'] as String? ?? '🌤️',
    );
  }

  IconData get materialIcon {
    if (weatherCode == 0) return Icons.wb_sunny_rounded;
    if (weatherCode <= 2) return Icons.wb_sunny_outlined;
    if (weatherCode == 3) return Icons.cloud_outlined;
    if (weatherCode == 45 || weatherCode == 48) return Icons.foggy;
    if (weatherCode >= 51 && weatherCode <= 55) return Icons.grain;
    if (weatherCode >= 61 && weatherCode <= 65) return Icons.water_drop_outlined;
    if (weatherCode >= 80) return Icons.thunderstorm_outlined;
    return Icons.wb_sunny_outlined;
  }

  Color get materialIconColor {
    if (weatherCode <= 2) return const Color(0xFFF59E0B);
    if (weatherCode >= 51 && weatherCode <= 65) return const Color(0xFF0284C7);
    if (weatherCode >= 80) return const Color(0xFF4F46E5);
    return const Color(0xFF0284C7);
  }
}

class WeatherData {
  final String cityName;
  final double temperature;
  final double apparentTemperature;
  final int humidity;
  final double windSpeed;
  final double precipitation;
  final int weatherCode;
  final String condition;
  final String icon;
  final bool isDay;
  final String travelAdvice;
  final List<DailyForecast> dailyForecast;
  final String updatedAt;
  final bool isFromGps;

  const WeatherData({
    this.cityName = 'Đà Nẵng',
    required this.temperature,
    required this.apparentTemperature,
    required this.humidity,
    required this.windSpeed,
    required this.precipitation,
    required this.weatherCode,
    required this.condition,
    required this.icon,
    this.isDay = true,
    required this.travelAdvice,
    required this.dailyForecast,
    required this.updatedAt,
    this.isFromGps = false,
  });

  String get tempFormatted => '${temperature.round()}°C';
  String get apparentTempFormatted => '${apparentTemperature.round()}°C';
  String get pillText => '$tempFormatted • ${isFromGps ? cityName : 'Đà Nẵng'}';

  IconData get materialIcon {
    if (weatherCode == 0) return isDay ? Icons.wb_sunny_rounded : Icons.nightlight_round;
    if (weatherCode <= 2) return isDay ? Icons.wb_sunny_outlined : Icons.cloud_outlined;
    if (weatherCode == 3) return Icons.cloud_outlined;
    if (weatherCode == 45 || weatherCode == 48) return Icons.foggy;
    if (weatherCode >= 51 && weatherCode <= 55) return Icons.grain;
    if (weatherCode >= 61 && weatherCode <= 65) return Icons.water_drop_outlined;
    if (weatherCode >= 80 && weatherCode <= 82) return Icons.thunderstorm_outlined;
    if (weatherCode >= 95) return Icons.flash_on;
    return Icons.wb_sunny_outlined;
  }

  Color get materialIconColor {
    if (weatherCode <= 2) return const Color(0xFFF59E0B);
    if (weatherCode >= 51 && weatherCode <= 65) return const Color(0xFF0284C7);
    if (weatherCode >= 80) return const Color(0xFF4F46E5);
    return const Color(0xFF0284C7);
  }

  WeatherData copyWith({
    String? cityName,
    double? temperature,
    double? apparentTemperature,
    int? humidity,
    double? windSpeed,
    double? precipitation,
    int? weatherCode,
    String? condition,
    String? icon,
    bool? isDay,
    String? travelAdvice,
    List<DailyForecast>? dailyForecast,
    String? updatedAt,
    bool? isFromGps,
  }) {
    return WeatherData(
      cityName: cityName ?? this.cityName,
      temperature: temperature ?? this.temperature,
      apparentTemperature: apparentTemperature ?? this.apparentTemperature,
      humidity: humidity ?? this.humidity,
      windSpeed: windSpeed ?? this.windSpeed,
      precipitation: precipitation ?? this.precipitation,
      weatherCode: weatherCode ?? this.weatherCode,
      condition: condition ?? this.condition,
      icon: icon ?? this.icon,
      isDay: isDay ?? this.isDay,
      travelAdvice: travelAdvice ?? this.travelAdvice,
      dailyForecast: dailyForecast ?? this.dailyForecast,
      updatedAt: updatedAt ?? this.updatedAt,
      isFromGps: isFromGps ?? this.isFromGps,
    );
  }

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final dailyList = (json['dailyForecast'] as List<dynamic>?)
            ?.map((e) => DailyForecast.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return WeatherData(
      cityName: json['cityName'] as String? ?? 'Đà Nẵng',
      temperature: (json['temperature'] as num?)?.toDouble() ?? 28.0,
      apparentTemperature: (json['apparentTemperature'] as num?)?.toDouble() ?? 31.0,
      humidity: (json['humidity'] as num?)?.toInt() ?? 70,
      windSpeed: (json['windSpeed'] as num?)?.toDouble() ?? 8.0,
      precipitation: (json['precipitation'] as num?)?.toDouble() ?? 0.0,
      weatherCode: (json['weatherCode'] as num?)?.toInt() ?? 1,
      condition: json['condition'] as String? ?? 'Nắng ráo',
      icon: json['icon'] as String? ?? '☀️',
      isDay: json['isDay'] as bool? ?? true,
      travelAdvice: json['travelAdvice'] as String? ??
          'Thời tiết Đà Nẵng nắng ráo, rất thích hợp tham quan Bán đảo Sơn Trà và tắm biển Mỹ Khê.',
      dailyForecast: dailyList,
      updatedAt: json['updatedAt'] as String? ?? 'Vừa xong',
      isFromGps: false,
    );
  }

  factory WeatherData.fromOpenMeteoJson(
    Map<String, dynamic> json, {
    String? locationName,
  }) {
    final current = (json['current'] as Map<String, dynamic>?) ?? {};
    final temp = (current['temperature_2m'] as num?)?.toDouble() ?? 28.5;
    final apparentTemp = (current['apparent_temperature'] as num?)?.toDouble() ?? (temp + 2);
    final humidity = (current['relative_humidity_2m'] as num?)?.toInt() ?? 75;
    final wind = (current['wind_speed_10m'] as num?)?.toDouble() ?? 8.0;
    final precip = (current['precipitation'] as num?)?.toDouble() ?? 0.0;
    final code = (current['weather_code'] as num?)?.toInt() ?? 1;
    final isDay = (current['is_day'] as num?)?.toInt() == 1;

    final condition = _mapCodeToCondition(code);
    final icon = _mapCodeToIcon(code, isDay);

    final daily = (json['daily'] as Map<String, dynamic>?) ?? {};
    final times = (daily['time'] as List<dynamic>?) ?? [];
    final codes = (daily['weather_code'] as List<dynamic>?) ?? [];
    final maxTemps = (daily['temperature_2m_max'] as List<dynamic>?) ?? [];
    final minTemps = (daily['temperature_2m_min'] as List<dynamic>?) ?? [];
    final rainProbs = (daily['precipitation_probability_max'] as List<dynamic>?) ?? [];

    final dailyForecast = <DailyForecast>[];
    final count = times.length > 7 ? 7 : times.length;
    int todayRainProb = 0;

    for (int i = 0; i < count; i++) {
      final dateStr = times[i].toString();
      final dayCode = (codes.length > i ? codes[i] as num? : 0)?.toInt() ?? 0;
      final maxT = (maxTemps.length > i ? maxTemps[i] as num? : 30.0)?.toDouble() ?? 30.0;
      final minT = (minTemps.length > i ? minTemps[i] as num? : 24.0)?.toDouble() ?? 24.0;
      final rainProb = (rainProbs.length > i ? rainProbs[i] as num? : 0)?.toInt() ?? 0;
      if (i == 0) todayRainProb = rainProb;

      dailyForecast.add(DailyForecast(
        date: dateStr,
        minTemp: minT,
        maxTemp: maxT,
        precipitationProbability: rainProb,
        weatherCode: dayCode,
        condition: _mapCodeToCondition(dayCode),
        icon: _mapCodeToIcon(dayCode, true),
      ));
    }

    final advice = _generateAdvice(code, temp, todayRainProb);
    final now = DateTime.now();
    final updatedAt =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} - ${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}';

    return WeatherData(
      cityName: locationName ?? 'Đà Nẵng',
      temperature: temp,
      apparentTemperature: apparentTemp,
      humidity: humidity,
      windSpeed: wind,
      precipitation: precip,
      weatherCode: code,
      condition: condition,
      icon: icon,
      isDay: isDay,
      travelAdvice: advice,
      dailyForecast: dailyForecast,
      updatedAt: updatedAt,
      isFromGps: false,
    );
  }

  static String _mapCodeToCondition(int code) {
    if (code == 0) return 'Trời quang đãng';
    if (code == 1) return 'Chủ yếu quang mây';
    if (code == 2) return 'Mây rải rác';
    if (code == 3) return 'Nhiều mây';
    if (code == 45 || code == 48) return 'Có sương mù';
    if (code >= 51 && code <= 55) return 'Mưa phùn nhẹ';
    if (code >= 61 && code <= 65) return 'Mưa rào rải rác';
    if (code >= 80 && code <= 82) return 'Mưa rào từng cơn';
    if (code >= 95) return 'Có dông sét';
    return 'Thời tiết dịu mát';
  }

  static String _mapCodeToIcon(int code, bool isDay) {
    if (code == 0) return isDay ? '☀️' : '🌙';
    if (code <= 2) return isDay ? '🌤️' : '☁️';
    if (code == 3) return '☁️';
    if (code == 45 || code == 48) return '🌫️';
    if (code >= 51 && code <= 55) return '🌦️';
    if (code >= 61 && code <= 65) return '🌧️';
    if (code >= 80 && code <= 82) return '⛈️';
    if (code >= 95) return '🌩️';
    return '⛅';
  }

  static String _generateAdvice(int code, double temp, int rainProb) {
    if (code >= 80 || rainProb >= 70) {
      return 'Thời tiết có thể có mưa to hoặc dông. Ưu tiên các điểm tham quan trong nhà như Bảo tàng Chăm, Chợ Cồn.';
    }
    if (code >= 51 && code <= 65) {
      return 'Có mưa rào rải rác. Hãy mang theo ô/áo mưa khi dạo phố Bạch Đằng và chú ý đường dốc Sơn Trà.';
    }
    if (temp >= 34) {
      return 'Thời tiết nắng nóng, thích hợp tắm biển Mỹ Khê vào sáng sớm hoặc chiều mát.';
    }
    if (code <= 2) {
      return 'Thời tiết nắng ráo rất đẹp! Thích hợp tham quan Bán đảo Sơn Trà, Ngũ Hành Sơn, Bà Nà Hills.';
    }
    return 'Thời tiết mát mẻ dễ chịu, thích hợp cho mọi hoạt động khám phá Đà Nẵng hôm nay.';
  }

  static WeatherData fallback({bool isFromGps = false}) {
    return WeatherData(
      cityName: isFromGps ? 'Vị trí của bạn (Đà Nẵng)' : 'Đà Nẵng',
      temperature: 29.0,
      apparentTemperature: 33.0,
      humidity: 72,
      windSpeed: 8.5,
      precipitation: 0.0,
      weatherCode: 1,
      condition: 'Nắng ráo dịu nhẹ',
      icon: '🌤️',
      isDay: true,
      travelAdvice: 'Thời tiết nắng ráo, rất thích hợp tham quan Bán đảo Sơn Trà và biển Mỹ Khê.',
      dailyForecast: const [],
      updatedAt: 'Vừa xong',
      isFromGps: isFromGps,
    );
  }
}
