import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smarttravel_mobile/core/localization/app_language.dart';
import 'package:smarttravel_mobile/features/itinerary/data/models/itinerary_model.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/widgets/itinerary/itinerary_bottom_bar.dart';

void main() {
  final english = Map<String, String>.from(
    jsonDecode(File('assets/translations/en.json').readAsStringSync()) as Map,
  );

  testWidgets('changing language retains form input and falls back for untranslated content', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    Widget view(String language) => AppLanguage(
      language: language, english: english,
      child: MaterialApp(home: Scaffold(body: Column(children: [
        const AppText('Lưu thay đổi'),
        const AppText('Tên riêng chưa có bản dịch'),
        TextField(controller: controller),
      ]))),
    );
    await tester.pumpWidget(view('vi'));
    await tester.enterText(find.byType(TextField), 'Bản sửa chưa gửi');
    await tester.pumpWidget(view('en'));
    expect(find.text('Save changes'), findsOneWidget);
    expect(find.text('Tên riêng chưa có bản dịch'), findsOneWidget);
    expect(controller.text, 'Bản sửa chưa gửi');
    await tester.pumpWidget(view('vi'));
    expect(find.text('Lưu thay đổi'), findsOneWidget);
  });

  testWidgets('draft actions fit a small screen at 200 percent text size in both languages', (tester) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final trip = ItineraryResponseModel.fromJson({'id': 1, 'status': 'DRAFT', 'days': <dynamic>[]});
    for (final language in ['vi', 'en']) {
      await tester.pumpWidget(AppLanguage(language: language, english: english,
        child: MaterialApp(home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Scaffold(bottomNavigationBar: ItineraryBottomBar(
            itinerary: trip, onItineraryUpdated: (_) {}, onSave: () {}, saving: false,
          )),
        )),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      for (final button in find.byWidgetPredicate((widget) => widget is ButtonStyleButton).evaluate()) {
        final box = button.renderObject as RenderBox;
        expect(box.size.height, greaterThanOrEqualTo(48));
      }
    }
  });
}
