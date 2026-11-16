import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smarttravel_mobile/features/destination/data/models/destination_model.dart';
import 'package:smarttravel_mobile/features/itinerary/data/models/itinerary_model.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/widgets/itinerary/budget_health_meter.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/widgets/itinerary/travel_leg_connector.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/widgets/itinerary/timeline_activity_card.dart';

void main() {
  final fixture = jsonDecode(File('../contracts/schema-sync.json').readAsStringSync()) as Map<String, dynamic>;
  test('shared destination preserves canonical NULL, schedule and zero coordinates', () {
    final point = DestinationModel.fromJson(fixture['destination'] as Map<String, dynamic>);
    expect(point.rating, isNull); expect(point.reviewCount, isNull);
    expect(point.latitude, 0); expect(point.longitude, 0); expect(point.hasCoordinates, isTrue);
    expect(point.appRating, 3); expect(point.priceMinVnd, isNull);
    expect(point.toJson()['openingSchedule'], fixture['destination']['openingSchedule']);
    expect(DestinationModel.fromJson({'rating': 4.2}).rating, 4.2);
  });
  test('snapshot without destination ID stays nullable and sends current version', () {
    final trip = ItineraryResponseModel.fromJson(fixture['trip'] as Map<String, dynamic>);
    final item = trip.days.first.items.first;
    expect(item.destination!.id, isNull); expect(item.destination!.hasCoordinates, isFalse);
    expect(item.estimatedCostVnd, isNull); expect(item.travelMinutes, isNull);
    expect(item.routeSource, 'UNKNOWN'); expect(trip.budgetHealth, 'UNKNOWN');
    expect(ItineraryResponseModel.fromJson({}).version, 0);
    final request = UpdateActivitiesRequestModel(version: trip.version, days: [DayUpdateModel(dayId: trip.days.first.id, items: [ItemUpdateModel(id: item.id, destinationId: item.destination!.id, sequenceOrder: 1)])]);
    expect(request.toJson(), fixture['update']);
    expect(() => const ItemUpdateModel(sequenceOrder: 1).toJson(), throwsStateError);
    expect(() => const ItemUpdateModel(destinationId: 0, sequenceOrder: 1).toJson(), throwsStateError);
    expect(() => const UpdateActivitiesRequestModel(version: 0, days: []).toJson(), throwsStateError);
  });
  testWidgets('unknown budget and route show missing data instead of safe budget or zero minutes', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Column(children: [
      BudgetHealthMeter(totalEstimatedCost: 0, maxBudgetVnd: 100000, budgetUtilizationPercent: 0, budgetHealth: 'UNKNOWN'),
      TravelLegConnector(distanceKm: null, durationMinutes: null),
    ]))));
    expect(find.text('Chưa đủ dữ liệu chi phí'), findsOneWidget);
    expect(find.textContaining('0 phút'), findsNothing);
    expect(find.textContaining('Còn lại'), findsNothing);
  });

  testWidgets('itinerary activity displays editorial reason and lower-bound cost', (tester) async {
    final item = ItineraryItemModel.fromJson({
      'id': 1,
      'sequenceOrder': 1,
      'featuredRecommendation': true,
      'recommendationReason': 'Trải nghiệm biển tiêu biểu',
      'estimatedCostVnd': 30000,
      'upperPriceKnown': false,
    });
    await tester.pumpWidget(MaterialApp(home: Scaffold(
      body: TimelineActivityCard(item: item, onTap: () {}),
    )));
    expect(find.text('Điểm tiêu biểu được đề xuất'), findsOneWidget);
    expect(find.text('Trải nghiệm biển tiêu biểu'), findsOneWidget);
    expect(find.text('Chi phí theo mức tối thiểu đã biết'), findsOneWidget);
  });
}
