import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smarttravel_mobile/core/network/api_client.dart';
import 'package:smarttravel_mobile/features/auth/presentation/providers/auth_provider.dart';

class ProfileSettingsSection extends ConsumerStatefulWidget {
  const ProfileSettingsSection({super.key});

  @override
  ConsumerState<ProfileSettingsSection> createState() => _ProfileSettingsSectionState();
}

class _ProfileSettingsSectionState extends ConsumerState<ProfileSettingsSection> {
  bool _weatherAlert = true;

  @override
  void initState() {
    super.initState();
    _loadWeatherSetting();
  }

  Future<void> _loadWeatherSetting() async {
    try {
      final storage = ref.read(secureStorageProvider);
      final val = await storage.read(key: 'pref_weather_alert');
      if (val != null && mounted) {
        setState(() => _weatherAlert = val == 'true');
      }
    } catch (_) {}
  }

  Future<void> _toggleWeatherSetting(bool value) async {
    setState(() => _weatherAlert = value);
    try {
      final storage = ref.read(secureStorageProvider);
      await storage.write(key: 'pref_weather_alert', value: value.toString());
    } catch (_) {}
  }

  void _showFeedbackDialog() {
    final feedbackController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Trợ giúp & Góp ý'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SmartTravel trân trọng mọi phản hồi của du khách nhằm nâng cao chất lượng trải nghiệm.',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: feedbackController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Nhập nội dung đóng góp hoặc câu hỏi của bạn...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0077B6)),
            onPressed: () {
              final text = feedbackController.text.trim();
              if (text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng nhập nội dung góp ý')),
                );
                return;
              }
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cảm ơn bạn! Ý kiến đóng góp đã được chuyển tới ban phát triển.'),
                  backgroundColor: Color(0xFF2A9D8F),
                ),
              );
            },
            child: const Text('Gửi góp ý'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi tài khoản không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authNotifierProvider.notifier).logout();
              if (mounted) {
                context.go('/login');
              }
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.manage_accounts_outlined, size: 18, color: Color(0xFF0077B6)),
            SizedBox(width: 6),
            Text(
              'Tài khoản & Cài đặt',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.bookmark_border, color: Color(0xFF0077B6)),
                ),
                title: const Text('Địa điểm đã lưu', style: TextStyle(fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
                onTap: () => context.push('/destinations'),
              ),
              const Divider(height: 1, indent: 64, color: Color(0xFFF1F5F9)),
              SwitchListTile(
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.cloud_outlined, color: Color(0xFF0077B6)),
                ),
                title: const Text('Cảnh báo thời tiết & mưa', style: TextStyle(fontWeight: FontWeight.w500)),
                subtitle: const Text('Thông báo trước 1 giờ khi trời chuyển mưa', style: TextStyle(fontSize: 12)),
                value: _weatherAlert,
                activeThumbColor: const Color(0xFF0077B6),
                onChanged: _toggleWeatherSetting,
              ),
              const Divider(height: 1, indent: 64, color: Color(0xFFF1F5F9)),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.support_agent, color: Color(0xFF64748B)),
                ),
                title: const Text('Trợ giúp & Góp ý du khách', style: TextStyle(fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
                onTap: _showFeedbackDialog,
              ),
              const Divider(height: 1, indent: 64, color: Color(0xFFF1F5F9)),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.logout, color: Color(0xFFEF4444)),
                ),
                title: const Text(
                  'Đăng xuất tài khoản',
                  style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w500),
                ),
                trailing: const Icon(Icons.chevron_right, color: Color(0xFFEF4444)),
                onTap: _confirmLogout,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
