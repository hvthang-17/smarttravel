import 'package:smarttravel_mobile/core/localization/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarttravel_mobile/features/auth/presentation/providers/auth_provider.dart';

class DeleteAccountDialog extends ConsumerStatefulWidget {
  const DeleteAccountDialog({super.key});

  @override
  ConsumerState<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends ConsumerState<DeleteAccountDialog> {
  final _password = TextEditingController();
  bool _confirmed = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    if (!_confirmed || _busy) return;
    if (_password.text.isEmpty) {
      setState(() => _error = 'Nhập mật khẩu hiện tại.');
      return;
    }
    setState(() { _busy = true; _error = null; });
    try {
      await ref.read(authNotifierProvider.notifier).deleteAccount(_password.text);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: AlertDialog(
      title: const AppText('Xóa tài khoản'),
      scrollable: true,
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const AppText('Hồ sơ, địa điểm yêu thích, đánh giá và lịch trình của bạn sẽ bị xóa. Liên kết chia sẻ sẽ ngừng hoạt động.'),
        const SizedBox(height: 12),
        TextField(controller: _password, enabled: !_busy, obscureText: true,
          decoration: const InputDecoration(label: AppText('Mật khẩu hiện tại'))),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: const AppText('Tôi xác nhận xóa vĩnh viễn'),
          value: _confirmed,
          onChanged: _busy ? null : (value) => setState(() => _confirmed = value == true),
        ),
        if (_error != null) Semantics(liveRegion: true, child: AppText(_error!)),
      ]),
      actions: [
        TextButton(onPressed: _busy ? null : () => Navigator.of(context).pop(), child: const AppText('Hủy')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError),
          onPressed: _busy || !_confirmed ? null : _delete,
          child: AppText(_busy ? 'Đang xóa…' : 'Xóa tài khoản'),
        ),
      ],
    ),
  );
}
