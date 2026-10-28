import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smarttravel_mobile/core/theme/app_theme.dart';
import 'package:smarttravel_mobile/features/itinerary/data/models/itinerary_model.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/widgets/itinerary/share_itinerary_dialog.dart';

class MyTripCard extends StatelessWidget {
  final ItineraryResponseModel trip;
  final int index;
  final Function(int tripId) onDelete;

  const MyTripCard({
    super.key,
    required this.trip,
    required this.index,
    required this.onDelete,
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

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa lịch trình "${trip.title}" không? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.statusError),
            onPressed: () {
              Navigator.pop(ctx);
              onDelete(trip.id);
            },
            child: const Text('Xóa lịch trình'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color dotColor = AppTheme.primaryBlue;
    String statusLabel = 'Sắp tới';
    Color statusBg = const Color(0xFFE0F2FE);
    Color statusText = const Color(0xFF0284C7);

    if (index == 1) {
      dotColor = AppTheme.secondaryCoral;
      statusLabel = 'Nháp';
      statusBg = const Color(0xFFFFEDD5);
      statusText = const Color(0xFFC2410C);
    } else if (index >= 2) {
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
                            child: Text(
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
                      child: Text(
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
                    Text(
                      '${trip.startDate} - ${trip.endDate}',
                      style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                    ),
                    const SizedBox(width: 10),
                    const Text('•', style: TextStyle(color: Color(0xFFCBD5E1))),
                    const SizedBox(width: 10),
                    const Icon(Icons.people_outline, size: 16, color: AppTheme.textMuted),
                    const SizedBox(width: 4),
                    Text('${trip.travelersCount} người', style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
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
                      Row(
                        children: [
                          const Icon(Icons.payments_outlined, size: 18, color: AppTheme.primaryBlue),
                          const SizedBox(width: 8),
                          Text(
                            '${_formatVnd(trip.totalEstimatedCost)} VNĐ',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
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
                            child: Text(
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
                    Row(
                      children: [
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: IconButton(
                            tooltip: 'Chỉnh sửa lịch trình',
                            icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF475569)),
                            onPressed: () => context.push('/itineraries/${trip.id}/edit', extra: trip),
                          ),
                        ),
                        const SizedBox(width: 2),
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: IconButton(
                            tooltip: 'Chia sẻ lịch trình',
                            icon: const Icon(Icons.share_outlined, size: 18, color: Color(0xFF475569)),
                            onPressed: () => ShareItineraryDialog.show(context, trip.id, trip.title),
                          ),
                        ),
                        const SizedBox(width: 2),
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: IconButton(
                            tooltip: 'Xóa lịch trình',
                            icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.statusError),
                            onPressed: () => _showDeleteDialog(context),
                          ),
                        ),
                      ],
                    ),
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
