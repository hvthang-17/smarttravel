import 'package:smarttravel_mobile/core/localization/app_language.dart';
import 'package:smarttravel_mobile/features/destination/presentation/widgets/destination_display.dart';
import 'package:smarttravel_mobile/features/destination/presentation/widgets/favorite_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smarttravel_mobile/core/theme/app_theme.dart';
import 'package:smarttravel_mobile/features/destination/data/models/destination_model.dart';

class DestinationCard extends StatelessWidget {
  final DestinationModel destination;
  final String language;

  const DestinationCard({
    super.key,
    required this.destination,
    this.language = 'vi',
  });

  @override
  Widget build(BuildContext context) {
    final image = destinationImageUrl(destination.imageUrl);
    final id = destination.id;

    Color badgeBg = const Color(0xFFE0F2FE);
    Color badgeText = const Color(0xFF0284C7);
    if (destination.category.contains('Văn hóa')) {
      badgeBg = const Color(0xFFF3E8FF);
      badgeText = const Color(0xFF7E22CE);
    } else if (destination.category.contains('Ẩm thực')) {
      badgeBg = const Color(0xFFFFEDD5);
      badgeText = const Color(0xFFC2410C);
    } else if (destination.category.contains('Check-in')) {
      badgeBg = const Color(0xFFFEF3C7);
      badgeText = const Color(0xFFB45309);
    }

    return InkWell(
      onTap: destination.id == null ? null : () => context.push('/destinations/${destination.id}'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderSubtle),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  image != null
                      ? Image.network(
                          image,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildFallbackCover(),
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              color: AppTheme.surfaceSubtle,
                              child: const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            );
                          },
                        )
                      : _buildFallbackCover(),

                  if (id != null) Positioned(
                    top: 4,
                    right: 4,
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      child: FavoriteButton(id: id),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: AppText(
                      destinationCategoryName(destination, language),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: badgeText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  AppText(
                    destinationName(destination, language),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  AppText(formatDestinationPrice(destination.priceMinVnd, destination.priceMaxVnd),
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackCover() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue.withValues(alpha: 0.5),
            const Color(0xFF023E8A).withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          destination.category.contains('Biển')
              ? Icons.beach_access
              : destination.category.contains('Ẩm thực')
                  ? Icons.restaurant
                  : destination.category.contains('Văn hóa')
                      ? Icons.account_balance
                      : Icons.landscape,
          size: 36,
          color: Colors.white.withValues(alpha: 0.85),
        ),
      ),
    );
  }
}
