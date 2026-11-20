import 'package:smarttravel_mobile/core/localization/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smarttravel_mobile/features/auth/presentation/providers/auth_provider.dart';
import '../providers/itinerary_provider.dart';
import '../widgets/itinerary/itinerary_guest_view.dart';
import '../widgets/itinerary/trip_actions.dart';

class TripDraftsScreen extends ConsumerWidget {
  const TripDraftsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authNotifierProvider.select((user) => user.token));
    return Scaffold(
      appBar: AppBar(title: const AppText('Bản nháp')),
      body: session == null ? const ItineraryGuestView() : _drafts(ref),
    );
  }

  Widget _drafts(WidgetRef ref) {
    return ref.watch(tripDraftsProvider).when(
      skipLoadingOnReload: false,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(child: TextButton(
        onPressed: () => ref.invalidate(tripDraftsProvider),
        child: const AppText('Không tải được bản nháp. Thử lại'),
      )),
      data: (trips) => RefreshIndicator(
        onRefresh: () => ref.refresh(tripDraftsProvider.future),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            if (trips.isEmpty) const AppText('Bạn chưa có bản nháp.'),
            for (final trip in trips)
              ListTile(
                leading: const Icon(Icons.edit_note),
                title: Text(trip.title),
                subtitle: AppText('${trip.startDate} · ${trip.totalDays} ngày'),
                trailing: TripActions(key: ValueKey(trip.id), trip: trip),
                onTap: () => ref.context.push('/itineraries/${trip.id}'),
              ),
          ],
        ),
      ),
    );
  }
}
