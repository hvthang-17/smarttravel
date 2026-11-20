import 'package:smarttravel_mobile/core/localization/app_language.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarttravel_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:smarttravel_mobile/features/itinerary/data/models/trip_management_models.dart';
import 'package:smarttravel_mobile/features/itinerary/data/repositories/itinerary_repository.dart';

class ShareItineraryDialog extends ConsumerStatefulWidget {
  final int itineraryId;
  final String title;

  const ShareItineraryDialog({super.key, required this.itineraryId, required this.title});

  static Future<void> show(BuildContext context, int itineraryId, String title) => showDialog<void>(
    context: context,
    builder: (_) => ShareItineraryDialog(itineraryId: itineraryId, title: title),
  );

  @override
  ConsumerState<ShareItineraryDialog> createState() => _ShareItineraryDialogState();
}

class _ShareItineraryDialogState extends ConsumerState<ShareItineraryDialog> {
  TripShareLink? _link;
  bool _busy = false;
  String? _error;
  Timer? _expiry;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _expiry?.cancel();
    super.dispose();
  }

  void _load() => _run((repo) => repo.shareStatus(widget.itineraryId));

  Future<void> _run(Future<TripShareLink> Function(ItineraryRepository) action) async {
    if (_busy) return;
    final token = ref.read(authNotifierProvider).token;
    setState(() { _busy = true; _error = null; });
    try {
      final link = await action(ref.read(itineraryRepositoryProvider));
      if (!mounted || ref.read(authNotifierProvider).token != token) return;
      _expiry?.cancel();
      final remaining = link.expiresAt?.difference(DateTime.now());
      if (remaining != null && remaining > Duration.zero) {
        _expiry = Timer(remaining, () { if (mounted) setState(() {}); });
      }
      setState(() => _link = link);
    } catch (error) {
      if (mounted && ref.read(authNotifierProvider).token == token) {
        setState(() {
          _link = null;
          _error = error.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted && ref.read(authNotifierProvider).token == token) setState(() => _busy = false);
    }
  }

  bool get _active => _link?.url != null && _link?.expiresAt?.isAfter(DateTime.now()) == true;

  Future<void> _copy() async {
    if (!_active) return;
    await Clipboard.setData(ClipboardData(text: _link!.url.toString()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: AppText('Đã sao chép liên kết.')));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authNotifierProvider.select((user) => user.token), (_, __) {
      if (mounted) Navigator.of(context).pop();
    });
    final active = _active;
    final expired = _link?.state == 'EXPIRED' || (_link?.state == 'ACTIVE' && !active);
    return AlertDialog(
      title: const AppText('Chia sẻ chuyến đi'),
      scrollable: true,
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        AppText(widget.title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        const AppText('Ai có liên kết đều xem được lịch trình. Liên kết hết hạn sau 7 ngày.'),
        const SizedBox(height: 12),
        if (_busy)
          const LinearProgressIndicator()
        else if (_error != null)
          AppText(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error))
        else if (active) ...[
          SelectableText(_link!.url.toString()),
          const SizedBox(height: 4),
          AppText('Hết hạn lúc ${_link!.expiresAt!.toLocal().toString().substring(0, 16)}'),
        ] else
          AppText(expired ? 'Liên kết đã hết hạn.' : 'Chưa có liên kết đang hoạt động.'),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const AppText('Đóng')),
        if (!_busy && _error != null)
          TextButton(onPressed: _load, child: const AppText('Thử lại')),
        if (!_busy && _error == null && !active)
          FilledButton(onPressed: () => _run((repo) => repo.shareItinerary(widget.itineraryId)),
            child: AppText(expired ? 'Tạo liên kết mới' : 'Tạo liên kết')),
        if (!_busy && active) ...[
          TextButton(onPressed: () => _run((repo) => repo.revokeShare(widget.itineraryId)),
            child: const AppText('Thu hồi')),
          TextButton(onPressed: () => _run((repo) => repo.shareItinerary(widget.itineraryId, rotate: true)),
            child: const AppText('Thay liên kết')),
          FilledButton(onPressed: _copy, child: const AppText('Sao chép')),
        ],
      ],
    );
  }
}
