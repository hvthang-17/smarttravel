import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarttravel_mobile/features/destination/data/models/user_model.dart';
import 'package:smarttravel_mobile/features/destination/data/repositories/auth_repository.dart';

final authNotifierProvider = StateNotifierProvider<AuthNotifier, UserState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<UserState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(UserState());

  Future<void> login(String email, String password) async {
    final user = await _authRepository.login(email, password);
    state = user;
  }

  Future<void> register(String email, String password, String fullName) async {
    final user = await _authRepository.register(email, password, fullName);
    state = user;
  }

  Future<void> updateProfile({
    required String fullName,
    String? phone,
    String? bio,
    String? persona,
    int? avatarIndex,
  }) async {
    final updated = await _authRepository.updateProfile(
      fullName: fullName,
      phone: phone,
      bio: bio,
      persona: persona,
      avatarIndex: avatarIndex,
      currentUser: state,
    );
    state = updated;
  }

  Future<void> logout() async {
    await _authRepository.logout();
    state = UserState();
  }
}
