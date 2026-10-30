import 'package:flutter/material.dart';
import 'package:smarttravel_mobile/core/theme/app_theme.dart';
import 'package:smarttravel_mobile/features/itinerary/data/models/itinerary_model.dart';

class ItineraryDailySummaryCard extends StatelessWidget {
  final ItineraryDayModel day;
  final int totalDays;
  final int maxBudgetVnd;

  const ItineraryDailySummaryCard({
    super.key,
    required this.day,
    required this.totalDays,
    required this.maxBudgetVnd,
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
    final daysCount = totalDays > 0 ? totalDays : 1;
    final dailyBudgetLimit = maxBudgetVnd ~/ daysCount;
    final percent = dailyBudgetLimit > 0
        ? (day.dayCostVnd * 100 / dailyBudgetLimit).clamp(0, 150).toDouble()
        : 0.0;
    final isOver = percent > 100;
    final isWarning = percent >= 85 && !isOver;
    final healthColor = isOver
        ? AppTheme.statusError
        : isWarning
            ? AppTheme.statusWarning
            : AppTheme.statusSuccess;

    final hours = day.totalDurationMinutes ~/ 60;
    final mins = day.totalDurationMinutes % 60;
    final timeFormatted = hours > 0 ? '${hours}h ${mins}p' : '${mins}p';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildStatColumn(
                icon: Icons.credit_card_outlined,
                label: 'Chi phí',
                value: '${_formatVnd(day.dayCostVnd)} VNĐ',
              ),
              Container(width: 1, height: 32, color: AppTheme.surfaceSubtle),
              _buildStatColumn(
                icon: Icons.navigation_outlined,
                label: 'Quãng đường',
                value: '${day.totalDistanceKm.toStringAsFixed(1)} km',
              ),
              Container(width: 1, height: 32, color: AppTheme.surfaceSubtle),
              _buildStatColumn(
                icon: Icons.schedule,
                label: 'Thời gian',
                value: timeFormatted,
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppTheme.surfaceSubtle),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(color: healthColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        isOver
                            ? 'Vượt hạn mức ngân sách ngày'
                            : isWarning
                                ? 'Gần chạm hạn mức ngân sách'
                                : 'Trong hạn mức ngân sách ngày',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${percent.toStringAsFixed(0)}% (${(day.dayCostVnd / 1000).toStringAsFixed(0)}k / ${(dailyBudgetLimit / 1000).toStringAsFixed(0)}k)',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: healthColor),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (percent / 100.0).clamp(0.0, 1.0),
              backgroundColor: AppTheme.borderSubtle,
              valueColor: AlwaysStoppedAnimation<Color>(healthColor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: AppTheme.primaryBlue),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
