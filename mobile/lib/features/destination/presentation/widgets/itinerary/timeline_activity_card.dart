import 'package:flutter/material.dart';
import 'package:smarttravel_mobile/features/destination/data/models/itinerary_model.dart';

class TimelineActivityCard extends StatelessWidget {
  final ItineraryItemModel item;
  final VoidCallback? onTap;

  const TimelineActivityCard({
    super.key,
    required this.item,
    this.onTap,
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

  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case 'Ăn uống':
        return Icons.restaurant;
      case 'Biển':
        return Icons.beach_access;
      case 'Văn hóa':
        return Icons.account_balance;
      case 'Thiên nhiên':
        return Icons.park;
      case 'Giải trí':
        return Icons.attractions;
      case 'Mua sắm':
        return Icons.shopping_bag;
      default:
        return Icons.place;
    }
  }

  String _formatEndTime(String? start, int? duration) {
    if (start == null || duration == null) return '';
    try {
      final parts = start.split(':');
      if (parts.length >= 2) {
        final h = int.parse(parts[0]);
        final m = int.parse(parts[1]);
        final totalM = h * 60 + m + duration;
        final endH = (totalM ~/ 60) % 24;
        final endM = totalM % 60;
        final startFormatted = '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
        final endFormatted = '${endH.toString().padLeft(2, '0')}:${endM.toString().padLeft(2, '0')}';
        return '$startFormatted - $endFormatted · $duration phút';
      }
    } catch (_) {}
    return '$start · $duration phút';
  }

  @override
  Widget build(BuildContext context) {
    final dest = item.destination;
    final seqStr = item.sequenceOrder.toString().padLeft(2, '0');
    final cost = item.estimatedCostVnd ?? 0;
    final timeStr = _formatEndTime(item.startTime, item.durationMinutes);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x060F172A),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sequence Badge (01, 02, 03)
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFF0077B6),
                shape: BoxShape.circle,
              ),
              child: Text(
                seqStr,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Destination Icon & Category
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFEDF6F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getCategoryIcon(dest?.category),
                color: const Color(0xFF0077B6),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),

            // Content details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          dest?.name ?? 'Điểm tham quan',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (dest?.category != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F9FF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            dest!.category,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0077B6),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Time & Duration
                  if (timeStr.isNotEmpty)
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 13,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timeStr,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 6),

                  // Cost with "Ước tính" tag
                  Row(
                    children: [
                      const Icon(
                        Icons.payments_outlined,
                        size: 14,
                        color: Color(0xFF475569),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        cost > 0 ? '${_formatVnd(cost)} VNĐ' : 'Miễn phí',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: cost > 0
                              ? const Color(0xFF0F172A)
                              : const Color(0xFF2A9D8F),
                        ),
                      ),
                      if (cost > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDF2F7),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: const Text(
                            'Ước tính',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  if (item.notes != null && item.notes!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.notes!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF475569),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
