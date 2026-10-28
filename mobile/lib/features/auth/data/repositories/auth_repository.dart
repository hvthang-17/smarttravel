import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smarttravel_mobile/core/network/api_client.dart';
import 'package:smarttravel_mobile/features/auth/data/models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(dioProvider), ref.read(secureStorageProvider));
});

class AuthRepository {
  final Dio dio;
  final FlutterSecureStorage storage;

  AuthRepository(this.dio, this.storage);

  Future<UserState> login(String email, String password) async {
    try {
      final response = await dio.post<Map<String, dynamic>>('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final responseData = response.data;
      if (responseData != null) {
        final data = responseData['data'] as Map<String, dynamic>;
        final token = data['token'] as String;
        await storage.write(key: 'jwt_token', value: token);
        return UserState.fromJson(data, token);
      }
      throw Exception('Phản hồi không hợp lệ');
    } catch (e) {
      throw Exception('Đăng nhập thất bại: ${e.toString()}');
    }
  }

  Future<UserState> register(String email, String password, String fullName) async {
    try {
      final response = await dio.post<Map<String, dynamic>>('/auth/register', data: {
        'email': email,
        'password': password,
        'fullName': fullName,
      });

      final responseData = response.data;
      if (responseData != null) {
        final data = responseData['data'] as Map<String, dynamic>;
        final token = data['token'] as String;
        await storage.write(key: 'jwt_token', value: token);
        return UserState.fromJson(data, token);
      }
      throw Exception('Phản hồi không hợp lệ');
    } catch (e) {
      throw Exception('Đăng ký thất bại: ${e.toString()}');
    }
  }

  Future<UserState> updateProfile({
    required String fullName,
    String? phone,
    String? bio,
    String? persona,
    int? avatarIndex,
    required UserState currentUser,
  }) async {
    try {
      final response = await dio.put<Map<String, dynamic>>('/auth/profile', data: {
        'fullName': fullName,
      });

      final responseData = response.data;
      if (responseData != null && responseData['data'] != null) {
        final data = responseData['data'] as Map<String, dynamic>;
        final token = currentUser.token ?? (await storage.read(key: 'jwt_token')) ?? '';
        return currentUser.copyWith(
          fullName: data['fullName'] as String? ?? fullName,
          phone: phone,
          bio: bio,
          persona: persona,
          avatarIndex: avatarIndex,
          token: token,
        );
      }
    } catch (_) {
      // Graceful fallback if backend is offline or network fails
    }

    return currentUser.copyWith(
      fullName: fullName,
      phone: phone,
      bio: bio,
      persona: persona,
      avatarIndex: avatarIndex,
    );
  }

  Future<void> logout() async {
    await storage.delete(key: 'jwt_token');
  }

  Future<String?> getToken() async {
    return await storage.read(key: 'jwt_token');
  }
}
