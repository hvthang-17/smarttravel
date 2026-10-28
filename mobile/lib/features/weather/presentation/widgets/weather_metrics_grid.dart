import 'package:flutter/material.dart';
import 'package:smarttravel_mobile/features/weather/data/models/weather_model.dart';

class WeatherMetricsGrid extends StatelessWidget {
  final WeatherData weather;

  const WeatherMetricsGrid({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _buildMetricTile(
              icon: Icons.water_drop_outlined,
              label: 'Độ ẩm',
              value: '${weather.humidity}%',
              color: const Color(0xFF0284C7),
            ),
            const SizedBox(width: 10),
            _buildMetricTile(
              icon: Icons.air,
              label: 'Tốc độ gió',
              value: '${weather.windSpeed.toStringAsFixed(1)} km/h',
              color: const Color(0xFF10B981),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildMetricTile(
              icon: Icons.umbrella_outlined,
              label: 'Lượng mưa',
              value: '${weather.precipitation.toStringAsFixed(1)} mm',
              color: const Color(0xFF8B5CF6),
            ),
            const SizedBox(width: 10),
            _buildMetricTile(
              icon: weather.isDay ? Icons.wb_sunny_outlined : Icons.nightlight_round,
              label: 'Thời điểm',
              value: weather.isDay ? 'Ban ngày' : 'Ban đêm',
              color: const Color(0xFFF77F00),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
