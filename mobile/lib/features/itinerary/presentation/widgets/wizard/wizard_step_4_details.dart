import 'package:flutter/material.dart';

class WizardStep4Details extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController startingPointController;
  final String selectedTransport;
  final ValueChanged<String> onTransportChanged;
  final int totalDays;
  final int travelersCount;
  final int budgetVnd;
  final String pace;

  const WizardStep4Details({
    super.key,
    required this.titleController,
    required this.startingPointController,
    required this.selectedTransport,
    required this.onTransportChanged,
    required this.totalDays,
    required this.travelersCount,
    required this.budgetVnd,
    required this.pace,
  });

  static const List<String> _transportOptions = [
    'Xe máy',
    'Ô tô / Taxi',
    'Đi bộ kết hợp',
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

  String _getPaceLabel(String p) {
    switch (p) {
      case 'relaxed':
        return 'Thư thả';
      case 'packed':
        return 'Năng động';
      default:
        return 'Cân bằng';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thông tin bổ sung',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Tùy chỉnh thông tin để thuật toán sắp xếp tuyến đường phù hợp nhất',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 20),

        // Trip Title
        const Text(
          'Tên chuyến đi',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: titleController,
          decoration: InputDecoration(
            hintText: 'Ví dụ: Du lịch Đà Nẵng cùng bạn bè',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF0077B6), width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),

        const SizedBox(height: 18),

        // Starting point / Hotel
        const Text(
          'Nơi lưu trú / Điểm xuất phát (tùy chọn)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: startingPointController,
          decoration: InputDecoration(
            hintText: 'Ví dụ: Khách sạn Novotel Đà Nẵng, Sơn Trà...',
            helperText: 'Tối ưu hoá các điểm đến xuất phát từ nơi ở của bạn',
            helperStyle: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF0077B6), width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),

        const SizedBox(height: 18),

        // Transport
        const Text(
          'Phương tiện di chuyển chính',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _transportOptions.map((opt) {
            final isSelected = selectedTransport == opt;
            return ChoiceChip(
              label: Text(opt),
              selected: isSelected,
              onSelected: (_) => onTransportChanged(opt),
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

        const SizedBox(height: 24),

        // Summary Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEDF6F9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF0077B6).withAlpha(60)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: Color(0xFF0077B6),
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Tóm tắt thông số chuyến đi',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0077B6),
                    ),
                  ),
                ],
              ),
              const Divider(height: 18, color: Color(0xFFE2E8F0)),
              _buildSummaryRow('Thời lượng', '$totalDays ngày'),
              _buildSummaryRow('Số lượng khách', '$travelersCount người'),
              _buildSummaryRow('Ngân sách tối đa', '${_formatVnd(budgetVnd)} đ'),
              _buildSummaryRow('Nhịp độ lịch trình', _getPaceLabel(pace)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}
