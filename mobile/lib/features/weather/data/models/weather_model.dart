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
    if (code == 1 || code == 2) return isDay ? '🌤️' : '☁️';
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
      return 'Thời tiết có thể có mưa to hoặc dông. Bạn nên ưu tiên các điểm tham quan trong nhà như Bảo tàng Điêu khắc Chăm, Chợ Cồn hoặc các quán cà phê ngắm cảnh sông Hàn.';
    }
    if (code >= 51 && code <= 65) {
      return 'Có mưa nhẹ hoặc mưa rào rải rác. Hãy mang theo ô/áo mưa khi dạo phố Bạch Đằng và lưu ý đường trơn khi lên Bán đảo Sơn Trà.';
    }
    if (temp >= 34) {
      return 'Thời tiết nắng nóng, thích hợp tắm biển Mỹ Khê vào sáng sớm hoặc chiều mát. Buổi trưa nên ghé các không gian nghỉ mát hoặc thưởng thức đặc sản Đà Nẵng.';
    }
    if (code <= 2) {
      return 'Thời tiết nắng ráo rất đẹp! Rất thích hợp để tham quan Bán đảo Sơn Trà, Ngũ Hành Sơn, Bà Nà Hills và ngắm hoàng hôn biển Mỹ Khê.';
    }
    return 'Thời tiết mát mẻ dễ chịu, rất thích hợp cho mọi hoạt động khám phá và dạo phố Đà Nẵng hôm nay.';
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
      travelAdvice:
          'Thời tiết nắng ráo rất đẹp! Rất thích hợp để tham quan Bán đảo Sơn Trà, Ngũ Hành Sơn, Bà Nà Hills và ngắm hoàng hôn biển Mỹ Khê.',
      dailyForecast: const [
        DailyForecast(
          date: 'Hôm nay',
          minTemp: 24.0,
          maxTemp: 31.0,
          precipitationProbability: 10,
          weatherCode: 1,
          condition: 'Nắng ráo',
          icon: '🌤️',
        ),
        DailyForecast(
          date: 'Ngày mai',
          minTemp: 24.5,
          maxTemp: 30.5,
          precipitationProbability: 20,
          weatherCode: 2,
          condition: 'Ít mây',
          icon: '⛅',
        ),
        DailyForecast(
          date: 'Hôm kia',
          minTemp: 24.0,
          maxTemp: 29.5,
          precipitationProbability: 40,
          weatherCode: 51,
          condition: 'Mưa rào nhẹ',
          icon: '🌦️',
        ),
        DailyForecast(
          date: 'Thứ sáu',
          minTemp: 23.5,
          maxTemp: 29.0,
          precipitationProbability: 30,
          weatherCode: 2,
          condition: 'Dịu mát',
          icon: '⛅',
        ),
        DailyForecast(
          date: 'Thứ bảy',
          minTemp: 24.0,
          maxTemp: 30.0,
          precipitationProbability: 15,
          weatherCode: 1,
          condition: 'Nắng đẹp',
          icon: '☀️',
        ),
      ],
      updatedAt: 'Hôm nay',
      isFromGps: isFromGps,
    );
  }
}
