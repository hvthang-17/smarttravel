import 'package:smarttravel_mobile/core/localization/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarttravel_mobile/features/auth/data/models/user_model.dart';
import 'package:smarttravel_mobile/features/auth/presentation/providers/auth_provider.dart';

class EditProfileBottomSheet extends ConsumerStatefulWidget {
  final UserState userState;
  const EditProfileBottomSheet({super.key, required this.userState});

  static Future<void> show(BuildContext context, UserState userState) =>
      showModalBottomSheet<void>(context: context, isScrollControlled: true,
        builder: (_) => EditProfileBottomSheet(userState: userState));

  @override
  ConsumerState<EditProfileBottomSheet> createState() => _EditProfileBottomSheetState();
}

class _EditProfileBottomSheetState extends ConsumerState<EditProfileBottomSheet> {
  final _form = GlobalKey<FormState>();
  late String _name = widget.userState.fullName ?? '';
  bool _saving = false;
  String? _error;

  Future<void> _save() async {
    if (!_form.currentState!.validate() || _saving) return;
    setState(() { _saving = true; _error = null; });
    try {
      await ref.read(authNotifierProvider.notifier).updateProfile(fullName: _name.trim());
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(const SnackBar(content: AppText('Đã cập nhật họ và tên.')));
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error.toString().replaceFirst('Exception: ', '');
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(top: false, child: SingleChildScrollView(
    padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.viewInsetsOf(context).bottom),
    child: Form(key: _form, child: Column(mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        AppText('Đổi họ và tên', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _name, enabled: !_saving, maxLength: 150,
          decoration: const InputDecoration(label: AppText('Họ và tên')),
          onChanged: (value) => _name = value,
          validator: (value) => (value?.trim().length ?? 0) < 2 ? 'Nhập ít nhất 2 ký tự.' : null,
        ),
        if (_error != null) AppText(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        FilledButton(onPressed: _saving ? null : _save, child: AppText(_saving ? 'Đang lưu…' : 'Lưu họ và tên')),
      ],
    )),
  ));
}
