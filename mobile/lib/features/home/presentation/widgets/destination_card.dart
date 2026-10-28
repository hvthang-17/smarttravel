import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smarttravel_mobile/core/theme/app_theme.dart';
import 'package:smarttravel_mobile/features/destination/data/models/destination_model.dart';

class DestinationCard extends StatelessWidget {
  final DestinationModel destination;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const DestinationCard({
    super.key,
    required this.destination,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  String _formatPrice(int amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}tr';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}k';
    }
    return '$amount';
  }

  @override
  Widget build(BuildContext context) {
    final isFree = (destination.priceMinVnd == null || destination.priceMinVnd == 0);

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
      onTap: () => context.push('/destinations/${destination.id}'),
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
                  destination.imageUrl?.trim().isNotEmpty == true
                      ? Image.network(
                          destination.imageUrl!,
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

                  // Floating 44x44 favorite button
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Semantics(
                      label: isFavorite ? 'Bỏ yêu thích' : 'Thêm vào yêu thích',
                      button: true,
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: onToggleFavorite,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  isFavorite ? Icons.favorite : Icons.favorite_border,
                                  size: 18,
                                  color: isFavorite
                                      ? AppTheme.statusError
                                      : AppTheme.textMuted,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
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
                    child: Text(
                      destination.category,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: badgeText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    destination.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isFree ? 'Miễn phí' : '~${_formatPrice(destination.priceMinVnd!)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isFree
                              ? AppTheme.statusSuccess
                              : AppTheme.secondaryCoral,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Color(0xFFF59E0B)),
                          const SizedBox(width: 2),
                          Text(
                            destination.rating > 0
                                ? destination.rating.toStringAsFixed(1)
                                : 'Mới',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
