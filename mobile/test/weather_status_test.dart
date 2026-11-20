import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smarttravel_mobile/features/weather/data/models/weather_model.dart';
import 'package:smarttravel_mobile/features/weather/data/repositories/weather_repository.dart';
import 'package:smarttravel_mobile/features/weather/presentation/providers/weather_provider.dart';
import 'package:smarttravel_mobile/features/weather/presentation/widgets/weather_pill.dart';

void main() {
  test('weather forwards timezone and locale and keeps stale model time', () async {
    final validAt = DateTime.now().toUtc().subtract(const Duration(hours: 1));
    final dio = Dio()..interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      expect(options.queryParameters, {
        'timezone': 'Asia/Ho_Chi_Minh', 'locale': 'en', 'lat': 16.05, 'lon': 108.2,
      });
      handler.resolve(Response<Map<String, dynamic>>(requestOptions: options, data: {
        'data': {'validAt': validAt.toIso8601String(), 'status': 'STALE',
          'source': 'OPEN_METEO_MODEL', 'temperature': 26.0},
      }));
    }));
    final data = await WeatherRepository(dio).getDaNangWeather(lat: 16.05, lon: 108.2, locale: 'en');
    expect(data.validAt, validAt);
    expect(data.pillText, contains('Dữ liệu cũ'));
    expect(data.pillText, contains('26°C'));
    expect(WeatherData.fromJson({'temperature': 29.0, 'updatedAt': 'Vừa xong'}).temperature, isNull);
  });

  testWidgets('unavailable weather offers retry without showing a temperature', (tester) async {
    await tester.pumpWidget(ProviderScope(overrides: [
      weatherProvider.overrideWith((ref) async => const WeatherData.unavailable()),
    ], child: const MaterialApp(home: Scaffold(body: WeatherPill()))));
    await tester.pumpAndSettle();
    expect(find.text('Thời tiết chưa có dữ liệu'), findsOneWidget);
    await tester.tap(find.text('Thời tiết chưa có dữ liệu'));
    await tester.pumpAndSettle();
    expect(find.text('Chưa có dữ liệu thời tiết'), findsOneWidget);
    expect(find.textContaining('°C'), findsNothing);
    expect(find.text('Thử lại'), findsOneWidget);
  });
}
