import '../models/traveler_profile.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smarttravel_mobile/core/network/api_client.dart';
import 'package:smarttravel_mobile/features/auth/data/models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(dioProvider), ref.read(secureStorageProvider));
});

final profileCategoriesProvider = FutureProvider.autoDispose<List<String>>(
  (ref) => ref.watch(authRepositoryProvider).availableCategories(),
);

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
        return _session(data, token);
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
        return _session(data, token);
      }
      throw Exception('Phản hồi không hợp lệ');
    } catch (e) {
      throw Exception('Đăng ký thất bại: ${e.toString()}');
    }
  }

  Future<UserState> updateProfile({
    required String fullName,
    TravelerProfile? travelerProfile,
    String? phone,
    String? bio,
    String? persona,
    int? avatarIndex,
    required UserState currentUser,
  }) async {
    try {
      final response = await dio.put<Map<String, dynamic>>('/auth/profile', data: {
        'fullName': fullName,
        ...?travelerProfile?.toJson(),
      }, options: Options(headers: {'Authorization': 'Bearer ${currentUser.token}'}));

      final responseData = response.data;
      if (responseData != null && responseData['data'] != null) {
        final data = responseData['data'] as Map<String, dynamic>;
        final token = currentUser.token ?? (await storage.read(key: 'jwt_token')) ?? '';
        return currentUser.copyWith(
          travelerProfile: TravelerProfile.fromJson(data['travelerProfile'] as Map<String, dynamic>? ?? {}),
          fullName: data['fullName'] as String? ?? fullName,
          phone: phone,
          bio: bio,
          persona: persona,
          avatarIndex: avatarIndex,
          token: token,
        );
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data is Map
          ? e.response?.data['message'] ?? 'Không thể cập nhật hồ sơ'
          : 'Không thể kết nối máy chủ');
    }
    throw Exception('Phản hồi cập nhật hồ sơ không hợp lệ');
  }

  UserState _session(Map<String, dynamic> data, String token) {
    final user = UserState.fromJson(data, token);
    if (!user.isAuthenticated || user.id == null || user.email == null ||
        !const {'ROLE_USER', 'ROLE_ADMIN'}.contains(user.role)) {
      throw const FormatException('Phản hồi phiên không hợp lệ');
    }
    return user;
  }

  Future<UserState> getProfile(String token) async {
    final response = await dio.get<Map<String, dynamic>>('/auth/profile',
      options: Options(headers: {'Authorization': 'Bearer $token'}));
    final data = response.data?['data'] as Map<String, dynamic>?;
    if (data == null) throw const FormatException('Không đọc được hồ sơ');
    return _session(data, token);
  }

  Future<void> saveToken(String token) => storage.write(key: 'jwt_token', value: token);

  Future<List<String>> availableCategories() async {
    final response = await dio.get<Map<String, dynamic>>('/categories', queryParameters: {'status': 'ACTIVE'});
    final rows = response.data?['data'];
    if (rows is! List) throw const FormatException('Không đọc được danh mục');
    return rows.whereType<Map<String, dynamic>>()
        .where((row) => row['status'] == 'ACTIVE')
        .map((row) => row['code']).whereType<String>().toList();
  }

  Future<void> requestPasswordReset(String email) =>
      _post('/auth/forgot-password', {'email': email});

  Future<void> resetPassword(String code, String password) =>
      _post('/auth/reset-password', {'code': code, 'password': password});

  Future<void> deleteAccount(String password, String token) =>
      _post('/auth/account/delete', {'password': password, 'confirmed': true}, token: token);

  Future<void> _post(String path, Map<String, Object> body, {String? token}) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(path, data: body,
        options: token == null ? null : Options(headers: {'Authorization': 'Bearer $token'}));
      if (response.data?['success'] != true) throw Exception('Phản hồi từ máy chủ không hợp lệ');
    } on DioException catch (error) {
      final data = error.response?.data;
      throw Exception(data is Map ? data['message'] ?? 'Yêu cầu thất bại' : 'Không thể kết nối máy chủ');
    }
  }

  Future<void> clearAccountSettings(int id) => storage.delete(key: 'weather_alert_user_$id');

  Future<void> logout() async {
    await storage.delete(key: 'jwt_token');
  }

  Future<String?> getToken() async {
    return await storage.read(key: 'jwt_token');
  }
}
