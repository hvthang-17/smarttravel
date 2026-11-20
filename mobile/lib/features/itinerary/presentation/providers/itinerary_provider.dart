import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarttravel_mobile/features/itinerary/data/models/itinerary_model.dart';
import 'package:smarttravel_mobile/features/itinerary/data/repositories/itinerary_repository.dart';
import 'package:smarttravel_mobile/features/auth/presentation/providers/auth_provider.dart';

final tripListsRevisionProvider = StateProvider<int>((ref) => 0);

final tripDraftsProvider = FutureProvider.autoDispose<List<ItineraryResponseModel>>((ref) async {
  final token = ref.watch(authNotifierProvider.select((user) => user.token));
  ref.watch(tripListsRevisionProvider);
  if (token == null) return [];
  return ref.watch(itineraryRepositoryProvider).getDrafts(token);
});

class ItineraryState {
  final bool isLoading;
  final ItineraryResponseModel? generatedItinerary;
  final String? errorMessage;

  const ItineraryState({
    this.isLoading = false,
    this.generatedItinerary,
    this.errorMessage,
  });

  ItineraryState copyWith({
    bool? isLoading,
    ItineraryResponseModel? generatedItinerary,
    String? errorMessage,
  }) {
    return ItineraryState(
      isLoading: isLoading ?? this.isLoading,
      generatedItinerary: generatedItinerary ?? this.generatedItinerary,
      errorMessage: errorMessage,
    );
  }
}

final itineraryNotifierProvider =
    StateNotifierProvider<ItineraryNotifier, ItineraryState>((ref) {
  ref.watch(authNotifierProvider.select((user) => user.token));
  return ItineraryNotifier(ref.read(itineraryRepositoryProvider));
});

class ItineraryNotifier extends StateNotifier<ItineraryState> {
  final ItineraryRepository _repository;

  ItineraryNotifier(this._repository) : super(const ItineraryState());

  Future<ItineraryResponseModel?> generateItinerary(ItineraryRequestModel request) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await _repository.generateItinerary(request);
      if (!mounted) return null;
      state = state.copyWith(isLoading: false, generatedItinerary: result);
      return result;
    } catch (e) {
      if (!mounted) return null;
      final msg = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(isLoading: false, errorMessage: msg);
      return null;
    }
  }

  void reset() {
    state = const ItineraryState();
  }
}
