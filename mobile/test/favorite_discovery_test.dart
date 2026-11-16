import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smarttravel_mobile/core/network/api_client.dart';
import 'package:smarttravel_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:smarttravel_mobile/features/destination/data/models/destination_model.dart';
import 'package:smarttravel_mobile/features/destination/data/models/discovery_models.dart';
import 'package:smarttravel_mobile/features/destination/data/repositories/destination_repository.dart';
import 'package:smarttravel_mobile/features/destination/presentation/providers/destination_provider.dart';
import 'package:smarttravel_mobile/features/destination/presentation/providers/favorite_provider.dart';
import 'package:smarttravel_mobile/features/destination/presentation/screens/destination_list_screen.dart';
import 'package:smarttravel_mobile/features/destination/presentation/widgets/destination_display.dart';
import 'package:smarttravel_mobile/features/destination/presentation/widgets/detail/destination_main_info_card.dart';
import 'package:smarttravel_mobile/features/itinerary/data/models/itinerary_model.dart';
import 'session_expiry_test.dart' show SessionAdapter;

DestinationModel destination(int id, String name) => DestinationModel.fromJson({
      'id': id,
      'name': name,
      'category': 'Ẩm thực Đà Nẵng',
      'categoryNameEn': 'Da Nang food',
      'latitude': 16.05,
      'longitude': 108.2,
    });

class DiscoveryTestRepository extends DestinationRepository {
  DiscoveryTestRepository(super.apiClient);
  bool failSearch = false;
  DiscoveryQuery? lastQuery;
  final Map<String, List<DestinationModel>> saved = {};

  @override
  Future<List<DestinationCategory>> categories() async =>
      const [DestinationCategory('FOOD', 'Ẩm thực Đà Nẵng', 'Da Nang food')];

  @override
  Future<DiscoveryPage> discover(DiscoveryQuery query) async {
    lastQuery = query;
    if (failSearch) throw Exception('offline');
    if (query.search == 'Không có') return const DiscoveryPage([], false);
    return DiscoveryPage([
      destination(
          query.page + 1, query.page == 0 ? 'Bản ghi đầu' : 'Bản ghi tiếp')
    ], query.page == 0);
  }

  @override
  Future<List<DestinationModel>> getFavorites(String token) async =>
      [...?saved[token]];

  @override
  Future<DestinationModel> addFavorite(int id, String token) async {
    final item = destination(id, 'Điểm đã lưu');
    saved.putIfAbsent(token, () => []).add(item);
    return item;
  }
}

void main() {
  test('price, weekly schedule, maps and media retain real values and unknowns',
      () {
    expect(formatDestinationPrice(null, null), 'Chưa rõ giá');
    expect(formatDestinationPrice(0, null), 'Từ 0 đ');
    expect(formatDestinationPrice(0, 20000), '0 đ – 20.000 đ');
    expect(formatDestinationPrice(0, 0), 'Miễn phí');
    final place = DestinationModel.fromJson({
      'name': 'Bảo tàng',
      'nameEn': ' ',
      'latitude': 16.07211,
      'longitude': 108.22009,
      'openingSchedule': {
        'week': {
          for (var day = 1; day <= 7; day++)
            '$day': [
              [360, 1260]
            ]
        }
      },
    });
    expect(formatOpeningSchedule(place), 'T2–CN: 06:00–21:00');
    expect(destinationName(place, 'en'), 'Bảo tàng');
    expect(destinationMapUri(place)?.queryParameters['query'],
        '16.07211,108.22009');
    expect(destinationImageUrl('/uploads/destinations/cover.png'),
        endsWith('/uploads/destinations/cover.png'));
    expect(destinationImageUrl('javascript:ignore'), isNull);
  });

  testWidgets('detail displays independent ratings and localized catalog label',
      (tester) async {
    final point = DestinationModel.fromJson({
      'name': 'Quán',
      'nameEn': 'Restaurant',
      'category': 'Món địa phương',
      'categoryNameEn': 'Local food',
      'googleRating': null,
      'googleReviewCount': null,
      'appRating': 4.2,
      'appReviewCount': 3,
    });
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body:
                DestinationMainInfoCard(destination: point, language: 'en'))));
    expect(find.text('Restaurant'), findsOneWidget);
    expect(find.text('Local food'), findsOneWidget);
    expect(find.text('Google Maps · Chưa có điểm · chưa rõ số lượt'),
        findsOneWidget);
    expect(find.text('SmartTravel · 4.2/5 · 3 lượt đánh giá'), findsOneWidget);
    expect(find.text('Chưa rõ giá tham khảo'), findsOneWidget);
    expect(find.text('Miễn phí'), findsNothing);
  });

  testWidgets('search resets pagination and shows empty and retry states',
      (tester) async {
    late DiscoveryTestRepository repo;
    await tester.pumpWidget(ProviderScope(
      overrides: [
        destinationRepositoryProvider.overrideWith(
            (ref) => repo = DiscoveryTestRepository(ApiClient(ref)))
      ],
      child: const MaterialApp(home: DestinationListScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Bản ghi đầu'), findsOneWidget);
    final next = find.byTooltip('Trang tiếp');
    await tester.ensureVisible(next);
    await tester.tap(next);
    await tester.pumpAndSettle();
    expect(repo.lastQuery?.page, 1);
    await tester.enterText(find.byType(TextFormField).first, 'Không có');
    await tester.tap(find.text('Áp dụng bộ lọc'));
    await tester.pumpAndSettle();
    expect(repo.lastQuery?.page, 0);
    expect(find.text('Không có địa điểm khớp với bộ lọc.'), findsOneWidget);
    repo.failSearch = true;
    await tester.tap(find.text('Xóa bộ lọc'));
    await tester.pumpAndSettle();
    expect(find.text('Không tải được địa điểm.'), findsOneWidget);
    repo.failSearch = false;
    await tester.tap(find.text('Thử lại'));
    await tester.pumpAndSettle();
    expect(find.text('Bản ghi đầu'), findsOneWidget);
  });

  test(
      'favorites reload from the server for each session and selected IDs reach wizard request',
      () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    FlutterSecureStorage.setMockInitialValues({});
    final container = ProviderContainer(overrides: [
      destinationRepositoryProvider
          .overrideWith((ref) => DiscoveryTestRepository(ApiClient(ref))),
    ]);
    addTearDown(container.dispose);
    final adapter = SessionAdapter();
    container.read(dioProvider).httpClientAdapter = adapter;
    final notifier = container.read(authNotifierProvider.notifier);
    await notifier.login('user@example.test', 'test-pass');
    await container.read(favoritesProvider.notifier).reload();
    await container.read(favoritesProvider.notifier).toggle(21);
    expect(container.read(favoritesProvider).valueOrNull?.single.id, 21);
    await notifier.logout();
    expect(container.read(favoritesProvider).valueOrNull, isEmpty);
    adapter.account = {
      'id': 2,
      'email': 'other@example.test',
      'role': 'ROLE_USER',
      'token': 'other-session'
    };
    await notifier.login('other@example.test', 'test-pass');
    await container.read(favoritesProvider.notifier).reload();
    expect(container.read(favoritesProvider).valueOrNull, isEmpty);
    await notifier.logout();
    adapter.account = null;
    await notifier.login('user@example.test', 'test-pass');
    await container.read(favoritesProvider.notifier).reload();
    expect(container.read(favoritesProvider).valueOrNull?.single.id, 21);
    const request = ItineraryRequestModel(
        title: 'Chuyến đi',
        startDate: '2026-12-01',
        endDate: '2026-12-01',
        travelersCount: 1,
        maxBudgetVnd: 1000000,
        pace: 'balanced',
        preferredCategories: ['FOOD'],
        favoriteDestinationIds: [21]);
    expect(request.toJson()['favoriteDestinationIds'], [21]);
  });
}
