import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarttravel_mobile/core/network/api_client.dart';
import 'package:smarttravel_mobile/features/destination/data/models/destination_model.dart';
import 'package:smarttravel_mobile/features/destination/data/repositories/destination_repository.dart';

final destinationRepositoryProvider = Provider<DestinationRepository>((ref) {
  final apiClient = ApiClient(ref);
  return DestinationRepository(apiClient);
});

final selectedCategoryProvider = StateProvider<String>((ref) => 'Tất cả');

final destinationListProvider = FutureProvider<List<DestinationModel>>((ref) async {
  final repository = ref.watch(destinationRepositoryProvider);
  final category = ref.watch(selectedCategoryProvider);
  return repository.getDestinations(category: category);
});

final destinationDetailProvider =
    FutureProvider.family<DestinationModel?, int>((ref, id) async {
  final repository = ref.watch(destinationRepositoryProvider);
  return repository.getDestinationById(id);
});


