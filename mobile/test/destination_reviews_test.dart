import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smarttravel_mobile/core/network/api_client.dart';
import 'package:smarttravel_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:smarttravel_mobile/features/destination/data/models/destination_review.dart';
import 'package:smarttravel_mobile/features/destination/data/repositories/destination_review_repository.dart';
import 'package:smarttravel_mobile/features/destination/presentation/providers/destination_reviews_provider.dart';
import 'package:smarttravel_mobile/features/destination/presentation/widgets/detail/destination_reviews_section.dart';
import 'session_expiry_test.dart' show SessionAdapter;

class ReviewTestRepository extends DestinationReviewRepository {
  ReviewTestRepository() : super(Dio());

  DestinationReview? own;
  final actions = <String>[];
  bool rejectReports = true;
  final _date = DateTime.utc(2026, 11, 16);

  @override
  Future<ReviewPage> list(int destination, int page) async => (
        items: [
          DestinationReview(8, 4, 'Nhận xét của người khác', null, _date),
          if (own?.status == 'PUBLISHED') own!,
        ],
        hasNext: false,
      );

  @override
  Future<DestinationReview?> mine(int destination, String token) async => own;

  @override
  Future<void> save(int destination, String token, ReviewInput input,
      {required bool existing}) async {
    actions.add(existing ? 'update' : 'create');
    own = DestinationReview(
        9, input.rating, input.comment, own?.status ?? 'PUBLISHED', _date);
  }

  @override
  Future<void> delete(int destination, String token) async {
    actions.add('delete');
    own = null;
  }

  @override
  Future<void> report(
      int destination, int review, String token, String reason) async {
    actions.add('report:$review:$reason');
    if (rejectReports) throw Exception('Chưa gửi được báo cáo');
  }
}

Future<void> _open(WidgetTester tester, ReviewTestRepository repo) async {
  tester.view.physicalSize = const Size(430, 940);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  FlutterSecureStorage.setMockInitialValues({});
  final container = ProviderContainer(
      overrides: [reviewRepositoryProvider.overrideWithValue(repo)]);
  addTearDown(container.dispose);
  container.read(dioProvider).httpClientAdapter = SessionAdapter();
  await tester.runAsync(() => container
      .read(authNotifierProvider.notifier)
      .login('user@example.test', 'password'));
  await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        home: Scaffold(
            body: SingleChildScrollView(
                child: DestinationReviewsSection(destinationId: 7))),
      )));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('writes, edits and deletes the signed-in traveler review',
      (tester) async {
    final repo = ReviewTestRepository();
    await _open(tester, repo);
    await tester.tap(find.text('Viết đánh giá'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Số sao'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('5 sao').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Đánh giá ban đầu');
    await tester.tap(find.text('Lưu đánh giá'));
    await tester.pumpAndSettle();
    expect(find.text('Đánh giá ban đầu'), findsOneWidget);
    await tester.tap(find.text('Sửa đánh giá của bạn'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Đánh giá đã sửa');
    await tester.tap(find.text('Lưu đánh giá'));
    await tester.pumpAndSettle();
    expect(find.text('Đánh giá đã sửa'), findsOneWidget);
    expect(find.text('Đánh giá ban đầu'), findsNothing);
    await tester.tap(find.text('Xóa đánh giá của bạn'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xóa đánh giá').last);
    await tester.pumpAndSettle();
    expect(repo.actions, ['create', 'update', 'delete']);
    expect(find.text('Viết đánh giá'), findsOneWidget);
    expect(find.text('Đánh giá đã sửa'), findsNothing);
  });

  testWidgets(
      'hidden owner review remains private and a report is confirmed after server success',
      (tester) async {
    final repo = ReviewTestRepository()
      ..own = DestinationReview(
          9, 5, 'Nội dung đang ẩn', 'HIDDEN', DateTime.utc(2026, 11, 16));
    await _open(tester, repo);
    expect(find.textContaining('đang bị ẩn'), findsOneWidget);
    expect(find.text('Nội dung đang ẩn'), findsNothing);
    for (final fails in [true, false]) {
      repo.rejectReports = fails;
      await tester.tap(find.text('Báo cáo đánh giá'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Quảng cáo hoặc spam'));
      await tester.pumpAndSettle();
      expect(find.text('Đã gửi báo cáo đến quản trị viên.'),
          fails ? findsNothing : findsOneWidget);
    }
    expect(repo.actions, ['report:8:SPAM', 'report:8:SPAM']);
    expect(find.text('Đã báo cáo'), findsOneWidget);
  });
}
