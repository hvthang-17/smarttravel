import 'package:flutter/material.dart';
import 'package:smarttravel_mobile/core/theme/app_theme.dart';
import 'package:smarttravel_mobile/features/itinerary/data/models/itinerary_model.dart';

class EditItineraryDaySelector extends StatelessWidget {
  final List<ItineraryDayModel> days;
  final int selectedDayIndex;
  final ValueChanged<int> onSelectDay;

  const EditItineraryDaySelector({
    super.key,
    required this.days,
    required this.selectedDayIndex,
    required this.onSelectDay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(days.length, (index) {
            final isSelected = index == selectedDayIndex;
            final day = days[index];
            final dateFormatted = (day.date != null && day.date!.isNotEmpty)
                ? ' (${day.date!.split('-').reversed.take(2).join('/')})'
                : '';
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () => onSelectDay(index),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryBlue : AppTheme.surfaceSubtle,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryBlue : AppTheme.borderSubtle,
                    ),
                  ),
                  child: Text(
                    'Ngày ${index + 1}$dateFormatted',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
