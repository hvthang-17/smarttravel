import 'package:flutter/material.dart';
import 'package:smarttravel_mobile/core/theme/app_theme.dart';

class EditItinerarySummaryCard extends StatelessWidget {
  final int dayNumber;
  final int placesCount;
  final int dayCostVnd;

  const EditItinerarySummaryCard({
    super.key,
    required this.dayNumber,
    required this.placesCount,
    required this.dayCostVnd,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.bar_chart, color: AppTheme.primaryBlue, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Tổng quan Ngày $dayNumber sau chỉnh sửa',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Tự động cập nhật',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0284C7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatColumn('Số địa điểm', '$placesCount điểm đến'),
              _buildStatColumn('Ước tính chi phí', '${_formatVnd(dayCostVnd)} VNĐ'),
              _buildStatColumn('Thời gian di chuyển', '~${(placesCount * 1.5).toStringAsFixed(1)} giờ'),
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
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
        const SizedBox(height: 2),
        Text(
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
