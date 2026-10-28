import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarttravel_mobile/features/itinerary/data/repositories/itinerary_repository.dart';

class ShareItineraryDialog extends ConsumerStatefulWidget {
  final int itineraryId;
  final String title;

  const ShareItineraryDialog({
    super.key,
    required this.itineraryId,
    required this.title,
  });

  static Future<void> show(BuildContext context, int itineraryId, String title) {
    return showDialog<void>(
      context: context,
      builder: (_) => ShareItineraryDialog(itineraryId: itineraryId, title: title),
    );
  }

  @override
  ConsumerState<ShareItineraryDialog> createState() => _ShareItineraryDialogState();
}

class _ShareItineraryDialogState extends ConsumerState<ShareItineraryDialog> {
  bool _isLoading = true;
  String? _shareUrl;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _generateShareLink();
  }

  Future<void> _generateShareLink() async {
    try {
      final repo = ref.read(itineraryRepositoryProvider);
      final res = await repo.shareItinerary(widget.itineraryId);
      final token = res['shareToken'];
      if (mounted) {
        setState(() {
          _shareUrl = 'https://smarttravel.danang.vn/itineraries/shared/$token';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void _copyToClipboard() {
    if (_shareUrl == null) return;
    Clipboard.setData(ClipboardData(text: _shareUrl!));
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã sao chép liên kết chia sẻ (Read-only)!'),
        backgroundColor: Color(0xFF2A9D8F),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      title: const Row(
        children: [
          Icon(Icons.share, color: Color(0xFF0077B6), size: 22),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Chia sẻ chuyến đi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Người nhận liên kết chỉ có quyền xem (Read-only), không thể chỉnh sửa lịch trình gốc của bạn.',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0077B6)),
                ),
              ),
            )
          else if (_errorMessage != null)
            Text(
              _errorMessage!,
              style: const TextStyle(color: Color(0xFFE76F51), fontSize: 13),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _shareUrl ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _copyToClipboard,
                    child: const Icon(
                      Icons.copy,
                      size: 18,
                      color: Color(0xFF0077B6),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Đóng', style: TextStyle(color: Color(0xFF64748B))),
        ),
        if (!_isLoading && _shareUrl != null)
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF0077B6),
            ),
            onPressed: _copyToClipboard,
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('Sao chép liên kết'),
          ),
      ],
    );
  }
}
