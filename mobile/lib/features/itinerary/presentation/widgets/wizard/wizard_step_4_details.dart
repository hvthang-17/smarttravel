import 'package:smarttravel_mobile/core/localization/app_language.dart';
import 'package:smarttravel_mobile/features/auth/data/models/traveler_profile.dart';
import 'package:flutter/material.dart';

class WizardStep4Details extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController startingPointController;
  final TextEditingController latitudeController;
  final TextEditingController longitudeController;
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
    required this.latitudeController,
    required this.longitudeController,
    required this.selectedTransport,
    required this.onTransportChanged,
    required this.totalDays,
    required this.travelersCount,
    required this.budgetVnd,
    required this.pace,
  });

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
        const AppText(
          'Thông tin bổ sung',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 6),
        const AppText(
          'Nhập tên chuyến, điểm xuất phát và phương tiện dự kiến.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 20),

        // Trip Title
        const AppText(
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
          maxLength: 255,
          decoration: InputDecoration(
            hint: const AppText('Ví dụ: Du lịch Đà Nẵng cùng bạn bè'),
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
        const AppText(
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
          maxLength: 255,
          decoration: InputDecoration(
            hint: const AppText('Ví dụ: Nơi ở tại Sơn Trà'),
            helper: const AppText('Dùng làm điểm xuất phát của chuyến đi'),
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

        const AppText('Tọa độ điểm xuất phát (tùy chọn)'),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: TextField(controller: latitudeController,
            keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
            decoration: const InputDecoration(label: AppText('Vĩ độ')))),
          const SizedBox(width: 12),
          Expanded(child: TextField(controller: longitudeController,
            keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
            decoration: const InputDecoration(label: AppText('Kinh độ')))),
        ]),
        const SizedBox(height: 18),

        // Transport
        const AppText(
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
          children: travelerTransports.keys.map((opt) {
            final isSelected = selectedTransport == opt;
            return ChoiceChip(
              label: AppText(travelerTransports[opt]!),
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
                  Flexible(
                    child: AppText(
                      'Tóm tắt chuyến đi',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0077B6),
                      ),
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
          Flexible(
            child: AppText(
              label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: AppText(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
