import 'package:smarttravel_mobile/core/localization/app_language.dart';
import 'package:flutter/material.dart';
import 'package:smarttravel_mobile/core/theme/app_theme.dart';
import 'package:smarttravel_mobile/features/itinerary/data/models/itinerary_model.dart';

class EditActivityItemTile extends StatelessWidget {
  final ItineraryItemModel item;
  final int index;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onReplace;

  const EditActivityItemTile({
    super.key,
    required this.item,
    required this.index,
    this.onMoveUp,
    this.onMoveDown,
    required this.onDelete,
    required this.onEdit,
    required this.onReplace,
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
    final time = item.startTime?.split(':').take(2).join(':') ?? 'Chưa đặt giờ';
    final minutes = item.previewDurationMinutes;
    final cost = item.estimatedCostVnd;
    final price = cost == null ? 'Chưa rõ giá'
        : !item.upperPriceKnown ? 'Từ ${_formatVnd(cost)} đ'
        : cost == 0 ? 'Miễn phí' : '${_formatVnd(cost)} đ';
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
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppTheme.primaryBlue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: AppText(
                '${index + 1}',
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
                      child: AppText(
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
                AppText(
                  '$time · ${minutes == null ? 'Chưa rõ thời lượng' : '$minutes phút'}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
                if (item.notes?.isNotEmpty == true)
                  AppText(item.notes!, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                const SizedBox(height: 6),
                Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: AppText(
                        price,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0284C7),
                        ),
                      ),
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
                  tooltip: AppLanguage.text(context, 'Chuyển lên trước'),
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
                  tooltip: AppLanguage.text(context, 'Chuyển xuống sau'),
                  onPressed: onMoveDown,
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    size: 20,
                    color: onMoveDown != null ? AppTheme.textPrimary : const Color(0xFFCBD5E1),
                  ),
                ),
              ),
              PopupMenuButton<VoidCallback>(
                tooltip: AppLanguage.text(context, 'Tùy chọn hoạt động'),
                onSelected: (action) => action(),
                itemBuilder: (_) => [
                  PopupMenuItem(value: onEdit, child: const AppText('Sửa giờ, thời lượng, ghi chú')),
                  PopupMenuItem(value: onReplace, child: const AppText('Thay địa điểm')),
                  PopupMenuItem(value: onDelete, child: const AppText('Xóa điểm này')),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
