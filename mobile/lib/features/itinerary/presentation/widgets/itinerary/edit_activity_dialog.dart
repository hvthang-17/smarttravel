import 'package:smarttravel_mobile/core/localization/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smarttravel_mobile/features/itinerary/data/models/itinerary_model.dart';

class EditActivityDialog extends StatefulWidget {
  final ItineraryItemModel item;
  const EditActivityDialog({super.key, required this.item});

  @override
  State<EditActivityDialog> createState() => _EditActivityDialogState();
}

class _EditActivityDialogState extends State<EditActivityDialog> {
  final _form = GlobalKey<FormState>();
  late final _time = TextEditingController(text: _originalTime);
  late final _duration = TextEditingController(text: widget.item.previewDurationMinutes?.toString());
  late final _note = TextEditingController(text: widget.item.notes);
  String? get _originalTime => widget.item.startTime?.split(':').take(2).join(':');

  @override
  void dispose() {
    _time.dispose();
    _duration.dispose();
    _note.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    final item = widget.item;
    final time = _time.text.trim();
    final duration = int.tryParse(_duration.text);
    Navigator.of(context).pop(item.edited(
      sequence: item.sequenceOrder,
      time: time == _originalTime ? item.startTime : time.isEmpty ? null : time,
      duration: duration == item.previewDurationMinutes ? item.durationMinutes : duration,
      note: _note.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const AppText('Sửa hoạt động'),
    content: SingleChildScrollView(
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _time,
              decoration: const InputDecoration(label: AppText('Giờ bắt đầu'), hint: AppText('HH:mm')),
              validator: (value) {
                final time = value?.trim() ?? '';
                return time.isEmpty || RegExp(r'^(?:[01]\d|2[0-3]):[0-5]\d$').hasMatch(time)
                    ? null : 'Nhập giờ theo dạng HH:mm';
              },
            ),
            TextFormField(
              controller: _duration,
              decoration: const InputDecoration(label: AppText('Thời lượng (phút)')),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) return null;
                final minutes = int.tryParse(value);
                return minutes != null && minutes >= 1 && minutes <= 1440
                    ? null : 'Nhập từ 1 đến 1440 phút';
              },
            ),
            TextFormField(
              controller: _note,
              decoration: const InputDecoration(label: AppText('Ghi chú')),
              minLines: 2,
              maxLines: 4,
              maxLength: 4000,
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.of(context).pop(), child: const AppText('Hủy')),
      FilledButton(onPressed: _submit, child: const AppText('Áp dụng')),
    ],
  );
}
