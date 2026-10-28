import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smarttravel_mobile/core/theme/app_theme.dart';

class MyTripsEmptyState extends StatelessWidget {
  const MyTripsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xFFE0F2FE),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.luggage_outlined, size: 32, color: AppTheme.primaryBlue),
          ),
          const SizedBox(height: 16),
          const Text(
            'Chưa có lịch trình nào',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Lên kế hoạch thông minh cho chuyến đi Đà Nẵng của bạn ngay bây giờ!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
            onPressed: () => context.push('/trip-wizard'),
            icon: const Icon(Icons.auto_awesome, size: 16),
            label: const Text('Bắt đầu tạo lịch trình'),
          ),
        ],
      ),
    );
  }
}
