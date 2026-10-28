import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarttravel_mobile/features/weather/data/models/weather_model.dart';
import 'package:smarttravel_mobile/features/weather/presentation/providers/weather_provider.dart';
import 'package:smarttravel_mobile/features/weather/presentation/widgets/weather_7day_forecast_card.dart';
import 'package:smarttravel_mobile/features/weather/presentation/widgets/weather_metrics_grid.dart';

class WeatherDetailBottomSheet extends ConsumerWidget {
  final WeatherData weather;

  const WeatherDetailBottomSheet({super.key, required this.weather});

  static Future<void> show(BuildContext context, WeatherData weather) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WeatherDetailBottomSheet(weather: weather),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maxSheetHeight = MediaQuery.of(context).size.height * 0.88;

    return Container(
      constraints: BoxConstraints(maxHeight: maxSheetHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.wb_sunny_rounded, color: Color(0xFF0077B6), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thời tiết thực tế Đà Nẵng',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        'Cập nhật: ${weather.updatedAt} • ${weather.isFromGps ? "Theo định vị GPS" : "Toàn thành phố"}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Làm mới',
                  icon: const Icon(Icons.refresh_rounded, color: Color(0xFF0077B6)),
                  onPressed: () {
                    ref.invalidate(weatherProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đang cập nhật lại thời tiết Đà Nẵng...'),
                        duration: Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0077B6), Color(0xFF0096C7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0077B6).withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${weather.temperature.round()}',
                                  style: const TextStyle(
                                    fontSize: 52,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1.0,
                                  ),
                                ),
                                const Text(
                                  '°C',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              weather.condition,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Cảm giác như ${weather.apparentTempFormatted}',
                              style: const TextStyle(fontSize: 12, color: Color(0xFFE0F2FE)),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Icon(weather.materialIcon, size: 54, color: Colors.white),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    weather.isFromGps ? Icons.near_me : Icons.location_on,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    weather.cityName,
                                    style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  WeatherMetricsGrid(weather: weather),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.tips_and_updates, color: Color(0xFFD97706), size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Gợi ý lịch trình theo thời tiết hôm nay',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF92400E),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          weather.travelAdvice,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: Color(0xFF78350F),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Dự báo thời tiết Đà Nẵng 7 ngày tới',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Weather7DayForecastCard(dailyForecast: weather.dailyForecast),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
