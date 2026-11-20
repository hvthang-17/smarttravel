import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smarttravel_mobile/features/itinerary/data/models/itinerary_model.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/screens/itinerary_detail_screen.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/screens/edit_itinerary_screen.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/widgets/itinerary/itinerary_guest_view.dart';

void main() {
  final cached = ItineraryResponseModel.fromJson({'id': 1, 'title': 'Private saved trip', 'days': <dynamic>[]});

  testWidgets('unauthenticated detail never displays cached private itinerary', (tester) async {
    await tester.pumpWidget(ProviderScope(child: MaterialApp(home: ItineraryDetailScreen(id: 1, initialData: cached))));
    expect(find.byType(ItineraryGuestView), findsOneWidget);
    expect(find.text('Private saved trip'), findsNothing);
  });

  testWidgets('unauthenticated editor never displays cached private itinerary', (tester) async {
    await tester.pumpWidget(ProviderScope(child: MaterialApp(home: EditItineraryScreen(id: 1, initialData: cached))));
    expect(find.byType(ItineraryGuestView), findsOneWidget);
    expect(find.text('Private saved trip'), findsNothing);
  });
}
