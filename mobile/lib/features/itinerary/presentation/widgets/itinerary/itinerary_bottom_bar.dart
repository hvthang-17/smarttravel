import 'package:smarttravel_mobile/core/localization/app_language.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smarttravel_mobile/core/theme/app_theme.dart';
import 'package:smarttravel_mobile/features/itinerary/data/models/itinerary_model.dart';

class ItineraryBottomBar extends StatelessWidget {
  final ItineraryResponseModel itinerary;
  final ValueChanged<ItineraryResponseModel> onItineraryUpdated;
  final VoidCallback onSave;
  final bool saving;

  const ItineraryBottomBar({
    super.key,
    required this.itinerary,
    required this.onItineraryUpdated,
    required this.onSave,
    required this.saving,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(top: false, child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.borderSubtle)),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.primaryBlue),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: saving ? null : () async {
                final updated = await context.push<ItineraryResponseModel?>(
                  '/itineraries/${itinerary.id}/edit',
                  extra: itinerary,
                );
                if (updated != null) {
                  onItineraryUpdated(updated);
                }
              },
              child: const AppText(
                'Chỉnh sửa lịch trình',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primaryBlue),
              ),
          ),
          if (itinerary.status == 'DRAFT') FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: saving ? null : onSave,
              child: AppText(
                saving ? 'Đang lưu…' : 'Lưu lịch trình',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
              ),
          ),
        ],
      ),
    ));
  }
}
