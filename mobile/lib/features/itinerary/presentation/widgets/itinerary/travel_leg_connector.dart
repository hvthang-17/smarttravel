import 'package:smarttravel_mobile/core/localization/app_language.dart';
import 'package:flutter/material.dart';

class TravelLegConnector extends StatelessWidget {
  final double? distanceKm;
  final int? durationMinutes;
  final String routeSource;
  final bool fromOrigin;

  const TravelLegConnector({
    super.key,
    required this.distanceKm,
    required this.durationMinutes,
    this.routeSource = 'UNKNOWN',
    this.fromOrigin = false,
  });

  @override
  Widget build(BuildContext context) {
    if (distanceKm == 0 && durationMinutes == 0 && routeSource != 'UNKNOWN') {
      return const SizedBox(height: 12);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const SizedBox(width: 15),
          Container(
            width: 2,
            height: 32,
            color: const Color(0xFFCBD5E1),
          ),
          const SizedBox(width: 15),
          Flexible(child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.directions_bike,
                  size: 14,
                  color: Color(0xFF0077B6),
                ),
                const SizedBox(width: 6),
                Flexible(child: AppText(
                  '${fromOrigin ? 'Từ điểm xuất phát · ' : ''}${distanceKm == null || durationMinutes == null || routeSource == 'UNKNOWN'
                      ? 'Chưa có dữ liệu di chuyển'
                      : '$durationMinutes phút · ${distanceKm!.toStringAsFixed(1)} km${routeSource == 'HAVERSINE' ? ' (ước tính)' : ''}'}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                )),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
