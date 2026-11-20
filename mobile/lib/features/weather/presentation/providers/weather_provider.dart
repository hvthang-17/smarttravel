import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarttravel_mobile/core/services/location_service.dart';
import 'package:smarttravel_mobile/features/weather/data/models/weather_model.dart';
import 'package:smarttravel_mobile/features/weather/data/repositories/weather_repository.dart';
import 'package:smarttravel_mobile/features/auth/presentation/providers/auth_provider.dart';

final weatherProvider = FutureProvider<WeatherData>((ref) async {
  final repository = ref.watch(weatherRepositoryProvider);
  final locationService = ref.watch(locationServiceProvider);
  final locale = ref.watch(authNotifierProvider.select((user) => user.travelerProfile?.language)) == 'en' ? 'en' : 'vi';
  final refresh = Timer(const Duration(minutes: 15), ref.invalidateSelf);
  ref.onDispose(refresh.cancel);

  // 1. Try fetching current GPS position automatically
  final position = await locationService.getCurrentLocation(requestIfNeeded: true);

  if (position != null) {
    // 2. Fetch hyper-local weather for user's exact GPS coordinates
    return repository.getDaNangWeather(
      lat: position.latitude,
      lon: position.longitude,
      locale: locale,
    );
  }

  // 3. Fallback to Da Nang city-wide weather
  return repository.getDaNangWeather(locale: locale);
});
