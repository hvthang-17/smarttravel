import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarttravel_mobile/core/router/app_router.dart';
import 'package:smarttravel_mobile/core/theme/app_theme.dart';

void main() => runApp(const ProviderScope(child: SmartTravelApp()));

class SmartTravelApp extends StatelessWidget {
  const SmartTravelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SmartTravel',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}


