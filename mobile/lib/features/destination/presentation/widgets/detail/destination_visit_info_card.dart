import 'package:smarttravel_mobile/core/localization/app_language.dart';
import '../destination_display.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smarttravel_mobile/core/theme/app_theme.dart';
import 'package:smarttravel_mobile/features/destination/data/models/destination_model.dart';

class DestinationVisitInfoCard extends StatelessWidget {
  final DestinationModel destination;

  const DestinationVisitInfoCard({super.key, required this.destination});

  Future<void> _openGoogleMaps(BuildContext context) async {
    final uri = destinationMapUri(destination);
    if (uri == null) return;
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: AppText('Không thể mở ứng dụng bản đồ.')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: AppText('Lỗi khi mở liên kết bản đồ.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final addressText = destination.address?.trim().isNotEmpty == true
        ? destination.address!
        : 'Chưa cập nhật địa chỉ';

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
          const AppText(
            'Thông tin tham quan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          _buildInfoRow(
            Icons.location_on_outlined,
            'Địa chỉ',
            addressText,
          ),
          const Divider(height: 20, color: AppTheme.surfaceSubtle),
          _buildInfoRow(
            Icons.schedule,
            'Thời lượng gợi ý',
            destination.visitDurationMinutes == null ? 'Chưa rõ' : '${destination.visitDurationMinutes} phút',
          ),
          const Divider(height: 20, color: AppTheme.surfaceSubtle),
          _buildInfoRow(
            Icons.explore_outlined,
            'Tọa độ GPS',
            destination.hasCoordinates ? '${destination.latitude!.toStringAsFixed(4)}, ${destination.longitude!.toStringAsFixed(4)}' : 'Chưa rõ',
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                backgroundColor: AppTheme.primarySurface,
                side: const BorderSide(color: Color(0xFFBAE6FD)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: destination.hasCoordinates ? () => _openGoogleMaps(context) : null,
              icon: const Icon(
                Icons.map_outlined,
                size: 18,
                color: AppTheme.primaryBlue,
              ),
              label: const AppText(
                'Xem vị trí trên Google Maps',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryBlue),
        const SizedBox(width: 10),
        SizedBox(
          width: 110,
          child: AppText(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textMuted,
            ),
          ),
        ),
        Expanded(
          child: AppText(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
