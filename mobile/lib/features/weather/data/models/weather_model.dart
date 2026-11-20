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
      minTemp: (json['minTemp'] as num).toDouble(),
      maxTemp: (json['maxTemp'] as num).toDouble(),
      precipitationProbability: (json['precipitationProbability'] as num).toInt(),
      weatherCode: (json['weatherCode'] as num).toInt(),
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
  final double? temperature;
  final double? apparentTemperature;
  final int? humidity;
  final double? windSpeed;
  final double? precipitation;
  final int? weatherCode;
  final String condition;
  final bool? isDay;
  final String? travelAdvice;
  final List<DailyForecast> dailyForecast;
  final DateTime? validAt;
  final DateTime? updatedAt;
  final String status;
  final String? source;
  final bool isFromGps;

  const WeatherData._({
    this.cityName = 'Đà Nẵng',
    this.temperature,
    this.apparentTemperature,
    this.humidity,
    this.windSpeed,
    this.precipitation,
    this.weatherCode,
    required this.condition,
    this.isDay,
    this.travelAdvice,
    this.dailyForecast = const [],
    this.validAt,
    this.updatedAt,
    this.status = 'UNAVAILABLE',
    this.source,
    this.isFromGps = false,
  });

  const WeatherData.unavailable() : this._(condition: 'Chưa có dữ liệu thời tiết');

  factory WeatherData.fromJson(Map<String, dynamic> json, {bool isFromGps = false}) {
    final validAt = DateTime.tryParse(json['validAt'] as String? ?? '');
    final status = json['status'];
    if (validAt == null || !['FRESH', 'CACHED', 'STALE'].contains(status) ||
        json['source'] != 'OPEN_METEO_MODEL' || json['temperature'] is! num) {
      return const WeatherData.unavailable();
    }
    return WeatherData._(
      cityName: json['cityName'] as String? ?? 'Đà Nẵng',
      temperature: (json['temperature'] as num?)?.toDouble(),
      apparentTemperature: (json['apparentTemperature'] as num?)?.toDouble(),
      humidity: (json['humidity'] as num?)?.toInt(),
      windSpeed: (json['windSpeed'] as num?)?.toDouble(),
      precipitation: (json['precipitation'] as num?)?.toDouble(),
      weatherCode: (json['weatherCode'] as num?)?.toInt(),
      condition: json['condition'] as String? ?? 'Chưa phân loại',
      isDay: json['isDay'] as bool?,
      travelAdvice: json['travelAdvice'] as String?,
      dailyForecast: (json['dailyForecast'] as List<dynamic>? ?? [])
          .map((item) => DailyForecast.fromJson(item as Map<String, dynamic>)).toList(),
      validAt: validAt,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
      status: status as String,
      source: json['source'] as String?,
      isFromGps: isFromGps,
    );
  }

  bool get available => temperature != null && validAt != null &&
      DateTime.now().difference(validAt!) < const Duration(hours: 6);
  bool get stale => status == 'STALE' || (validAt != null &&
      DateTime.now().difference(validAt!) >= const Duration(minutes: 30));
  String get pillText => !available ? 'Thời tiết chưa có dữ liệu'
      : '${temperature!.round()}°C · ${stale ? 'Dữ liệu cũ' : cityName}';
  String get apparentTempFormatted => apparentTemperature == null ? 'Chưa rõ' : '${apparentTemperature!.round()}°C';
  String get modelTime {
    if (validAt == null) return 'Chưa rõ';
    final time = validAt!.toUtc().add(const Duration(hours: 7));
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute · ${time.day}/${time.month}/${time.year}';
  }

  IconData get materialIcon => switch (weatherCode ?? -1) {
    0 => isDay == true ? Icons.wb_sunny_rounded : Icons.nightlight_round,
    45 || 48 => Icons.foggy,
    >= 95 => Icons.thunderstorm_outlined,
    >= 51 => Icons.water_drop_outlined,
    _ => Icons.cloud_outlined,
  };
  Color get materialIconColor => const Color(0xFF0284C7);
}
