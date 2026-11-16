import 'package:smarttravel_mobile/core/localization/app_language.dart';
import 'package:flutter/material.dart';
import 'package:smarttravel_mobile/features/auth/data/repositories/auth_repository.dart';

class PasswordResetDialog extends StatefulWidget {
  const PasswordResetDialog({super.key, required this.repository, required this.email});
  final AuthRepository repository;
  final String email;

  @override
  State<PasswordResetDialog> createState() => _PasswordResetDialogState();
}

class _PasswordResetDialogState extends State<PasswordResetDialog> {
  late final _email = TextEditingController(text: widget.email);
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _codeStep = false;
  bool _busy = false;
  String? _message;

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    if (!_codeStep && !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(_email.text.trim())) {
      setState(() => _message = 'Nhập địa chỉ email hợp lệ.');
      return;
    }
    if (_codeStep && (!RegExp(r'^[A-Za-z0-9_-]{43}$').hasMatch(_code.text.trim()) ||
        _password.text.length < 8 || _password.text != _confirmation.text)) {
      setState(() => _message = 'Kiểm tra mã và nhập hai mật khẩu khớp nhau, ít nhất 8 ký tự.');
      return;
    }
    setState(() { _busy = true; _message = null; });
    try {
      if (_codeStep) {
        await widget.repository.resetPassword(_code.text.trim(), _password.text);
        if (mounted) Navigator.of(context).pop(true);
      } else {
        await widget.repository.requestPasswordReset(_email.text.trim());
        if (mounted) {
          setState(() {
            _codeStep = true;
            _message = 'Nếu email đủ điều kiện, bạn sẽ nhận được mã. Kiểm tra cả thư rác.';
          });
        }
      }
    } catch (error) {
      if (mounted) setState(() => _message = error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: AlertDialog(
      title: const AppText('Đặt lại mật khẩu'),
      scrollable: true,
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        if (!_codeStep)
          TextField(controller: _email, enabled: !_busy, keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(label: AppText('Email tài khoản')))
        else ...[
          TextField(controller: _code, enabled: !_busy, autocorrect: false,
            decoration: const InputDecoration(label: AppText('Mã trong email'))),
          TextField(controller: _password, enabled: !_busy, obscureText: true,
            decoration: const InputDecoration(label: AppText('Mật khẩu mới'))),
          TextField(controller: _confirmation, enabled: !_busy, obscureText: true,
            decoration: const InputDecoration(label: AppText('Nhập lại mật khẩu mới'))),
        ],
        if (_message != null) Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Semantics(liveRegion: true, child: AppText(_message!)),
        ),
      ]),
      actions: [
        TextButton(onPressed: _busy ? null : () => Navigator.of(context).pop(), child: const AppText('Hủy')),
        TextButton(onPressed: _busy ? null : () => setState(() {
          _codeStep = !_codeStep;
          _message = null;
        }), child: AppText(_codeStep ? 'Đổi email hoặc gửi lại' : 'Tôi đã có mã')),
        FilledButton(onPressed: _busy ? null : _submit,
          child: AppText(_busy ? 'Đang xử lý…' : _codeStep ? 'Đổi mật khẩu' : 'Gửi mã')),
      ],
    ),
  );
}
