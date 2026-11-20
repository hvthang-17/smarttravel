import 'package:smarttravel_mobile/core/localization/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smarttravel_mobile/features/auth/presentation/providers/auth_provider.dart';
import '../../../data/models/itinerary_model.dart';
import '../../../data/repositories/itinerary_repository.dart';
import '../../providers/itinerary_provider.dart';
import 'share_itinerary_dialog.dart';

enum _Action { edit, rename, copy, delete, share }

class TripActions extends ConsumerStatefulWidget {
  final ItineraryResponseModel trip;
  const TripActions({super.key, required this.trip});

  @override
  ConsumerState<TripActions> createState() => _TripActionsState();
}

class _TripActionsState extends ConsumerState<TripActions> {
  bool _busy = false;

  Future<void> _apply(_Action action) async {
    final trip = widget.trip;
    final token = ref.read(authNotifierProvider).token;
    if (_busy || token == null) return;
    if (action == _Action.edit) {
      await context.push('/itineraries/${trip.id}/edit');
      return;
    }
    if (action == _Action.share) {
      await ShareItineraryDialog.show(context, trip.id, trip.title);
      return;
    }
    final title = action == _Action.rename ? await _askTitle(trip.title) : null;
    if (action == _Action.rename && (title == null || title == trip.title)) return;
    if (!mounted || ref.read(authNotifierProvider).token != token) return;
    if (action == _Action.delete && !await _confirmDelete(trip.title)) return;
    if (!mounted || ref.read(authNotifierProvider).token != token) return;
    final repo = ref.read(itineraryRepositoryProvider);
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      switch (action) {
        case _Action.rename:
          await repo.renameTrip(trip.id, title!);
        case _Action.copy:
          final copy = await repo.copyTrip(trip.id);
          if (mounted && ref.read(authNotifierProvider).token == token) {
            router.push('/itineraries/${copy.id}');
          }
        case _Action.delete:
          await repo.deleteTrip(trip.id);
        case _Action.edit || _Action.share:
          return;
      }
      if (!mounted || ref.read(authNotifierProvider).token != token) return;
      ref.read(tripListsRevisionProvider.notifier).state++;
      messenger.showSnackBar(SnackBar(content: AppText(switch (action) {
        _Action.rename => 'Đã đổi tên chuyến đi.',
        _Action.copy => 'Đã tạo bản sao trong Bản nháp.',
        _Action.delete => 'Đã xóa chuyến đi.',
        _Action.edit || _Action.share => '',
      })));
    } catch (error) {
      if (mounted && ref.read(authNotifierProvider).token == token) {
        messenger.showSnackBar(SnackBar(content: AppText(error.toString().replaceFirst('Exception: ', ''))));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String?> _askTitle(String title) {
    final form = GlobalKey<FormState>();
    var current = title;
    return showDialog<String>(context: context, builder: (dialog) => AlertDialog(
      title: const AppText('Đổi tên chuyến đi'),
      content: Form(key: form, child: TextFormField(
        autofocus: true, initialValue: title, maxLength: 255,
        decoration: const InputDecoration(label: AppText('Tên chuyến đi')),
        onChanged: (value) => current = value,
        validator: (value) => value == null || value.trim().isEmpty ? 'Nhập tên chuyến đi' : null,
      )),
      actions: [
        TextButton(onPressed: () => Navigator.of(dialog).pop(), child: const AppText('Hủy')),
        FilledButton(onPressed: () {
          if (form.currentState!.validate()) Navigator.of(dialog).pop(current.trim());
        }, child: const AppText('Lưu tên')),
      ],
    ));
  }

  Future<bool> _confirmDelete(String title) async =>
      await showDialog<bool>(context: context, builder: (dialog) => AlertDialog(
        title: const AppText('Xóa chuyến đi?'),
        content: AppText('Lịch trình “$title” sẽ bị xóa và liên kết chia sẻ sẽ mất hiệu lực.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialog).pop(false), child: const AppText('Hủy')),
          FilledButton(onPressed: () => Navigator.of(dialog).pop(true), child: const AppText('Xóa chuyến đi')),
        ],
      )) ?? false;

  @override
  Widget build(BuildContext context) => _busy
      ? const SizedBox(width: 48, height: 48, child: Center(
          child: SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)),
        ))
      : PopupMenuButton<_Action>(
          tooltip: AppLanguage.text(context, 'Tùy chọn chuyến đi'),
          onSelected: _apply,
          itemBuilder: (_) => [
            const PopupMenuItem(value: _Action.edit, child: AppText('Chỉnh sửa lịch trình')),
            const PopupMenuItem(value: _Action.rename, child: AppText('Đổi tên')),
            const PopupMenuItem(value: _Action.copy, child: AppText('Sao chép chuyến đi')),
            if (widget.trip.status == 'SAVED')
              const PopupMenuItem(value: _Action.share, child: AppText('Chia sẻ')),
            const PopupMenuItem(value: _Action.delete, child: AppText('Xóa chuyến đi')),
          ],
        );
}
