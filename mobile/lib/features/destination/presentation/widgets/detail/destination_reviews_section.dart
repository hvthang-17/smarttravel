import 'package:smarttravel_mobile/core/localization/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smarttravel_mobile/core/theme/app_theme.dart';
import 'package:smarttravel_mobile/features/auth/presentation/providers/auth_provider.dart';
import '../../../data/models/destination_review.dart';
import '../../providers/destination_provider.dart';
import '../../providers/destination_reviews_provider.dart';
import 'review_form_dialog.dart';

class DestinationReviewsSection extends ConsumerStatefulWidget {
  final int destinationId;
  const DestinationReviewsSection({super.key, required this.destinationId});

  @override
  ConsumerState<DestinationReviewsSection> createState() =>
      _DestinationReviewsSectionState();
}

class _DestinationReviewsSectionState
    extends ConsumerState<DestinationReviewsSection> {
  final _reported = <int>{};
  final _additional = <DestinationReview>[];
  int _page = 0;
  bool? _hasNext;
  bool _busy = false;
  String? _message;
  bool _failed = false;
  ReviewInput? _unsavedReview;
  String? get _token => ref.read(authNotifierProvider).token;
  int get _id => widget.destinationId;

  Future<void> _edit(DestinationReview? existing) async {
    final token = _token;
    if (token == null || _busy) return;
    final input = await showDialog<ReviewInput>(
        context: context,
        builder: (_) =>
            ReviewFormDialog(review: existing, draft: _unsavedReview));
    if (input == null || !mounted || _token != token) return;
    _unsavedReview = input;
    await _act(token, () async {
      await ref
          .read(reviewRepositoryProvider)
          .save(_id, token, input, existing: existing != null);
      if (!mounted || _token != token) return;
      _unsavedReview = null;
      _reload(token);
    }, 'Đã lưu đánh giá.');
  }

  Future<void> _delete() async {
    final token = _token;
    if (token == null || _busy) return;
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialog) => AlertDialog(
              title: const AppText('Xóa đánh giá?'),
              content: const AppText('Đánh giá sẽ được xóa khỏi SmartTravel.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(dialog).pop(false),
                    child: const AppText('Hủy')),
                FilledButton(
                    onPressed: () => Navigator.of(dialog).pop(true),
                    child: const AppText('Xóa đánh giá')),
              ],
            ));
    if (confirmed != true || !mounted || _token != token) return;
    await _act(token, () async {
      await ref.read(reviewRepositoryProvider).delete(_id, token);
      if (mounted && _token == token) {
        _unsavedReview = null;
        _reload(token);
      }
    }, 'Đã xóa đánh giá.');
  }

  Future<void> _report(int id) async {
    final token = _token;
    if (token == null || _busy || _reported.contains(id)) return;
    final reason = await showDialog<String>(
        context: context,
        builder: (dialog) => SimpleDialog(
              title: const AppText('Lý do báo cáo'),
              children: [
                for (final reason in reviewReportReasons.entries)
                  SimpleDialogOption(
                      onPressed: () => Navigator.of(dialog).pop(reason.key),
                      child: AppText(reason.value)),
                SimpleDialogOption(
                    onPressed: () => Navigator.of(dialog).pop(),
                    child: const AppText('Hủy')),
              ],
            ));
    if (reason == null || !mounted || _token != token) return;
    await _act(token, () async {
      await ref.read(reviewRepositoryProvider).report(_id, id, token, reason);
      if (mounted && _token == token) setState(() => _reported.add(id));
    }, 'Đã gửi báo cáo đến quản trị viên.');
  }

  Future<void> _act(
      String? token, Future<void> Function() operation, String? success) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _failed = false;
      _message = null;
    });
    try {
      await operation();
      if (mounted && _token == token) setState(() => _message = success);
    } catch (error) {
      if (mounted && _token == token) {
        setState(() {
          _failed = true;
          _message = error.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted && _token == token) setState(() => _busy = false);
    }
  }

  void _reload(String token) {
    setState(() {
      _additional.clear();
      _page = 0;
      _hasNext = null;
    });
    ref.invalidate(myDestinationReviewProvider((_id, token)));
    ref.invalidate(destinationReviewsProvider(_id));
    ref.invalidate(destinationDetailProvider(_id));
    ref.invalidate(discoveryProvider);
  }

  Future<void> _more() {
    final token = _token;
    return _act(token, () async {
      final page =
          await ref.read(reviewRepositoryProvider).list(_id, _page + 1);
      if (!mounted || _token != token) return;
      setState(() {
        _additional.addAll(page.items);
        _page++;
        _hasNext = page.hasNext;
      });
    }, null);
  }

  @override
  Widget build(BuildContext context) {
    final token = ref.watch(authNotifierProvider.select((user) => user.token));
    ref.listen(authNotifierProvider.select((user) => user.token), (_, __) {
      setState(() {
        _reported.clear();
        _message = null;
        _unsavedReview = null;
        _busy = false;
      });
    });
    final page = ref.watch(destinationReviewsProvider(_id));
    final mine = token == null
        ? null
        : ref.watch(myDestinationReviewProvider((_id, token)));
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderSubtle)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AppText('Đánh giá SmartTravel',
            style: Theme.of(context).textTheme.titleMedium),
        if (token == null)
          TextButton(
              onPressed: () => context.push('/login'),
              child: const AppText('Đăng nhập để đánh giá'))
        else if (mine!.hasError)
          TextButton(
              onPressed: () =>
                  ref.invalidate(myDestinationReviewProvider((_id, token))),
              child: const AppText('Không tải được đánh giá của bạn. Thử lại'))
        else if (!mine.isLoading) ...[
          if (mine.valueOrNull?.status == 'HIDDEN')
            const Padding(
                padding: EdgeInsets.only(top: 8),
                child: AppText(
                    'Đánh giá của bạn đang bị ẩn khỏi danh sách công khai.')),
          Wrap(spacing: 8, children: [
            FilledButton(
                onPressed: _busy ? null : () => _edit(mine.valueOrNull),
                child: AppText(mine.valueOrNull == null
                    ? 'Viết đánh giá'
                    : 'Sửa đánh giá của bạn')),
            if (mine.valueOrNull != null)
              TextButton(
                  onPressed: _busy ? null : _delete,
                  child: const AppText('Xóa đánh giá của bạn')),
          ]),
        ],
        if (_busy) const LinearProgressIndicator(),
        if (_message != null)
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Semantics(
                  liveRegion: true,
                  child: AppText(_message!,
                      style: TextStyle(
                          color: _failed ? colors.error : colors.onSurface)))),
        page.when(
          loading: () => const Padding(
              padding: EdgeInsets.all(12), child: LinearProgressIndicator()),
          error: (_, __) => TextButton(
              onPressed: () => ref.invalidate(destinationReviewsProvider(_id)),
              child: const AppText('Không tải được đánh giá. Thử lại')),
          data: (first) {
            final rows = {
              for (final review in [...first.items, ..._additional])
                review.id: review
            };
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (rows.isEmpty) const AppText('Chưa có đánh giá SmartTravel.'),
                  for (final review in rows.values) ...[
                    const Divider(),
                    AppText(
                        '${review.rating}/5 sao · ${review.createdAt.toIso8601String().split('T').first}',
                        style: Theme.of(context).textTheme.titleSmall),
                    if (review.comment != null) AppText(review.comment!),
                    if (token != null &&
                        mine?.hasValue == true &&
                        review.id != mine?.valueOrNull?.id)
                      TextButton(
                          onPressed: _busy || _reported.contains(review.id)
                              ? null
                              : () => _report(review.id),
                          child: AppText(_reported.contains(review.id)
                              ? 'Đã báo cáo'
                              : 'Báo cáo đánh giá')),
                  ],
                  if (_hasNext ?? first.hasNext)
                    TextButton(
                        onPressed: _busy ? null : _more,
                        child: const AppText('Xem thêm đánh giá')),
                ]);
          },
        ),
      ]),
    );
  }
}
