import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarttravel_mobile/features/auth/presentation/providers/auth_provider.dart';
import '../../data/models/destination_model.dart';
import '../../data/repositories/destination_repository.dart';
import 'destination_provider.dart';

final favoritesProvider =
    StateNotifierProvider<FavoriteNotifier, AsyncValue<List<DestinationModel>>>(
        (ref) {
  final token = ref.watch(authNotifierProvider.select((user) => user.token));
  return FavoriteNotifier(ref.read(destinationRepositoryProvider), token);
});

class FavoriteNotifier
    extends StateNotifier<AsyncValue<List<DestinationModel>>> {
  FavoriteNotifier(this._repository, this._token) : super(const AsyncData([])) {
    if (_token != null) reload();
  }

  final DestinationRepository _repository;
  final String? _token;
  bool _writing = false;
  int _request = 0;

  Future<void> reload() async {
    final token = _token;
    if (token == null || _writing) return;
    final request = ++_request;
    state = const AsyncLoading();
    final next = await AsyncValue.guard(() => _repository.getFavorites(token));
    if (mounted && request == _request) state = next;
  }

  Future<void> toggle(int id) async {
    if (!mounted) return;
    final token = _token;
    final current = state.asData?.value;
    if (token == null || _writing) return;
    if (current == null) {
      throw StateError('Hãy tải lại danh sách yêu thích trước khi lưu');
    }
    _writing = true;
    state =
        const AsyncLoading<List<DestinationModel>>().copyWithPrevious(state);
    try {
      if (current.any((item) => item.id == id)) {
        await _repository.removeFavorite(id, token);
        if (mounted) {
          state = AsyncData(current.where((item) => item.id != id).toList());
        }
      } else {
        final saved = await _repository.addFavorite(id, token);
        if (mounted) state = AsyncData([saved, ...current]);
      }
    } catch (_) {
      if (mounted) state = AsyncData(current);
      rethrow;
    } finally {
      _writing = false;
    }
  }
}
