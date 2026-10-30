import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarttravel_mobile/features/itinerary/data/repositories/itinerary_repository.dart';

class ProfileStatsData {
  final int total;
  final int completed;
  final int destinations;

  const ProfileStatsData({
    required this.total,
    required this.completed,
    required this.destinations,
  });
}

final userItinerariesStatsProvider = FutureProvider.autoDispose<ProfileStatsData>((ref) async {
  try {
    final itineraries = await ref.watch(itineraryRepositoryProvider).getMyItineraries();
    final now = DateTime.now();
    int completedCount = 0;
    final Set<String> uniqueDestinations = {};

    for (final trip in itineraries) {
      final parsedEnd = DateTime.tryParse(trip.endDate);
      if (parsedEnd != null && parsedEnd.isBefore(now)) {
        completedCount++;
      }
      for (final day in trip.days) {
        for (final item in day.items) {
          final destName = item.destination?.name;
          if (destName != null && destName.isNotEmpty) {
            uniqueDestinations.add(destName);
          }
        }
      }
    }

    return ProfileStatsData(
      total: itineraries.length,
      completed: completedCount,
      destinations: uniqueDestinations.length,
    );
  } catch (_) {
    return const ProfileStatsData(total: 0, completed: 0, destinations: 0);
  }
});

class ProfileStatsRow extends ConsumerWidget {
  const ProfileStatsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(userItinerariesStatsProvider);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: statsAsync.when(
        data: (stats) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem('${stats.total}', 'Lịch trình đã tạo', const Color(0xFF0077B6)),
            Container(height: 32, width: 1, color: const Color(0xFFE2E8F0)),
            _buildStatItem('${stats.completed}', 'Chuyến đi xong', const Color(0xFF0F172A)),
            Container(height: 32, width: 1, color: const Color(0xFFE2E8F0)),
            _buildStatItem('${stats.destinations}', 'Điểm khám phá', const Color(0xFFF77F00)),
          ],
        ),
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        error: (_, __) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem('0', 'Lịch trình đã tạo', const Color(0xFF0077B6)),
            Container(height: 32, width: 1, color: const Color(0xFFE2E8F0)),
            _buildStatItem('0', 'Chuyến đi xong', const Color(0xFF0F172A)),
            Container(height: 32, width: 1, color: const Color(0xFFE2E8F0)),
            _buildStatItem('0', 'Điểm khám phá', const Color(0xFFF77F00)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String number, String label, Color numColor) {
    return Expanded(
      child: Column(
        children: [
          Text(
            number,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: numColor),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}
