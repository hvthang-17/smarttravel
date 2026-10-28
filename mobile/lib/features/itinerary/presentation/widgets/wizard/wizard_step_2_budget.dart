import 'package:flutter/material.dart';

class WizardStep2Budget extends StatelessWidget {
  final int budgetVnd;
  final int travelersCount;
  final ValueChanged<int> onBudgetChanged;
  final ValueChanged<int> onTravelersChanged;

  const WizardStep2Budget({
    super.key,
    required this.budgetVnd,
    required this.travelersCount,
    required this.onBudgetChanged,
    required this.onTravelersChanged,
  });

  static const List<int> _presetBudgets = [
    2000000,
    3500000,
    5000000,
    8000000,
    12000000,
  ];

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
    final perPerson = travelersCount > 0 ? (budgetVnd / travelersCount).round() : budgetVnd;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ngân sách và số người',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Ước tính chi phí tối đa và quy mô nhóm cho chuyến đi',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 24),

        // Stepper for Travelers Count
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFEDF6F9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.group_outlined,
                  size: 20,
                  color: Color(0xFF0077B6),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Số người đi cùng',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$travelersCount người',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              // Stepper buttons
              Row(
                children: [
                  InkWell(
                    onTap: travelersCount > 1
                        ? () => onTravelersChanged(travelersCount - 1)
                        : null,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: travelersCount > 1
                            ? const Color(0xFFF1F5F9)
                            : const Color(0xFFF8F9FA),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Icon(
                        Icons.remove,
                        size: 20,
                        color: travelersCount > 1
                            ? const Color(0xFF0F172A)
                            : const Color(0xFFCBD5E1),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 36,
                    child: Text(
                      '$travelersCount',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: travelersCount < 20
                        ? () => onTravelersChanged(travelersCount + 1)
                        : null,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 20,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Budget Field
        const Text(
          'Ngân sách dự kiến',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF0077B6), width: 1.5),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                color: Color(0xFF0077B6),
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _formatVnd(budgetVnd),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              const Text(
                'VNĐ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ước tính: ~${_formatVnd(perPerson)} đ / người',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),
        const Text(
          'Chọn nhanh mức ngân sách:',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 8),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _presetBudgets.map((preset) {
            final isSelected = budgetVnd == preset;
            return ChoiceChip(
              label: Text('${_formatVnd(preset)} đ'),
              selected: isSelected,
              onSelected: (_) => onBudgetChanged(preset),
              selectedColor: const Color(0xFFEDF6F9),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? const Color(0xFF0077B6)
                    : const Color(0xFF475569),
              ),
              side: BorderSide(
                color: isSelected
                    ? const Color(0xFF0077B6)
                    : const Color(0xFFE2E8F0),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
