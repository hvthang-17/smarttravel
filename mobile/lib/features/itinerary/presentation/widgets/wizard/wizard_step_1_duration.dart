import 'package:flutter/material.dart';

class WizardStep1Duration extends StatelessWidget {
  final int selectedDays;
  final DateTime startDate;
  final ValueChanged<int> onDaysChanged;
  final ValueChanged<DateTime> onDateChanged;

  const WizardStep1Duration({
    super.key,
    required this.selectedDays,
    required this.startDate,
    required this.onDaysChanged,
    required this.onDateChanged,
  });

  static const List<Map<String, dynamic>> _durationOptions = [
    {
      'days': 1,
      'title': '1 ngày',
      'subtitle': 'Đi về trong ngày, tập trung điểm nổi bật',
    },
    {
      'days': 2,
      'title': '2 ngày 1 đêm',
      'subtitle': 'Phù hợp đi cuối tuần ngắn ngày',
    },
    {
      'days': 3,
      'title': '3 ngày 2 đêm',
      'subtitle': 'Lựa chọn phổ biến nhất, khám phá trọn vẹn',
    },
    {
      'days': 4,
      'title': '4 ngày 3 đêm',
      'subtitle': 'Thoải mái trải nghiệm văn hóa và ẩm thực',
    },
    {
      'days': 5,
      'title': '5 ngày 4 đêm',
      'subtitle': 'Kỳ nghỉ dài, kết hợp Hội An & Bà Nà',
    },
  ];

  Future<void> _selectStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('vi', 'VN'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0077B6),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child ?? const SizedBox(),
        );
      },
    );
    if (picked != null) {
      onDateChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        '${startDate.day.toString().padLeft(2, '0')}/${startDate.month.toString().padLeft(2, '0')}/${startDate.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bạn đi Đà Nẵng mấy ngày?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Chọn số ngày và thời điểm khởi hành chuyến đi',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 20),

        // Date selection card
        InkWell(
          onTap: () => _selectStartDate(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: Color(0xFF0077B6),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ngày khởi hành',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  color: Color(0xFF475569),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 18),
        const Text(
          'Thời lượng chuyến đi',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),

        // Duration option cards
        ..._durationOptions.map((opt) {
          final days = opt['days'] as int;
          final isSelected = selectedDays == days;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => onDaysChanged(days),
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
                        Icons.calendar_month_outlined,
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
                              fontSize: 16,
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
