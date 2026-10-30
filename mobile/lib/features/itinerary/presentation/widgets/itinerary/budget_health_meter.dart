import 'package:flutter/material.dart';

class BudgetHealthMeter extends StatelessWidget {
  final int totalEstimatedCost;
  final int maxBudgetVnd;
  final double budgetUtilizationPercent;
  final String budgetHealth;
  final Map<String, int> categoryBreakdown;
  final VoidCallback? onAdjustBudget;

  const BudgetHealthMeter({
    super.key,
    required this.totalEstimatedCost,
    required this.maxBudgetVnd,
    required this.budgetUtilizationPercent,
    required this.budgetHealth,
    this.categoryBreakdown = const {},
    this.onAdjustBudget,
  });

  static const Color greenSafe = Color(0xFF2A9D8F);
  static const Color yellowWarning = Color(0xFFE9C46A);
  static const Color redOverbudget = Color(0xFFE76F51);

  Color get _statusColor {
    if (budgetHealth == 'OVERBUDGET' || budgetUtilizationPercent > 100.0) {
      return redOverbudget;
    } else if (budgetHealth == 'WARNING' || budgetUtilizationPercent >= 85.0) {
      return yellowWarning;
    }
    return greenSafe;
  }

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
    final isOverbudget =
        budgetHealth == 'OVERBUDGET' || budgetUtilizationPercent > 100.0;
    final isWarning =
        budgetHealth == 'WARNING' || (budgetUtilizationPercent >= 85.0 && !isOverbudget);
    final remainingVnd = maxBudgetVnd - totalEstimatedCost;
    final progressValue = (totalEstimatedCost / (maxBudgetVnd > 0 ? maxBudgetVnd : 1)).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOverbudget ? redOverbudget : const Color(0xFFE2E8F0),
          width: isOverbudget ? 1.5 : 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 20,
                      color: Color(0xFF0077B6),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Ngân sách chuyến đi',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF2F7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'ƯỚC TÍNH',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Big number: Used / Max
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${_formatVnd(totalEstimatedCost)} ',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: isOverbudget ? redOverbudget : const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  '/ ${_formatVnd(maxBudgetVnd)} VNĐ',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progressValue,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(_statusColor),
              minHeight: 8,
            ),
          ),

          const SizedBox(height: 8),

          // Status & Remaining
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${budgetUtilizationPercent.toStringAsFixed(1)}% ngân sách',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _statusColor,
                ),
              ),
              Text(
                isOverbudget
                    ? 'Vượt: ${_formatVnd(-remainingVnd)} VNĐ'
                    : 'Còn lại: ${_formatVnd(remainingVnd)} VNĐ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isOverbudget ? redOverbudget : greenSafe,
                ),
              ),
            ],
          ),

          // Overbudget Warning Banner (US-04, US-05)
          if (isOverbudget) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF2F0),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: redOverbudget),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: redOverbudget,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cảnh báo vượt ngân sách dự kiến',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: redOverbudget,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tổng chi phí vượt ${_formatVnd(-remainingVnd)} VNĐ so với hạn mức ban đầu. Hãy cân nhắc điều chỉnh hoặc tăng ngân sách.',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else if (isWarning) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF9E7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: yellowWarning),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Color(0xFFB45309),
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Chi phí đã chạm ngưỡng ≥ 85% hạn mức.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFB45309),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Category breakdown mini preview
          if (categoryBreakdown.isNotEmpty) ...[
            const Divider(height: 24, color: Color(0xFFE2E8F0)),
            const Text(
              'Phân bổ theo danh mục:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: categoryBreakdown.entries.map((entry) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${entry.key}: ${_formatVnd(entry.value)} đ',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF475569),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
