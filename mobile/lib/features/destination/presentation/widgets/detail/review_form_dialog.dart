import 'package:smarttravel_mobile/core/localization/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarttravel_mobile/features/auth/presentation/providers/auth_provider.dart';
import '../../../data/models/destination_review.dart';

class ReviewFormDialog extends ConsumerStatefulWidget {
  final DestinationReview? review;
  final ReviewInput? draft;
  const ReviewFormDialog({super.key, required this.review, this.draft});

  @override
  ConsumerState<ReviewFormDialog> createState() => _ReviewFormDialogState();
}

class _ReviewFormDialogState extends ConsumerState<ReviewFormDialog> {
  late int? _rating = widget.draft?.rating ?? widget.review?.rating;
  late String _comment = widget.draft == null
      ? widget.review?.comment ?? ''
      : widget.draft!.comment ?? '';

  @override
  Widget build(BuildContext context) {
    ref.listen(authNotifierProvider.select((user) => user.token), (_, __) {
      if (ModalRoute.of(context)?.isCurrent == true) {
        Navigator.of(context).pop();
      }
    });
    return AlertDialog(
      title: AppText(widget.review == null ? 'Viết đánh giá' : 'Sửa đánh giá'),
      scrollable: true,
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        DropdownButtonFormField<int>(
          initialValue: _rating,
          decoration: const InputDecoration(label: AppText('Số sao')),
          items: [
            for (final rating in [5, 4, 3, 2, 1])
              DropdownMenuItem(value: rating, child: AppText('$rating sao')),
          ],
          onChanged: (rating) => setState(() => _rating = rating),
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: _comment,
          minLines: 2,
          maxLines: 4,
          maxLength: 1000,
          decoration:
              const InputDecoration(label: AppText('Nhận xét (không bắt buộc)')),
          onChanged: (comment) => _comment = comment,
        ),
      ]),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const AppText('Hủy')),
        FilledButton(
          onPressed: _rating == null
              ? null
              : () => Navigator.of(context).pop<ReviewInput>(
                    (
                      rating: _rating!,
                      comment: _comment.trim().isEmpty ? null : _comment.trim()
                    ),
                  ),
          child: const AppText('Lưu đánh giá'),
        ),
      ],
    );
  }
}
