import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarttravel_mobile/core/network/api_client.dart';
import 'package:smarttravel_mobile/features/destination/data/models/destination_model.dart';
import 'package:smarttravel_mobile/features/destination/data/repositories/destination_repository.dart';
import '../../data/models/discovery_models.dart';

final destinationRepositoryProvider = Provider<DestinationRepository>((ref) {
  final apiClient = ApiClient(ref);
  return DestinationRepository(apiClient);
});

final destinationCatalogProvider = FutureProvider.autoDispose<List<DestinationCategory>>(
  (ref) => ref.watch(destinationRepositoryProvider).categories(),
);

final discoveryProvider = FutureProvider.autoDispose.family<DiscoveryPage, DiscoveryQuery>(
  (ref, query) => ref.watch(destinationRepositoryProvider).discover(query),
);

final destinationDetailProvider =
    FutureProvider.autoDispose.family<DestinationModel?, int>((ref, id) async {
  final repository = ref.watch(destinationRepositoryProvider);
  return repository.getDestinationById(id);
});


