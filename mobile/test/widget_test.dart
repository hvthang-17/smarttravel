import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smarttravel_mobile/main.dart';

void main() {
  testWidgets('SmartTravelApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: SmartTravelApp()));
    expect(find.byType(SmartTravelApp), findsOneWidget);
  });
}
