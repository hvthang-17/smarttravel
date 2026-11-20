import 'package:smarttravel_mobile/core/localization/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/trip_management_models.dart';
import '../../data/repositories/itinerary_repository.dart';

final sharedTripProvider = FutureProvider.autoDispose.family<SharedTrip, String>(
  (ref, token) => ref.read(itineraryRepositoryProvider).getSharedItinerary(token),
);

class SharedTripScreen extends ConsumerWidget {
  final String token;
  const SharedTripScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trip = ref.watch(sharedTripProvider(token));
    return Scaffold(
      appBar: AppBar(
        title: const AppText('Lịch trình được chia sẻ'),
        actions: [
          IconButton(tooltip: AppLanguage.text(context, 'Tải lại'), icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(sharedTripProvider(token))),
        ],
      ),
      body: trip.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              AppText(error is SharedTripUnavailable
                  ? (error.expired ? 'Liên kết đã hết hạn' : 'Liên kết không hợp lệ hoặc đã bị thu hồi')
                  : 'Không tải được lịch trình', textAlign: TextAlign.center),
              const SizedBox(height: 8),
              if (error is SharedTripUnavailable)
                const AppText('Hãy xin chủ chuyến gửi một liên kết mới.', textAlign: TextAlign.center)
              else
                TextButton(onPressed: () => ref.invalidate(sharedTripProvider(token)), child: const AppText('Thử lại')),
              TextButton(onPressed: () => context.go('/'), child: const AppText('Về trang chủ')),
            ]),
          ),
        ),
        data: (shared) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppText(shared.title, style: Theme.of(context).textTheme.headlineSmall),
            AppText('${shared.startDate} – ${shared.endDate} · Chỉ xem'),
            for (final day in shared.days) ...[
              const SizedBox(height: 16),
              AppText('Ngày ${day.dayNumber} · ${day.date ?? ''}',
                style: Theme.of(context).textTheme.titleMedium),
              if (day.items.isEmpty) const AppText('Chưa có hoạt động.'),
              for (final item in day.items)
                ListTile(
                  leading: CircleAvatar(child: AppText('${item.sequenceOrder}')),
                  title: AppText(item.destination?.name ?? 'Điểm đến'),
                  subtitle: AppText([
                    if (item.startTime != null) item.startTime!,
                    if (item.durationMinutes != null) '${item.durationMinutes} phút',
                  ].join(' · ')),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
