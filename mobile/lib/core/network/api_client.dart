import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Base URL của Backend API.
///
/// Các cách kết nối từ thiết bị thật Android tới Backend chạy trên máy tính:
/// 1. Cắm cáp USB (khuyên dùng):
///    - Bật "USB Debugging" trên điện thoại.
///    - Chạy lệnh terminal trên máy tính: `adb reverse tcp:8080 tcp:8080`
///    - Khi đó điện thoại có thể truy cập `http://localhost:8080/api/v1` trực tiếp.
///
/// 2. Cùng mạng Wi-Fi:
///    - Chạy với cờ: `flutter run --dart-define=API_BASE_URL=http://<IP_MÁY_TÍNH>:8080/api/v1`
///    - Hoặc cập nhật IP LAN mặc định tại [defaultServerHost].
const String _configuredBaseUrl = String.fromEnvironment('API_BASE_URL');

/// IP LAN của máy tính đang chạy Spring Boot Backend (kiểm tra bằng lệnh `ipconfig`).
/// Có thể cập nhật IP này khi mạng Wi-Fi thay đổi.
const String defaultServerHost = '192.168.1.21';
const String defaultServerPort = '8080';

String resolveBaseUrl() {
  if (_configuredBaseUrl.isNotEmpty) {
    return _configuredBaseUrl;
  }
  // Nếu chạy trên nền tảng Web:
  if (kIsWeb) {
    return 'http://localhost:$defaultServerPort/api/v1';
  }
  // Mặc định cho thiết bị Android vật lý kết nối cùng mạng Wi-Fi:
  return 'http://$defaultServerHost:$defaultServerPort/api/v1';
}

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: resolveBaseUrl(),
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  final storage = ref.read(secureStorageProvider);

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.read(key: 'jwt_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ),
  );

  return dio;
});

class ApiClient {
  final Ref ref;
  ApiClient(this.ref);

  Dio get dio => ref.read(dioProvider);
}
