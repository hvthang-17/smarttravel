import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarttravel_mobile/core/router/app_router.dart';
import 'package:smarttravel_mobile/core/theme/app_theme.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:smarttravel_mobile/core/localization/app_language.dart';
import 'package:smarttravel_mobile/features/auth/presentation/providers/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final translations = Map<String, String>.from(jsonDecode(
    await rootBundle.loadString('assets/translations/en.json'),
  ) as Map<String, dynamic>);
  runApp(ProviderScope(child: SmartTravelApp(translations: translations)));
}

class SmartTravelApp extends ConsumerWidget {
  final Map<String, String> translations;
  const SmartTravelApp({super.key, this.translations = const {}});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(authNotifierProvider.select((user) => user.travelerProfile?.language)) ?? 'vi';
    return AppLanguage(language: language, english: translations, child: MaterialApp.router(
      title: 'SmartTravel',
      locale: Locale(language),
      supportedLocales: const [Locale('vi'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    ));
  }
}
