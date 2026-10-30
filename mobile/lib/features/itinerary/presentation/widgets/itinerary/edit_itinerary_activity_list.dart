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

  const EditItineraryActivityList({
    super.key,
    required this.selectedDayIndex,
    required this.currentItems,
    required this.dayCost,
    required this.onMoveItem,
    required this.onRemoveItem,
    required this.onAddDestination,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        _buildInstructionCard(context),
        const SizedBox(height: 16),
        ...currentItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == currentItems.length - 1;
          return Column(
            children: [
              EditActivityItemTile(
                item: item,
                index: index,
                totalCount: currentItems.length,
                onMoveUp: index > 0 ? () => onMoveItem(index, index - 1) : null,
                onMoveDown: index < currentItems.length - 1 ? () => onMoveItem(index, index + 1) : null,
                onDelete: () => onRemoveItem(index),
              ),
              if (!isLast) _buildConnector(),
            ],
          );
        }),
        const SizedBox(height: 16),
        _buildAddDestinationButton(),
        const SizedBox(height: 20),
        EditItinerarySummaryCard(
          dayNumber: selectedDayIndex + 1,
          placesCount: currentItems.length,
          dayCostVnd: dayCost,
        ),
      ],
    );
  }

  Widget _buildInstructionCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBAE6FD)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: AppTheme.primaryBlue, borderRadius: BorderRadius.all(Radius.circular(8))),
            child: const Icon(Icons.swap_vert, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chỉnh sửa thứ tự hoạt động',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0369A1)),
                ),
                SizedBox(height: 2),
                Text(
                  'Dùng nút mũi tên ↑ ↓ để sắp xếp hoặc đổi điểm tham quan phù hợp nhu cầu.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF0284C7), height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              side: const BorderSide(color: AppTheme.primaryBlue),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('AI đã tối ưu lại tuyến đường ngắn nhất!'),
                  backgroundColor: AppTheme.statusSuccess,
                ),
              );
            },
            child: const Text('Tối ưu AI', style: TextStyle(fontSize: 11, color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildConnector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const SizedBox(width: 44),
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(color: AppTheme.primaryBlue, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppTheme.surfaceSubtle, borderRadius: BorderRadius.circular(12)),
            child: const Row(
              children: [
                Icon(Icons.directions_car, size: 12, color: AppTheme.textMuted),
                SizedBox(width: 4),
                Text(
                  '15p • 4.2 km di chuyển',
                  style: TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
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
            Text(
              'Thêm địa điểm vào Ngày ${selectedDayIndex + 1}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
            ),
          ],
        ),
      ),
    );
  }
}
