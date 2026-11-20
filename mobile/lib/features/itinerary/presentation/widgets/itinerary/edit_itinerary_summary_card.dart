import 'package:smarttravel_mobile/core/localization/app_language.dart';
import 'package:flutter/material.dart';
import 'package:smarttravel_mobile/core/theme/app_theme.dart';

class EditItinerarySummaryCard extends StatelessWidget {
  final int dayNumber;
  final int placesCount;
  final int dayCostVnd;
  final bool costComplete;
  final bool saving;

  const EditItinerarySummaryCard({
    super.key,
    required this.dayNumber,
    required this.placesCount,
    required this.dayCostVnd,
    this.costComplete = false,
    this.saving = false,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: AppText('Ngày $dayNumber',
              style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildStatColumn('Số địa điểm', '$placesCount điểm đến'),
              _buildStatColumn(saving ? 'Chi phí đã lưu' : costComplete ? 'Ước tính chi phí' : 'Chi phí đã biết', '${_formatVnd(dayCostVnd)} VNĐ'),
              _buildStatColumn('Thời gian di chuyển', saving ? 'Đang tính lại' : 'Tính lại khi lưu'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
        const SizedBox(height: 2),
        AppText(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
