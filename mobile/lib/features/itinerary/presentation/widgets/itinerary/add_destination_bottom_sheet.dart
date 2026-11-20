import 'package:smarttravel_mobile/core/localization/app_language.dart';
import 'package:flutter/material.dart';
import 'package:smarttravel_mobile/core/theme/app_theme.dart';
import 'package:smarttravel_mobile/features/destination/data/models/destination_model.dart';

class AddDestinationBottomSheet extends StatelessWidget {
  final int dayNumber;
  final bool replacing;
  final List<DestinationModel> destinations;
  final ValueChanged<DestinationModel> onSelectDestination;

  const AddDestinationBottomSheet({
    super.key,
    required this.dayNumber,
    this.replacing = false,
    required this.destinations,
    required this.onSelectDestination,
  });

  static Future<void> show({
    required BuildContext context,
    required int dayNumber,
    bool replacing = false,
    required List<DestinationModel> destinations,
    required ValueChanged<DestinationModel> onSelectDestination,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => AddDestinationBottomSheet(
        dayNumber: dayNumber,
        replacing: replacing,
        destinations: destinations,
        onSelectDestination: onSelectDestination,
      ),
    );
  }

  String _formatVnd(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }
    return buffer.toString().split('').reversed.join('');
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppText(
              replacing ? 'Chọn địa điểm thay thế' : 'Thêm điểm đến vào Ngày $dayNumber',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
          ),
          if (destinations.isEmpty)
            const Expanded(child: Center(child: AppText('Không có địa điểm khả dụng.')))
          else Expanded(
            child: ListView.separated(
              itemCount: destinations.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, i) {
                final d = destinations[i];
                final price = d.priceMaxVnd != null ? '${_formatVnd(d.priceMaxVnd!)} đ/khách'
                    : d.priceMinVnd != null ? 'Từ ${_formatVnd(d.priceMinVnd!)} đ/khách' : 'Chưa rõ giá';
                final duration = d.suggestedVisitDurationMinutes ?? d.visitDurationMinutes;
                return ListTile(
                  title: AppText(d.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: AppText(
                    '${d.category} · $price${duration == null ? '' : ' · $duration phút'}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                  trailing: const Icon(Icons.add_circle_outline, color: AppTheme.primaryBlue),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    onSelectDestination(d);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
