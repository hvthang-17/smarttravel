import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smarttravel_mobile/core/network/api_client.dart';
import 'package:smarttravel_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:smarttravel_mobile/features/destination/data/models/destination_model.dart';
import 'package:smarttravel_mobile/features/destination/data/repositories/destination_repository.dart';
import 'package:smarttravel_mobile/features/destination/presentation/providers/destination_provider.dart';
import 'package:smarttravel_mobile/features/itinerary/data/models/itinerary_model.dart';
import 'package:smarttravel_mobile/features/itinerary/data/repositories/itinerary_repository.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/screens/edit_itinerary_screen.dart';
import 'session_expiry_test.dart' show SessionAdapter;

class ConflictRepository extends ItineraryRepository {
  ConflictRepository() : super(Dio());
  Map<String, dynamic>? submitted;
  bool failReload = false;
  @override
  Future<ItineraryResponseModel> updateActivities(int id, UpdateActivitiesRequestModel request) async {
    submitted = request.toJson();
    throw const ItineraryConflictException();
  }
  @override
  Future<ItineraryResponseModel?> getItineraryById(int id) async {
    if (failReload) throw Exception('offline');
    return ItineraryResponseModel.fromJson({'id': id, 'version': 4, 'title': 'Bản mới', 'days': <dynamic>[]});
  }
}

class CatalogForEdit extends DestinationRepository {
  CatalogForEdit(super.apiClient);

  @override
  Future<List<DestinationModel>> getDestinations({String? category}) async => [
    DestinationModel.fromJson({
      'id': 81, 'name': 'Điểm check-in mới', 'categoryCode': 'CHECKIN',
      'priceMinVnd': 10000, 'priceMaxVnd': 25000, 'suggestedVisitDurationMinutes': 45,
    }),
  ];
}

class RejectedEditRepository extends ConflictRepository {
  @override
  Future<ItineraryResponseModel> updateActivities(int id, UpdateActivitiesRequestModel request) async {
    submitted = request.toJson();
    throw Exception('Máy chủ bận, hãy thử lại');
  }
}

void main() {
  testWidgets('409 preserves local snapshot and version until discard is explicitly confirmed', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    FlutterSecureStorage.setMockInitialValues({});
    final repo = ConflictRepository();
    final container = ProviderContainer(overrides: [itineraryRepositoryProvider.overrideWithValue(repo)]);
    addTearDown(container.dispose);
    container.read(dioProvider).httpClientAdapter = SessionAdapter();
    await tester.runAsync(() => container.read(authNotifierProvider.notifier).login('user@example.test', 'password'));
    final fixture = jsonDecode(File('../contracts/schema-sync.json').readAsStringSync()) as Map<String, dynamic>;
    final trip = ItineraryResponseModel.fromJson(fixture['trip'] as Map<String, dynamic>);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: MaterialApp(home: EditItineraryScreen(id: trip.id, initialData: trip))));
    await tester.tap(find.byTooltip('Tùy chọn hoạt động')); await tester.pumpAndSettle();
    await tester.tap(find.text('Sửa giờ, thời lượng, ghi chú')); await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Ghi chú'), 'Ghi chú chưa gửi');
    await tester.tap(find.text('Áp dụng')); await tester.pumpAndSettle();
    await tester.tap(find.text('Hoàn tất')); await tester.pumpAndSettle();
    expect(repo.submitted!['version'], 3);
    final days = repo.submitted!['days'] as List<dynamic>;
    expect((days.first as Map<String, dynamic>)['items'], contains(containsPair('destinationId', null)));
    expect(find.text('Lịch trình đã thay đổi'), findsOneWidget);
    await tester.tap(find.text('Giữ bản sửa')); await tester.pumpAndSettle();
    expect(find.text('Địa điểm đã xóa'), findsOneWidget);
    expect(find.text('Ghi chú chưa gửi'), findsOneWidget);
    await tester.tap(find.text('Hoàn tất')); await tester.pumpAndSettle();
    await tester.tap(find.text('Xem bản mới')); await tester.pumpAndSettle();
    expect(find.text('Bỏ bản sửa và tải lại'), findsOneWidget);
    await tester.tap(find.text('Giữ bản sửa')); await tester.pumpAndSettle();
    expect(find.text('Địa điểm đã xóa'), findsOneWidget);
    repo.failReload = true;
    await tester.tap(find.text('Hoàn tất')); await tester.pumpAndSettle();
    await tester.tap(find.text('Xem bản mới')); await tester.pumpAndSettle();
    expect(find.text('Không tải được bản mới. Bản sửa vẫn được giữ.'), findsOneWidget);
    expect(find.text('Địa điểm đã xóa'), findsOneWidget);
    expect(repo.submitted!['version'], 3);
  });

  testWidgets('catalog quote previews ceiling and duration, sends a real destination ID and retains a failed edit', (tester) async {
    tester.view.physicalSize = const Size(390, 850);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    FlutterSecureStorage.setMockInitialValues({});
    final repo = RejectedEditRepository();
    final container = ProviderContainer(overrides: [
      itineraryRepositoryProvider.overrideWithValue(repo),
      destinationRepositoryProvider.overrideWith((ref) => CatalogForEdit(ApiClient(ref))),
    ]);
    addTearDown(container.dispose);
    container.read(dioProvider).httpClientAdapter = SessionAdapter();
    await tester.runAsync(() => container.read(authNotifierProvider.notifier).login('user@example.test', 'password'));
    final trip = ItineraryResponseModel.fromJson({
      'id': 7, 'version': 3, 'travelersCount': 2,
      'days': [{'id': 90, 'dayNumber': 1, 'items': <Map<String, dynamic>>[]}],
    });
    await tester.pumpWidget(UncontrolledProviderScope(container: container,
      child: MaterialApp(home: EditItineraryScreen(id: 7, initialData: trip))));
    await tester.tap(find.text('Thêm địa điểm vào Ngày 1')); await tester.pumpAndSettle();
    expect(find.textContaining('25.000 đ/khách · 45 phút'), findsOneWidget);
    await tester.tap(find.text('Điểm check-in mới')); await tester.pumpAndSettle();
    expect(find.text('Chưa đặt giờ · 45 phút'), findsOneWidget);
    expect(find.text('50.000 đ'), findsOneWidget);
    await tester.tap(find.text('Hoàn tất')); await tester.pumpAndSettle();
    final day = (repo.submitted!['days'] as List).single as Map;
    final item = (day['items'] as List).single as Map;
    expect(item['destinationId'], 81);
    expect(item.containsKey('id'), isFalse);
    expect(item.containsKey('estimatedCostVnd'), isFalse);
    expect(item['durationMinutes'], isNull);
    expect(find.text('Điểm check-in mới'), findsOneWidget);
    expect(find.text('Máy chủ bận, hãy thử lại'), findsOneWidget);
    expect(find.textContaining('thành công'), findsNothing);
    await tester.tap(find.byTooltip('Đóng')); await tester.pumpAndSettle();
    expect(find.text('Có thay đổi chưa lưu'), findsOneWidget);
    await tester.tap(find.text('Tiếp tục chỉnh sửa')); await tester.pumpAndSettle();
    expect(find.text('Điểm check-in mới'), findsOneWidget);

  });
}
