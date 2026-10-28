import 'package:flutter/material.dart';
import 'package:smarttravel_mobile/core/theme/app_theme.dart';
import 'package:smarttravel_mobile/features/itinerary/data/models/itinerary_model.dart';

class EditActivityItemTile extends StatelessWidget {
  final ItineraryItemModel item;
  final int index;
  final int totalCount;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final VoidCallback onDelete;

  const EditActivityItemTile({
    super.key,
    required this.item,
    required this.index,
    required this.totalCount,
    this.onMoveUp,
    this.onMoveDown,
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

  @override
  Widget build(BuildContext context) {
    final dest = item.destination;
    final IconData categoryIcon = dest?.category.contains('Biển') == true
        ? Icons.beach_access
        : dest?.category.contains('Ẩm thực') == true
            ? Icons.restaurant
            : dest?.category.contains('Văn hóa') == true
                ? Icons.museum_outlined
                : dest?.category.contains('Thiên nhiên') == true
                    ? Icons.park_outlined
                    : Icons.camera_alt_outlined;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.drag_indicator, color: AppTheme.textMuted, size: 20),
          const SizedBox(width: 8),
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppTheme.primaryBlue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '0${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(categoryIcon, size: 16, color: AppTheme.primaryBlue),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        dest?.name ?? 'Điểm tham quan',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.startTime ?? "08:00"} - ${item.durationMinutes ?? 90}p • ${item.notes ?? ""}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.estimatedCostVnd != null && item.estimatedCostVnd! > 0
                            ? '${_formatVnd(item.estimatedCostVnd!)}đ'
                            : 'Miễn phí',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0284C7),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '• ${dest?.category ?? "Đà Nẵng"}',
                      style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: IconButton(
                  tooltip: 'Chuyển lên trước',
                  onPressed: onMoveUp,
                  icon: Icon(
                    Icons.keyboard_arrow_up,
                    size: 20,
                    color: onMoveUp != null ? AppTheme.textPrimary : const Color(0xFFCBD5E1),
                  ),
                ),
              ),
              SizedBox(
                width: 44,
                height: 44,
                child: IconButton(
                  tooltip: 'Chuyển xuống sau',
                  onPressed: onMoveDown,
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    size: 20,
                    color: onMoveDown != null ? AppTheme.textPrimary : const Color(0xFFCBD5E1),
                  ),
                ),
              ),
              SizedBox(
                width: 44,
                height: 44,
                child: IconButton(
                  tooltip: 'Xóa điểm này',
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 20, color: AppTheme.statusError),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
