import 'package:flutter/material.dart';
import 'package:smarttravel_mobile/features/weather/data/models/weather_model.dart';

class Weather7DayForecastCard extends StatelessWidget {
  final List<DailyForecast> dailyForecast;

  const Weather7DayForecastCard({super.key, required this.dailyForecast});

  String _formatDayLabel(String dateStr, int index) {
    if (index == 0) return 'Hôm nay';
    if (index == 1) return 'Ngày mai';
    if (dateStr.length >= 10) {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        return '${parts[2]}/${parts[1]}';
      }
    }
    return dateStr;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: List.generate(dailyForecast.length, (index) {
          final day = dailyForecast[index];
          final isLast = index == dailyForecast.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 85,
                      child: Text(
                        _formatDayLabel(day.date, index),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: index == 0 ? FontWeight.bold : FontWeight.w500,
                          color: index == 0 ? const Color(0xFF0077B6) : const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    Icon(day.materialIcon, size: 20, color: day.materialIconColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        day.condition,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (day.precipitationProbability > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: day.precipitationProbability > 50
                              ? const Color(0xFFFEE2E2)
                              : const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.water_drop,
                              size: 10,
                              color: day.precipitationProbability > 50
                                  ? const Color(0xFFDC2626)
                                  : const Color(0xFF0284C7),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${day.precipitationProbability}%',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: day.precipitationProbability > 50
                                    ? const Color(0xFFDC2626)
                                    : const Color(0xFF0284C7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Text(
                      '${day.minTemp.round()}° - ${day.maxTemp.round()}°C',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast) const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFF1F5F9)),
            ],
          );
        }),
      ),
    );
  }
}
