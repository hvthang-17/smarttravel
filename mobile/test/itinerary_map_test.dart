import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smarttravel_mobile/features/itinerary/data/models/itinerary_model.dart';
import 'package:smarttravel_mobile/features/itinerary/data/repositories/itinerary_repository.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/widgets/itinerary/itinerary_map_view.dart';

void main() {
  test('map only uses valid provider geometry in longitude, latitude order', () {
    final item = {
      'id': 1,
      'sequenceOrder': 1,
      'routePolyline': '[[108.2,16.05],[108.21,16.06],[108.23,16.05]]',
    };
    for (final source in ['PROVIDER', 'CACHE']) {
      final points = itineraryRoutePoints(ItineraryItemModel.fromJson({...item, 'routeSource': source}));
      expect(points, hasLength(3));
      expect(points[1].latitude, 16.06);
      expect(points[1].longitude, 108.21);
    }
    for (final source in ['HAVERSINE', 'UNKNOWN']) {
      expect(itineraryRoutePoints(ItineraryItemModel.fromJson({...item, 'routeSource': source})), isEmpty);
    }
    for (final bad in ['x', '[[180,91],[108,16]]', '[[108,16],["108",16]]']) {
      expect(itineraryRoutePoints(ItineraryItemModel.fromJson({
        ...item, 'routeSource': 'PROVIDER', 'routePolyline': bad,
      })), isEmpty);
    }
  });

  test('saved trips remain readable on outage while authorization errors reject cache', () async {
    final fixture = (jsonDecode(File('../contracts/schema-sync.json').readAsStringSync())
        as Map<String, dynamic>)['trip'] as Map<String, dynamic>;
    final trip = {...fixture, 'status': 'SAVED'};
    final id = trip['id'] as int;
    final dio = Dio();
    int? failure;
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      if (failure == null) {
        handler.resolve(Response(requestOptions: options, data: {
          'data': options.path == '/itineraries' ? [trip] : trip,
        }));
      } else {
        handler.reject(DioException(
          requestOptions: options,
          type: failure == 0 ? DioExceptionType.connectionError : DioExceptionType.badResponse,
          response: failure == 0 ? null : Response(requestOptions: options, statusCode: failure),
        ));
      }
    }));
    final repository = ItineraryRepository(dio);
    expect((await repository.getMyItineraries()).single.id, id);
    failure = 0;
    expect((await repository.getMyItineraries()).single.id, id);
    expect(repository.usedCachedList, isTrue);
    expect((await repository.getItineraryById(id))?.id, id);
    expect(repository.usedCachedTrip(id), isTrue);
    await expectLater(ItineraryRepository(dio).getItineraryById(id), throwsException);
    failure = 403;
    await expectLater(repository.getItineraryById(id), throwsException);
    failure = 503;
    await expectLater(repository.getItineraryById(id), throwsException);
  });
}
