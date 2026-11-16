import 'package:smarttravel_mobile/features/itinerary/data/repositories/itinerary_repository.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smarttravel_mobile/core/network/api_client.dart';
import 'package:smarttravel_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:smarttravel_mobile/features/auth/data/models/traveler_profile.dart';
import 'package:smarttravel_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:smarttravel_mobile/features/itinerary/data/models/itinerary_model.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/providers/itinerary_provider.dart';

class SessionAdapter implements HttpClientAdapter {
  int status = 200;
  Future<void> Function()? beforeResponse;
  Map<String, dynamic>? account;
  RequestOptions? lastRequest;
  bool offline = false;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream,
      Future<void>? cancelFuture) async {
    lastRequest = options;
    if (offline) throw DioException(requestOptions: options, type: DioExceptionType.connectionError);
    await beforeResponse?.call();
    return ResponseBody.fromString(jsonEncode(status == 200
        ? {'success': true, 'data': options.path.startsWith('/itineraries')
            ? {'id': 7, 'title': 'Private saved trip', 'days': <dynamic>[]}
            : account ?? {'id': 1, 'email': 'user@example.test',
            'fullName': 'Traveler', 'role': 'ROLE_USER', 'token': 'test-token'}}
        : {'success': false, 'message': 'Session rejected'}), status,
        headers: {Headers.contentTypeHeader: [Headers.jsonContentType]});
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ProviderContainer container;
  late SessionAdapter adapter;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    container = ProviderContainer();
    adapter = SessionAdapter();
    container.read(dioProvider).httpClientAdapter = adapter;
    await container.read(authNotifierProvider.notifier).login('user@example.test', 'password');
  });

  tearDown(() => container.dispose());

  test('409 from itinerary API becomes a conflict without invalidating login', () async {
    adapter.status = 409;
    await expectLater(container.read(itineraryRepositoryProvider).updateActivities(7,
      const UpdateActivitiesRequestModel(version: 3, days: [])),
      throwsA(isA<ItineraryConflictException>()));
    expect(container.read(authNotifierProvider).isAuthenticated, isTrue);
  });

  test('401 removes stored token and clears authenticated state', () async {
    adapter.status = 401;
    await expectLater(container.read(dioProvider).get<dynamic>('/auth/profile'), throwsA(isA<DioException>()));
    expect(await container.read(secureStorageProvider).read(key: 'jwt_token'), isNull);
    expect(container.read(authNotifierProvider).isAuthenticated, isFalse);
  });

  test('403 keeps the session and reports permission failure', () async {
    adapter.status = 403;
    await expectLater(container.read(dioProvider).get<dynamic>('/admin/users'), throwsA(isA<DioException>()));
    expect(container.read(authNotifierProvider).isAuthenticated, isTrue);
    expect(await container.read(secureStorageProvider).read(key: 'jwt_token'), 'test-token');
  });

  test('failed login does not clear an already authenticated session', () async {
    adapter.status = 401;
    await expectLater(container.read(authNotifierProvider.notifier).login('user@example.test', 'wrong-password'), throwsException);
    expect(container.read(authNotifierProvider).isAuthenticated, isTrue);
    expect(await container.read(secureStorageProvider).read(key: 'jwt_token'), 'test-token');
  });

  test('401 for an old request does not erase a newer token', () async {
    adapter.status = 401;
    adapter.beforeResponse = () => container.read(secureStorageProvider).write(key: 'jwt_token', value: 'new-token');
    await expectLater(container.read(dioProvider).get<dynamic>('/auth/profile'), throwsA(isA<DioException>()));
    expect(await container.read(secureStorageProvider).read(key: 'jwt_token'), 'new-token');
    expect(container.read(sessionInvalidationProvider), 0);
  });

  test('rejected profile update never reports a local successful update', () async {
    adapter.status = 403;
    await expectLater(container.read(authNotifierProvider.notifier).updateProfile(fullName: 'Rejected name'), throwsException);
    expect(container.read(authNotifierProvider).fullName, 'Traveler');
  });

  test('logout clears the generated itinerary cache before another login', () async {
    await container.read(itineraryNotifierProvider.notifier).generateItinerary(
      const ItineraryRequestModel(title: 'Private saved trip', startDate: '2026-12-01', endDate: '2026-12-01',
        travelersCount: 1, maxBudgetVnd: 1000000, pace: 'balanced', preferredCategories: ['FOOD']));
    expect(container.read(itineraryNotifierProvider).generatedItinerary?.id, 7);
    await container.read(authNotifierProvider.notifier).logout();
    expect(container.read(itineraryNotifierProvider).generatedItinerary, isNull);
  });

  test('traveler profile is read from the server and cleared across sessions', () async {
    final auth = container.read(authNotifierProvider.notifier);
    final storage = container.read(secureStorageProvider);
    await storage.write(key: 'pref_interests', value: 'HOTEL');
    adapter.account = {
      'id': 1, 'email': 'user@example.test', 'fullName': 'Traveler',
      'role': 'ROLE_USER', 'token': 'first-session',
      'travelerProfile': const TravelerProfile(language: 'en', defaultTransport: 'taxi',
        preferredCategories: ['FOOD'], defaultBudgetVnd: 1200000).toJson(),
    };
    await auth.login('user@example.test', 'password');
    expect(container.read(authNotifierProvider).travelerProfile?.preferredCategories, ['FOOD']);
    await auth.updateProfile(fullName: 'Traveler', travelerProfile: const TravelerProfile(preferredCategories: ['CAFE']));
    expect(adapter.lastRequest?.data, containsPair('preferredCategories', ['CAFE']));
    expect(adapter.lastRequest?.data, containsPair('defaultBudgetVnd', null));
    await auth.logout();
    expect(container.read(authNotifierProvider).travelerProfile, isNull);
    adapter.account = {
      'id': 2, 'email': 'other@example.test', 'fullName': 'Other traveler',
      'role': 'ROLE_USER', 'token': 'second-session',
    };
    await auth.login('other@example.test', 'password');
    expect(container.read(authNotifierProvider).id, 2);
    expect(container.read(authNotifierProvider).travelerProfile?.preferredCategories, isEmpty);
  });

  test('network failure creates no session and failed account deletion preserves current session', () async {
    final auth = container.read(authNotifierProvider.notifier);
    adapter.status = 400;
    await expectLater(auth.deleteAccount('wrong pass'), throwsException);
    expect(container.read(authNotifierProvider).isAuthenticated, isTrue);
    expect(adapter.lastRequest?.data, containsPair('confirmed', true));
    await auth.logout();
    adapter.offline = true;
    await expectLater(auth.login('other@example.test', 'password'), throwsException);
    expect(container.read(authNotifierProvider).isAuthenticated, isFalse);
    expect(await container.read(secureStorageProvider).read(key: 'jwt_token'), isNull);
  });

  test('reset uses the real public API path without attaching current JWT', () async {
    final repo = container.read(authRepositoryProvider);
    await repo.requestPasswordReset('user@example.test');
    expect(adapter.lastRequest?.path, '/auth/forgot-password');
    expect(adapter.lastRequest?.headers.containsKey('Authorization'), isFalse);
    await repo.resetPassword('a' * 43, 'replacement password');
    expect(adapter.lastRequest?.path, '/auth/reset-password');
    expect(adapter.lastRequest?.headers.containsKey('Authorization'), isFalse);
  });
}
