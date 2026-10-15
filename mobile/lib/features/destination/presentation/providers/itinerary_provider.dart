import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarttravel_mobile/features/destination/data/models/itinerary_model.dart';
import 'package:smarttravel_mobile/features/destination/data/repositories/itinerary_repository.dart';

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
  return ItineraryNotifier(ref.read(itineraryRepositoryProvider));
});

class ItineraryNotifier extends StateNotifier<ItineraryState> {
  final ItineraryRepository _repository;

  ItineraryNotifier(this._repository) : super(const ItineraryState());

  Future<ItineraryResponseModel?> generateItinerary(ItineraryRequestModel request) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await _repository.generateItinerary(request);
      state = state.copyWith(isLoading: false, generatedItinerary: result);
      return result;
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(isLoading: false, errorMessage: msg);
      return null;
    }
  }

  void reset() {
    state = const ItineraryState();
  }
}
