import 'package:flutter/material.dart';
import 'package:smarttravel_mobile/core/theme/app_theme.dart';

class HomeCategoryItem {
  final String label;
  final IconData? icon;

  const HomeCategoryItem({required this.label, this.icon});
}

const List<HomeCategoryItem> homeCategories = [
  HomeCategoryItem(label: 'Tất cả'),
  HomeCategoryItem(label: 'Biển', icon: Icons.beach_access),
  HomeCategoryItem(label: 'Văn hóa', icon: Icons.museum_outlined),
  HomeCategoryItem(label: 'Ẩm thực', icon: Icons.restaurant),
  HomeCategoryItem(label: 'Thiên nhiên', icon: Icons.park_outlined),
  HomeCategoryItem(label: 'Check-in', icon: Icons.camera_alt_outlined),
];

class HomeCategoryPills extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onSelectCategory;

  const HomeCategoryPills({
    super.key,
    required this.selectedCategory,
    required this.onSelectCategory,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: homeCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = homeCategories[index];
          final isSelected = selectedCategory == cat.label;
          return InkWell(
            onTap: () => onSelectCategory(cat.label),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryBlue : AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppTheme.primaryBlue : AppTheme.borderSubtle,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (cat.icon != null) ...[
                    Icon(
                      cat.icon,
                      size: 16,
                      color: isSelected ? Colors.white : AppTheme.primaryBlue,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    cat.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
