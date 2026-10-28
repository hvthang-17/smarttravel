import 'package:flutter/material.dart';
import 'package:smarttravel_mobile/core/theme/app_theme.dart';
import 'package:smarttravel_mobile/features/home/presentation/widgets/home_category_pills.dart';

class HomeFilterBottomSheet extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onSelectCategory;

  const HomeFilterBottomSheet({
    super.key,
    required this.selectedCategory,
    required this.onSelectCategory,
  });

  static Future<void> show(
    BuildContext context, {
    required String selectedCategory,
    required ValueChanged<String> onSelectCategory,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => HomeFilterBottomSheet(
        selectedCategory: selectedCategory,
        onSelectCategory: onSelectCategory,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Lọc theo danh mục', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: homeCategories.map((c) {
              final isSelected = selectedCategory == c.label;
              return ChoiceChip(
                avatar: c.icon != null
                    ? Icon(c.icon, size: 16, color: isSelected ? Colors.white : AppTheme.primaryBlue)
                    : null,
                label: Text(c.label),
                selected: isSelected,
                selectedColor: AppTheme.primaryBlue,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (selected) {
                  if (selected) {
                    onSelectCategory(c.label);
                    Navigator.pop(context);
                  }
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
