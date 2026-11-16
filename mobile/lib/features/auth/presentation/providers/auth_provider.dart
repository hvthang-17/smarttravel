import 'package:smarttravel_mobile/features/auth/data/models/traveler_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarttravel_mobile/features/auth/data/models/user_model.dart';
import 'package:smarttravel_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:smarttravel_mobile/core/network/api_client.dart';

final authNotifierProvider = StateNotifierProvider<AuthNotifier, UserState>((ref) {
  final notifier = AuthNotifier(ref.read(authRepositoryProvider), ref.read(sessionWritesProvider));
  ref.listen(sessionInvalidationProvider, (_, __) => notifier.clearSession());
  return notifier;
});

class AuthNotifier extends StateNotifier<UserState> {
  final AuthRepository _authRepository;

  final SessionWrites _sessionWrites;

  AuthNotifier(this._authRepository, this._sessionWrites) : super(UserState());

  int _revision = 0;
  void clearSession() {
    _revision++;
    state = UserState();
  }

  Future<void> _authenticate(Future<UserState> Function() action) async {
    final revision = ++_revision;
    final user = await action();
    await _sessionWrites.run(() async {
      if (!mounted || revision != _revision) return;
      await _authRepository.saveToken(user.token!);
      if (mounted && revision == _revision) state = user;
    });
  }

  Future<void> login(String email, String password) =>
      _authenticate(() => _authRepository.login(email, password));

  Future<void> register(String email, String password, String fullName) =>
      _authenticate(() => _authRepository.register(email, password, fullName));

  Future<bool> restoreSession() async {
    final revision = _revision;
    try {
      final token = await _authRepository.getToken();
      if (token == null || token.isEmpty) return false;
      final user = await _authRepository.getProfile(token);
      if (mounted && revision == _revision) state = user;
      return mounted && state.isAuthenticated;
    } catch (_) {
      return false;
    }
  }

  Future<void> updateProfile({
    required String fullName,
    TravelerProfile? travelerProfile,
    String? phone,
    String? bio,
    String? persona,
    int? avatarIndex,
  }) async {
    final user = state;
    final updated = await _authRepository.updateProfile(
      fullName: fullName, travelerProfile: travelerProfile,
      phone: phone, bio: bio, persona: persona, avatarIndex: avatarIndex,
      currentUser: user,
    );
    if (!mounted || state.token != user.token) throw StateError('Phiên đăng nhập đã thay đổi');
    state = updated;
  }

  Future<void> deleteAccount(String password) async {
    final user = state;
    final token = user.token;
    if (token == null) throw StateError('Vui lòng đăng nhập lại');
    await _authRepository.deleteAccount(password, token);
    if (mounted && state.token == token) await logout();
    if (user.id != null) await _authRepository.clearAccountSettings(user.id!);
  }

  Future<void> logout() async {
    clearSession();
    await _sessionWrites.run(_authRepository.logout);
  }
}
