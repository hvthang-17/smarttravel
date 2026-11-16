import 'package:smarttravel_mobile/core/localization/app_language.dart';
import '../destination_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smarttravel_mobile/core/theme/app_theme.dart';
import 'package:smarttravel_mobile/features/destination/data/models/destination_model.dart';

class DestinationMainInfoCard extends StatelessWidget {
  final DestinationModel destination;
  final String language;

  const DestinationMainInfoCard({super.key, required this.destination, this.language = 'vi'});

  void _handleShare(BuildContext context) {
    final info = '${destinationName(destination, language)} - ${destination.address ?? "Đà Nẵng"}';
    Clipboard.setData(ClipboardData(text: info));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AppText('Đã sao chép: $info'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hours = formatOpeningSchedule(destination);
    final price = formatDestinationPrice(destination.priceMinVnd, destination.priceMaxVnd);

    final locationDisplay = destination.address?.trim().isNotEmpty == true
        ? (destination.address!.contains(',')
            ? destination.address!.split(',').first.trim()
            : destination.address!)
        : 'Đà Nẵng';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primarySurface,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: AppText(
                  destinationCategoryName(destination, language),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              )),
              Semantics(
                label: 'Chia sẻ thông tin địa điểm',
                button: true,
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Material(
                    color: AppTheme.bgCanvas,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: AppTheme.borderSubtle),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => _handleShare(context),
                      child: const Center(
                        child: Icon(
                          Icons.share_outlined,
                          size: 18,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AppText(
            destinationName(destination, language),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppTheme.surfaceSubtle),
          const SizedBox(height: 14),
          AppText('Giờ hoạt động', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          AppText(hours),
          const SizedBox(height: 12),
          AppText(destination.priceMinVnd == null && destination.priceMaxVnd == null
              ? 'Chưa rõ giá tham khảo' : 'Giá tham khảo mỗi người · $price'),
          const SizedBox(height: 4),
          AppText(locationDisplay),
          const SizedBox(height: 16),
          const Divider(),
          _rating('Google Maps', destination.rating, destination.reviewCount),
          const SizedBox(height: 8),
          _rating('SmartTravel', destination.appRating, destination.appReviewCount),
        ],
      ),
    );
  }

  Widget _rating(String source, double? rating, int? count) {
    final score = rating == null ? 'Chưa có điểm' : '${rating.toStringAsFixed(1)}/5';
    final reviews = count == null ? 'chưa rõ số lượt' : '$count lượt đánh giá';
    return AppText('$source · $score · $reviews');
  }
}
