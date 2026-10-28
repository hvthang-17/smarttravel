import 'package:flutter/material.dart';
import 'package:smarttravel_mobile/core/theme/app_theme.dart';
import 'package:smarttravel_mobile/features/itinerary/data/models/itinerary_model.dart';

class ItineraryDayRibbon extends StatelessWidget {
  final List<ItineraryDayModel> days;
  final int selectedDayIndex;
  final int activeViewIndex;
  final ValueChanged<int> onDaySelected;
  final ValueChanged<int> onViewChanged;

  const ItineraryDayRibbon({
    super.key,
    required this.days,
    required this.selectedDayIndex,
    required this.activeViewIndex,
    required this.onDaySelected,
    required this.onViewChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 10, bottom: 12),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: List.generate(days.length, (index) {
                final isSelected = index == selectedDayIndex;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => onDaySelected(index),
                    borderRadius: BorderRadius.circular(999),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryBlue : Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryBlue : AppTheme.borderSubtle,
                        ),
                        boxShadow: isSelected
                            ? const [
                                BoxShadow(
                                  color: Color(0x260077B6),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        'Ngày ${index + 1}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? Colors.white : AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 38,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSwitcherTab(
                      index: 0,
                      icon: Icons.format_list_bulleted,
                      label: 'Lịch trình',
                    ),
                  ),
                  Expanded(
                    child: _buildSwitcherTab(
                      index: 1,
                      icon: Icons.map_outlined,
                      label: 'Bản đồ',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitcherTab({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isActive = activeViewIndex == index;
    return GestureDetector(
      onTap: () => onViewChanged(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: isActive
              ? const [
                  BoxShadow(
                    color: Color(0x0F0F172A),
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? AppTheme.primaryBlue : AppTheme.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? AppTheme.primaryBlue : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
