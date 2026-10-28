import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarttravel_mobile/features/weather/data/models/weather_model.dart';
import 'package:smarttravel_mobile/features/weather/presentation/providers/weather_provider.dart';
import 'package:smarttravel_mobile/features/weather/presentation/widgets/weather_detail_bottom_sheet.dart';

class WeatherPill extends ConsumerWidget {
  const WeatherPill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherProvider);

    return weatherAsync.when(
      data: (weather) => _buildPill(
        context: context,
        text: weather.pillText,
        iconData: weather.materialIcon,
        iconColor: weather.materialIconColor,
        isFromGps: weather.isFromGps,
        onTap: () => WeatherDetailBottomSheet.show(context, weather),
      ),
      loading: () => _buildPill(
        context: context,
        text: 'Đang định vị...',
        iconData: Icons.cloud_outlined,
        iconColor: const Color(0xFF0284C7),
        isLoading: true,
        onTap: null,
      ),
      error: (_, __) {
        final fallback = WeatherData.fallback();
        return _buildPill(
          context: context,
          text: fallback.pillText,
          iconData: fallback.materialIcon,
          iconColor: fallback.materialIconColor,
          onTap: () => WeatherDetailBottomSheet.show(context, fallback),
        );
      },
    );
  }

  Widget _buildPill({
    required BuildContext context,
    required String text,
    required IconData iconData,
    required Color iconColor,
    bool isLoading = false,
    bool isFromGps = false,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFE0F2FE),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFBAE6FD)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0077B6).withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: Color(0xFF0284C7),
                  ),
                )
              else ...[
                if (isFromGps) ...[
                  const Icon(Icons.near_me, size: 12, color: Color(0xFF0284C7)),
                  const SizedBox(width: 4),
                ],
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0284C7),
                  ),
                ),
              ],
              const SizedBox(width: 6),
              Icon(iconData, size: 16, color: iconColor),
            ],
          ),
        ),
      ),
    );
  }
}
