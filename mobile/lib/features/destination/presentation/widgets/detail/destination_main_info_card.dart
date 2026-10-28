import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smarttravel_mobile/core/theme/app_theme.dart';
import 'package:smarttravel_mobile/features/destination/data/models/destination_model.dart';

class DestinationMainInfoCard extends StatelessWidget {
  final DestinationModel destination;

  const DestinationMainInfoCard({super.key, required this.destination});

  void _handleShare(BuildContext context) {
    final info = '${destination.name} - ${destination.address ?? "Đà Nẵng"}';
    Clipboard.setData(ClipboardData(text: info));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã sao chép: $info'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatPrice(int amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)} triệu';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}k';
    }
    return '$amountđ';
  }

  @override
  Widget build(BuildContext context) {
    final isFree = (destination.priceMinVnd == null || destination.priceMinVnd == 0);
    final hours = destination.openingHours?.trim().isNotEmpty == true
        ? destination.openingHours!
        : 'Cả ngày / Tự do';

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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primarySurface,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  destination.category,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
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
          Text(
            destination.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppTheme.surfaceSubtle),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: AppTheme.primaryBlue),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  hours,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.confirmation_number_outlined, size: 16, color: AppTheme.statusSuccess),
              const SizedBox(width: 4),
              Text(
                isFree ? 'Miễn phí' : _formatPrice(destination.priceMinVnd!),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.statusSuccess,
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.location_on_outlined, size: 16, color: AppTheme.secondaryCoral),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  locationDisplay,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
