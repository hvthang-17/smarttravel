import 'package:smarttravel_mobile/core/localization/app_language.dart';
import 'delete_account_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smarttravel_mobile/features/auth/presentation/providers/auth_provider.dart';

class ProfileSettingsSection extends ConsumerStatefulWidget {
  const ProfileSettingsSection({super.key});

  @override
  ConsumerState<ProfileSettingsSection> createState() => _ProfileSettingsSectionState();
}

class _ProfileSettingsSectionState extends ConsumerState<ProfileSettingsSection> {
  void _confirmLogout() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const AppText('Đăng xuất'),
        content: const AppText('Bạn có chắc chắn muốn đăng xuất khỏi tài khoản không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const AppText('Hủy'),
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
            child: const AppText('Đăng xuất'),
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
            AppText(
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
                leading: const Icon(Icons.delete_outline),
                title: const AppText('Xóa tài khoản'),
                onTap: () async {
                  final router = GoRouter.of(context);
                  final deleted = await showDialog<bool>(context: context, barrierDismissible: false,
                    builder: (_) => const DeleteAccountDialog());
                  if (deleted == true) router.go('/login');
                },
              ),

              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.bookmark_border, color: Color(0xFF0077B6)),
                ),
                title: const AppText('Địa điểm đã lưu', style: TextStyle(fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
                onTap: () => context.push('/favorites'),
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
                title: const AppText(
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
