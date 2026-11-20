import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:smarttravel_mobile/core/network/api_client.dart';
import 'package:smarttravel_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:smarttravel_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:smarttravel_mobile/features/destination/presentation/providers/destination_provider.dart';
import 'package:smarttravel_mobile/features/itinerary/data/models/itinerary_model.dart';
import 'package:smarttravel_mobile/features/itinerary/data/repositories/itinerary_repository.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/screens/itinerary_detail_screen.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/screens/trip_wizard_screen.dart';
import 'favorite_discovery_test.dart' show DiscoveryTestRepository;
import 'session_expiry_test.dart' show SessionAdapter;

class PlanningRepository extends ItineraryRepository {
  PlanningRepository() : super(Dio());
  final requests = <Map<String, dynamic>>[];
  bool failFirst = true;
  int saveCalls = 0;
  late final fixture = (jsonDecode(File('../contracts/schema-sync.json').readAsStringSync()) as Map<String, dynamic>)['trip'] as Map<String, dynamic>;

  ItineraryResponseModel trip(String status) =>
    ItineraryResponseModel.fromJson({...fixture, 'status': status});

  @override
  Future<ItineraryResponseModel> generateItinerary(ItineraryRequestModel request) async {
    requests.add(request.toJson());
    if (failFirst) {
      failFirst = false;
      throw Exception('Mất kết nối. Hãy thử lại.');
    }
    return trip('DRAFT');
  }

  @override
  Future<ItineraryResponseModel> saveDraft(int id, String token) async {
    saveCalls++;
    return trip('SAVED');
  }
}

Future<ProviderContainer> loginForTrip(WidgetTester tester, PlanningRepository repo) async {
  FlutterSecureStorage.setMockInitialValues({});
  final container = ProviderContainer(overrides: [
    itineraryRepositoryProvider.overrideWithValue(repo),
    destinationRepositoryProvider.overrideWith((ref) => DiscoveryTestRepository(ApiClient(ref))),
    profileCategoriesProvider.overrideWith((ref) async => ['FOOD']),
  ]);
  addTearDown(container.dispose);
  container.read(dioProvider).httpClientAdapter = SessionAdapter()..account = {
    'id': 1, 'email': 'trip@example.test', 'fullName': 'Traveler', 'role': 'ROLE_USER', 'token': 'owner',
    'travelerProfile': {
      'defaultBudgetVnd': 3200000, 'defaultPace': 'relaxed', 'defaultTransport': 'taxi',
      'preferredCategories': ['FOOD'],
    },
  };
  await tester.runAsync(() => container.read(authNotifierProvider.notifier).login('trip@example.test', 'password'));
  return container;
}

void main() {
  testWidgets('wizard uses profile defaults and retries the same generation key with origin and constraints', (tester) async {
    tester.view.physicalSize = const Size(430, 940);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repo = PlanningRepository();
    final container = await loginForTrip(tester, repo);
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => const TripWizardScreen()),
      GoRoute(path: '/itineraries/:id', builder: (_, __) => const Scaffold(body: Text('Đã mở bản nháp'))),
    ]);
    addTearDown(router.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: container,
      child: MaterialApp.router(routerConfig: router)));
    await tester.pumpAndSettle();
    Future<void> tapText(String label) async {
      final target = find.text(label);
      await tester.ensureVisible(target);
      await tester.tap(target);
      await tester.pumpAndSettle();
    }
    await tapText('7 ngày 6 đêm');
    await tapText('Tiếp tục');
    expect(tester.widget<TextField>(find.byType(TextField)).controller?.text, '3200000');
    await tapText('Tiếp tục');
    await tester.ensureVisible(find.text('Chọn địa điểm (0/5)').first);
    await tester.tap(find.text('Chọn địa điểm (0/5)').first);
    await tester.pumpAndSettle();
    await tapText('Bản ghi đầu');
    await tapText('Tiếp tục');
    final textFields = find.byType(TextField);
    await tester.ensureVisible(textFields.at(1));
    await tester.enterText(textFields.at(1), 'Nơi ở tại Sơn Trà');
    await tester.enterText(find.widgetWithText(TextField, 'Vĩ độ'), '16,05');
    await tester.enterText(find.widgetWithText(TextField, 'Kinh độ'), '108.21');
    await tapText('Tạo bản nháp');
    expect(find.text('Mất kết nối. Hãy thử lại.'), findsOneWidget);
    await tapText('Tạo bản nháp');
    expect(find.text('Đã mở bản nháp'), findsOneWidget);
    expect(repo.requests, hasLength(2));
    expect(repo.requests[0], repo.requests[1]);
    expect(repo.requests.first, containsPair('generationKey', matches(r'^[a-f0-9]{32}$')));
    expect(repo.requests.first, containsPair('originName', 'Nơi ở tại Sơn Trà'));
    expect(repo.requests.first, containsPair('originLatitude', 16.05));
    expect(repo.requests.first, containsPair('originLongitude', 108.21));
    expect(repo.requests.first, containsPair('requiredDestinationIds', [1]));
    expect(repo.requests.first, containsPair('preferredCategories', ['FOOD']));
    expect(repo.requests.first, containsPair('maxBudgetVnd', 3200000));
    expect(repo.requests.first, containsPair('pace', 'relaxed'));
    expect(repo.requests.first, containsPair('transport', 'taxi'));
  });

  testWidgets('saving a private draft enables sharing only after server confirms SAVED', (tester) async {
    final repo = PlanningRepository();
    final container = await loginForTrip(tester, repo);
    final draft = repo.trip('DRAFT');
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: MaterialApp(
      home: ItineraryDetailScreen(id: draft.id, initialData: draft),
    )));
    await tester.pumpAndSettle();
    expect(find.text('Bản nháp riêng tư'), findsOneWidget);
    expect(find.byTooltip('Chia sẻ lịch trình'), findsNothing);
    await tester.tap(find.text('Lưu lịch trình'));
    await tester.pumpAndSettle();
    expect(repo.saveCalls, 1);
    expect(find.text('Bản nháp riêng tư'), findsNothing);
    expect(find.byTooltip('Chia sẻ lịch trình'), findsOneWidget);
  });
}
