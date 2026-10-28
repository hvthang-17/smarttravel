import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarttravel_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:smarttravel_mobile/features/profile/presentation/widgets/profile_guest_view.dart';
import 'package:smarttravel_mobile/features/profile/presentation/widgets/profile_header_card.dart';
import 'package:smarttravel_mobile/features/profile/presentation/widgets/profile_settings_section.dart';
import 'package:smarttravel_mobile/features/profile/presentation/widgets/profile_stats_row.dart';
import 'package:smarttravel_mobile/features/profile/presentation/widgets/profile_travel_preferences.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Set<String> _selectedInterests = {
    'Biển & Nghỉ dưỡng',
    'Ẩm thực đường phố',
    'Check-in & Sống ảo',
  };

  void _showNotificationsSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.notifications_active, color: Color(0xFF0077B6)),
                SizedBox(width: 8),
                Text('Thông báo & Cập nhật', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE0F2FE),
                child: Icon(Icons.wb_sunny, color: Color(0xFF0077B6), size: 20),
              ),
              title: const Text('Thời tiết Đà Nẵng hôm nay', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: const Text('Trời nắng nhẹ, thuận lợi tham quan Bán đảo Sơn Trà và Bà Nà Hills.', style: TextStyle(fontSize: 12)),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFFEF3C7),
                child: Icon(Icons.event, color: Color(0xFFD97706), size: 20),
              ),
              title: const Text('Cầu Rồng phun lửa cuối tuần', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: const Text('21:00 Thứ Bảy & Chủ Nhật hàng tuần tại bờ Đông Cầu Rồng.', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickSettingsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cài đặt ứng dụng'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phiên bản: SmartTravel v1.0.0', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            SizedBox(height: 8),
            Text('Dữ liệu điểm đến: Đà Nẵng, Việt Nam', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
            SizedBox(height: 8),
            Text('Ngôn ngữ: Tiếng Việt (Mặc định)', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân'),
        actions: [
          IconButton(
            tooltip: 'Thông báo',
            icon: const Icon(Icons.notifications_none_outlined),
            onPressed: _showNotificationsSheet,
          ),
          IconButton(
            tooltip: 'Cài đặt',
            icon: const Icon(Icons.settings_outlined),
            onPressed: _showQuickSettingsDialog,
          ),
        ],
      ),
      body: authState.isAuthenticated
          ? ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                ProfileHeaderCard(
                  authState: authState,
                  selectedInterests: _selectedInterests,
                ),
                const SizedBox(height: 16),
                const ProfileStatsRow(),
                const SizedBox(height: 24),
                ProfileTravelPreferences(
                  initialInterests: _selectedInterests,
                  onInterestsChanged: (updated) => setState(() => _selectedInterests = updated),
                ),
                const SizedBox(height: 24),
                const ProfileSettingsSection(),
                const SizedBox(height: 32),
              ],
            )
          : const ProfileGuestView(),
    );
  }
}
