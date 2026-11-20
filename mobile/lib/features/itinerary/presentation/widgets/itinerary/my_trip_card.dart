import 'package:smarttravel_mobile/core/localization/app_language.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smarttravel_mobile/core/theme/app_theme.dart';
import 'package:smarttravel_mobile/features/itinerary/data/models/itinerary_model.dart';
import 'trip_actions.dart';

class MyTripCard extends StatelessWidget {
  final ItineraryResponseModel trip;

  const MyTripCard({
    super.key,
    required this.trip,
  });

  String _formatVnd(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }
    return buffer.toString().split('').reversed.join('');
  }

  @override
  Widget build(BuildContext context) {
    Color dotColor = AppTheme.primaryBlue;
    String statusLabel = 'Hiện tại / sắp tới';
    Color statusBg = const Color(0xFFE0F2FE);
    Color statusText = const Color(0xFF0284C7);

    if (trip.status == 'DRAFT') {
      dotColor = AppTheme.secondaryCoral;
      statusLabel = 'Nháp';
      statusBg = const Color(0xFFFFEDD5);
      statusText = const Color(0xFFC2410C);
    } else if (trip.period == 'HISTORY') {
      dotColor = const Color(0xFF94A3B8);
      statusLabel = 'Đã đi';
      statusBg = const Color(0xFFF1F5F9);
      statusText = AppTheme.textMuted;
    }

    final previewPlaces = <String>[];
    for (final day in trip.days) {
      for (final it in day.items) {
        if (it.destination?.name != null && !previewPlaces.contains(it.destination!.name)) {
          previewPlaces.add(it.destination!.name);
          if (previewPlaces.length >= 2) break;
        }
      }
      if (previewPlaces.length >= 2) break;
    }
    final placesText = previewPlaces.isNotEmpty ? previewPlaces.join(' & ') : 'Khám phá TP. Đà Nẵng';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push('/itineraries/${trip.id}', extra: trip),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AppText(
                              trip.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(12)),
                      child: AppText(
                        statusLabel,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusText),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 14, color: AppTheme.textMuted),
                    const SizedBox(width: 6),
                    Flexible(child: AppText(
                      '${trip.startDate} - ${trip.endDate}',
                      style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                    )),
                    const SizedBox(width: 10),
                    const AppText('•', style: TextStyle(color: Color(0xFFCBD5E1))),
                    const SizedBox(width: 10),
                    const Icon(Icons.people_outline, size: 16, color: AppTheme.textMuted),
                    const SizedBox(width: 4),
                    AppText('${trip.travelersCount} người', style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCanvas,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.borderSubtle),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Row(
                        children: [
                          const Icon(Icons.payments_outlined, size: 18, color: AppTheme.primaryBlue),
                          const SizedBox(width: 8),
                          Flexible(child: AppText(
                            '${_formatVnd(trip.totalEstimatedCost)} VNĐ${trip.costComplete ? '' : ' (đã biết)'}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          )),
                        ],
                      )),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const AppText(
                          'Ước tính',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primaryBlue),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 16, color: AppTheme.primaryBlue),
                          const SizedBox(width: 4),
                          Expanded(
                            child: AppText(
                              placesText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.primaryBlue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TripActions(trip: trip),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
