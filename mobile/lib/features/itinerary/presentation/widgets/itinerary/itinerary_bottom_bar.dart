import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smarttravel_mobile/core/theme/app_theme.dart';
import 'package:smarttravel_mobile/features/itinerary/data/models/itinerary_model.dart';

class ItineraryBottomBar extends StatelessWidget {
  final ItineraryResponseModel itinerary;
  final ValueChanged<ItineraryResponseModel> onItineraryUpdated;

  const ItineraryBottomBar({
    super.key,
    required this.itinerary,
    required this.onItineraryUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.borderSubtle)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.primaryBlue),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () async {
                final updated = await context.push<ItineraryResponseModel?>(
                  '/itineraries/${itinerary.id}/edit',
                  extra: itinerary,
                );
                if (updated != null) {
                  onItineraryUpdated(updated);
                }
              },
              child: const Text(
                'Chỉnh sửa lịch trình',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primaryBlue),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lịch trình đã sẵn sàng cho chuyến đi của bạn!'),
                    backgroundColor: AppTheme.statusSuccess,
                  ),
                );
              },
              child: const Text(
                'Lưu lịch trình',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
