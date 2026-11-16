import 'package:smarttravel_mobile/core/localization/app_language.dart';
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
  void _showQuickSettingsDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const AppText('Cài đặt ứng dụng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText('Phiên bản: SmartTravel v1.0.0', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            const AppText('Dữ liệu điểm đến: Đà Nẵng, Việt Nam', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
            const SizedBox(height: 8),
            AppText(ref.read(authNotifierProvider).travelerProfile?.language == 'en' ? 'Ngôn ngữ ưu tiên: English' : 'Ngôn ngữ ưu tiên: Tiếng Việt', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const AppText('Đóng'),
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
        title: const AppText('Hồ sơ cá nhân'),
        actions: [
          IconButton(
            tooltip: AppLanguage.text(context, 'Cài đặt'),
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
                ),
                const SizedBox(height: 16),
                const ProfileStatsRow(),
                const SizedBox(height: 24),
                ProfileTravelPreferences(key: ValueKey(authState.token)),
                const SizedBox(height: 24),
                ProfileSettingsSection(key: ValueKey(authState.token)),
                const SizedBox(height: 32),
              ],
            )
          : const ProfileGuestView(),
    );
  }
}
