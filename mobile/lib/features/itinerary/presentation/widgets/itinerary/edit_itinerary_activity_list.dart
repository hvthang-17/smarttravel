import 'package:smarttravel_mobile/core/localization/app_language.dart';
import 'package:flutter/material.dart';
import 'package:smarttravel_mobile/core/theme/app_theme.dart';
import 'package:smarttravel_mobile/features/itinerary/data/models/itinerary_model.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/widgets/itinerary/edit_activity_item_tile.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/widgets/itinerary/edit_itinerary_summary_card.dart';

class EditItineraryActivityList extends StatelessWidget {
  final int selectedDayIndex;
  final List<ItineraryItemModel> currentItems;
  final int dayCost;
  final void Function(int oldIndex, int newIndex) onMoveItem;
  final ValueChanged<int> onRemoveItem;
  final VoidCallback onAddDestination;
  final ValueChanged<int> onEditItem;
  final ValueChanged<int> onReplaceItem;
  final bool saving;
  final int savedDayCost;

  const EditItineraryActivityList({
    super.key,
    required this.selectedDayIndex,
    required this.currentItems,
    required this.dayCost,
    required this.onMoveItem,
    required this.onRemoveItem,
    required this.onAddDestination,
    required this.onEditItem,
    required this.onReplaceItem,
    required this.saving,
    required this.savedDayCost,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        if (saving)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: AppText('Đang tính lại. Số liệu đã lưu được giữ đến khi máy chủ xác nhận.'),
          ),
        ...currentItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: EditActivityItemTile(
                item: item,
                index: index,
                onMoveUp: index > 0 ? () => onMoveItem(index, index - 1) : null,
                onMoveDown: index < currentItems.length - 1 ? () => onMoveItem(index, index + 1) : null,
                onDelete: () => onRemoveItem(index),
                onEdit: () => onEditItem(index),
                onReplace: () => onReplaceItem(index),
            ),
          );
        }),
        const SizedBox(height: 16),
        _buildAddDestinationButton(),
        const SizedBox(height: 20),
        EditItinerarySummaryCard(
          dayNumber: selectedDayIndex + 1,
          placesCount: currentItems.length,
          dayCostVnd: saving ? savedDayCost : dayCost,
          costComplete: currentItems.every((item) => item.estimatedCostVnd != null && item.upperPriceKnown),
          saving: saving,
        ),
      ],
    );
  }

  Widget _buildAddDestinationButton() {
    return InkWell(
      onTap: onAddDestination,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F9FF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.primaryBlue, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: AppTheme.primaryBlue, shape: BoxShape.circle),
              child: const Icon(Icons.add, size: 14, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: AppText(
                'Thêm địa điểm vào Ngày ${selectedDayIndex + 1}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
