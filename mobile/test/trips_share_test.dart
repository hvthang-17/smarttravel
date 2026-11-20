import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smarttravel_mobile/core/network/api_client.dart';
import 'package:smarttravel_mobile/core/router/app_router.dart';
import 'package:smarttravel_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:smarttravel_mobile/features/itinerary/data/models/itinerary_model.dart';
import 'package:smarttravel_mobile/features/itinerary/data/models/trip_management_models.dart';
import 'package:smarttravel_mobile/features/itinerary/data/repositories/itinerary_repository.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/widgets/itinerary/share_itinerary_dialog.dart';
import 'session_expiry_test.dart' show SessionAdapter;

const _shareToken = 'abcdef0123456789abcdef0123456789';

class TripTestRepository extends ItineraryRepository {
  TripTestRepository() : super(Dio());

  final queries = <(String, String, int)>[];
  final actions = <String>[];
  bool deleted = false;
  bool failDelete = true;

  @override
  Future<SavedTripPage> getSavedPage(String search, String period, int page) async {
    queries.add((search, period, page));
    final trips = <ItineraryResponseModel>[
      if (!deleted && (search.isEmpty || 'Biển Mỹ Khê'.contains(search)))
        ItineraryResponseModel.fromJson({
          'id': 8, 'title': 'Biển Mỹ Khê', 'status': 'SAVED',
          'period': 'HISTORY', 'endDate': '2025-01-01',
        }),
    ];
    return SavedTripPage(trips, !deleted && page == 0, trips.length);
  }

  @override
  Future<void> deleteTrip(int id) async {
    actions.add('delete:$id');
    if (failDelete) throw Exception('Chưa xóa được');
    deleted = true;
  }

  @override
  Future<TripShareLink> shareStatus(int id) async {
    actions.add('status');
    return const TripShareLink('EXPIRED', null, null);
  }

  @override
  Future<TripShareLink> shareItinerary(int id, {bool rotate = false}) async {
    actions.add(rotate ? 'rotate' : 'create');
    return TripShareLink('ACTIVE', Uri.parse('https://example.test/itineraries/shared/$_shareToken'),
      DateTime.now().add(const Duration(days: 7)));
  }

  @override
  Future<TripShareLink> revokeShare(int id) async {
    actions.add('revoke');
    return const TripShareLink('NONE', null, null);
  }
}

Future<ProviderContainer> _login(WidgetTester tester, TripTestRepository repo) async {
  FlutterSecureStorage.setMockInitialValues({});
  final container = ProviderContainer(overrides: [itineraryRepositoryProvider.overrideWithValue(repo)]);
  addTearDown(container.dispose);
  container.read(dioProvider).httpClientAdapter = SessionAdapter();
  await tester.runAsync(() => container.read(authNotifierProvider.notifier).login('user@example.test', 'password'));
  return container;
}

void main() {
  testWidgets('guest app deep link reads public route without authorization and displays expiry', (tester) async {
    FlutterSecureStorage.setMockInitialValues({'jwt_token': 'old-token'});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    var expired = false;
    var calls = 0;
    container.read(dioProvider).interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      expect(options.path, '/itineraries/shared/$_shareToken');
      expect(options.headers['Authorization'], isNull);
      calls++;
      if (expired) {
        handler.reject(DioException(requestOptions: options,
          response: Response(requestOptions: options, statusCode: 410), type: DioExceptionType.badResponse));
      } else {
        handler.resolve(Response<Map<String, dynamic>>(requestOptions: options, data: {
          'data': {
            'title': 'Chuyến biển', 'startDate': '2026-11-16', 'endDate': '2026-11-16',
            'days': [
              {'dayNumber': 1, 'date': '2026-11-16', 'items': [
                {'sequenceOrder': 1, 'destination': {'name': 'Bãi biển'}}
              ]}
            ],
          },
        }));
      }
    }));
    appRouter.go('smarttravel://share/itineraries/shared/$_shareToken');
    await tester.pumpWidget(UncontrolledProviderScope(container: container,
      child: MaterialApp.router(routerConfig: appRouter)));
    await tester.pumpAndSettle();
    expect(container.read(authNotifierProvider).isAuthenticated, isFalse);
    expect(find.text('Chuyến biển'), findsOneWidget);
    expect(find.textContaining('Chỉ xem'), findsOneWidget);
    expect(find.text('Lưu lịch trình'), findsNothing);
    expired = true;
    await tester.tap(find.byTooltip('Tải lại')); await tester.pumpAndSettle();
    expect(calls, 2);
    expect(find.text('Liên kết đã hết hạn'), findsOneWidget);
  });

  testWidgets('saved trips query history and page, leaving failed deletion visible', (tester) async {
    tester.view.physicalSize = const Size(500, 1024);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repo = TripTestRepository();
    final container = await _login(tester, repo);
    appRouter.go('/my-trips');
    await tester.pumpWidget(UncontrolledProviderScope(container: container,
      child: MaterialApp.router(routerConfig: appRouter)));
    await tester.pumpAndSettle();
    expect(find.text('Đã đi'), findsOneWidget);
    await tester.tap(find.text('Lịch sử')); await tester.pumpAndSettle();
    expect(repo.queries.last, ('', 'HISTORY', 0));
    await tester.ensureVisible(find.text('Tải thêm chuyến đi'));
    await tester.tap(find.text('Tải thêm chuyến đi')); await tester.pumpAndSettle();
    expect(repo.queries.last, ('', 'HISTORY', 1));
    for (final failing in [true, false]) {
      repo.failDelete = failing;
      await tester.ensureVisible(find.byTooltip('Tùy chọn chuyến đi'));
      await tester.tap(find.byTooltip('Tùy chọn chuyến đi')); await tester.pumpAndSettle();
      await tester.tap(find.text('Xóa chuyến đi')); await tester.pumpAndSettle();
      await tester.tap(find.text('Xóa chuyến đi')); await tester.pumpAndSettle();
      expect(find.text('Biển Mỹ Khê'), failing ? findsOneWidget : findsNothing);
    }
    expect(repo.actions, ['delete:8', 'delete:8']);
  });

  testWidgets('opening sharing does not publish, supports renewal, rotation and revoke', (tester) async {
    final repo = TripTestRepository();
    final container = await _login(tester, repo);
    await tester.pumpWidget(UncontrolledProviderScope(container: container,
      child: const MaterialApp(home: Scaffold(body: ShareItineraryDialog(itineraryId: 8, title: 'Biển')))));
    await tester.pumpAndSettle();
    expect(repo.actions, ['status']);
    expect(find.text('Liên kết đã hết hạn.'), findsOneWidget);
    await tester.tap(find.text('Tạo liên kết mới')); await tester.pumpAndSettle();
    await tester.tap(find.text('Thay liên kết')); await tester.pumpAndSettle();
    await tester.tap(find.text('Thu hồi')); await tester.pumpAndSettle();
    expect(repo.actions, ['status', 'create', 'rotate', 'revoke']);
    expect(find.text('Chưa có liên kết đang hoạt động.'), findsOneWidget);
  });
}
