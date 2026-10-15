import 'package:flutter/material.dart';

class WizardStep3Preferences extends StatelessWidget {
  final Set<String> selectedCategories;
  final String selectedPace;
  final ValueChanged<Set<String>> onCategoriesChanged;
  final ValueChanged<String> onPaceChanged;

  const WizardStep3Preferences({
    super.key,
    required this.selectedCategories,
    required this.selectedPace,
    required this.onCategoriesChanged,
    required this.onPaceChanged,
  });

  static const List<String> _availableCategories = [
    'Tham quan',
    'Ăn uống',
    'Biển',
    'Văn hóa',
    'Check-in',
    'Thiên nhiên',
    'Giải trí',
    'Mua sắm',
  ];

  static const List<Map<String, dynamic>> _paceOptions = [
    {
      'id': 'relaxed',
      'title': 'Thư thả',
      'subtitle': '2 điểm mỗi ngày, nhiều thời gian thư giãn & cà phê',
      'icon': Icons.wb_sunny_outlined,
    },
    {
      'id': 'balanced',
      'title': 'Cân bằng',
      'subtitle': '3 điểm mỗi ngày, kết hợp khám phá và nghỉ ngơi hợp lý',
      'icon': Icons.explore_outlined,
    },
    {
      'id': 'packed',
      'title': 'Năng động',
      'subtitle': '4 điểm mỗi ngày, lịch trình dày dặn trải nghiệm tối đa',
      'icon': Icons.bolt_outlined,
    },
  ];

  void _toggleCategory(String category) {
    final updated = Set<String>.from(selectedCategories);
    if (updated.contains(category)) {
      if (updated.length > 1) {
        updated.remove(category);
      }
    } else {
      updated.add(category);
    }
    onCategoriesChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bạn thích trải nghiệm gì?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Chọn ít nhất 1 chủ đề bạn muốn tập trung tại Đà Nẵng',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 16),

        // Categories multi-select chips
        Wrap(
          spacing: 8,
          runSpacing: 10,
          children: _availableCategories.map((category) {
            final isSelected = selectedCategories.contains(category);
            return FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (_) => _toggleCategory(category),
              selectedColor: const Color(0xFF0077B6),
              backgroundColor: Colors.white,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? Colors.white : const Color(0xFF0F172A),
              ),
              side: BorderSide(
                color: isSelected
                    ? const Color(0xFF0077B6)
                    : const Color(0xFFE2E8F0),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            );
          }).toList(),
        ),

        const SizedBox(height: 28),
        const Text(
          'Nhịp độ chuyến đi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Điều chỉnh số lượng hoạt động trong từng ngày',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 12),

        // Pace options cards
        ..._paceOptions.map((opt) {
          final id = opt['id'] as String;
          final isSelected = selectedPace == id;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => onPaceChanged(id),
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFEDF6F9) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF0077B6)
                        : const Color(0xFFE2E8F0),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF0077B6)
                            : const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        opt['icon'] as IconData,
                        size: 20,
                        color: isSelected ? Colors.white : const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            opt['title'] as String,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight:
                                  isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            opt['subtitle'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF0077B6),
                        size: 22,
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
