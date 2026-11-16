import 'package:smarttravel_mobile/core/localization/app_language.dart';
import 'package:smarttravel_mobile/features/destination/presentation/screens/favorites_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarttravel_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:smarttravel_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:smarttravel_mobile/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:smarttravel_mobile/features/profile/presentation/screens/profile_screen.dart';
import 'package:smarttravel_mobile/features/auth/presentation/screens/register_screen.dart';
import 'package:smarttravel_mobile/features/auth/presentation/screens/splash_screen.dart';
import 'package:smarttravel_mobile/features/destination/presentation/screens/destination_detail_screen.dart';
import 'package:smarttravel_mobile/features/destination/presentation/screens/destination_list_screen.dart';
import 'package:smarttravel_mobile/features/home/presentation/screens/home_screen.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/screens/edit_itinerary_screen.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/screens/itinerary_detail_screen.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/screens/my_trips_screen.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/screens/trip_wizard_screen.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/screens/trip_drafts_screen.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/screens/shared_trip_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const RootNavigationScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/trip-wizard',
      builder: (context, state) => Consumer(builder: (context, ref, _) {
        final token = ref.watch(authNotifierProvider.select((user) => user.token));
        return TripWizardScreen(key: ValueKey(token),
          initialFavoriteId: int.tryParse(state.uri.queryParameters['favorite'] ?? ''));
      }),
    ),
    GoRoute(
      path: '/my-trips',
      builder: (context, state) => const MyTripsScreen(),
    ),
    GoRoute(path: '/trip-drafts', builder: (context, state) => const TripDraftsScreen()),
    GoRoute(
      path: '/itineraries/shared/:token',
      builder: (context, state) => SharedTripScreen(token: state.pathParameters['token']!),
    ),
    GoRoute(
      path: '/itineraries/:id',
      builder: (context, state) {
        final idStr = state.pathParameters['id'] ?? '0';
        final id = int.tryParse(idStr) ?? 0;
        return Consumer(builder: (context, ref, _) {
          final session = ref.watch(authNotifierProvider.select((user) => user.token));
          return ItineraryDetailScreen(key: ValueKey(session), id: id);
        });
      },
    ),
    GoRoute(
      path: '/itineraries/:id/edit',
      builder: (context, state) {
        final idStr = state.pathParameters['id'] ?? '0';
        final id = int.tryParse(idStr) ?? 0;
        return Consumer(builder: (context, ref, _) {
          final session = ref.watch(authNotifierProvider.select((user) => user.token));
          return EditItineraryScreen(key: ValueKey(session), id: id);
        });
      },
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(path: '/favorites', builder: (context, state) => const FavoritesScreen()),
    GoRoute(
      path: '/destinations',
      builder: (context, state) => Consumer(builder: (context, ref, _) {
        final token = ref.watch(authNotifierProvider.select((user) => user.token));
        return DestinationListScreen(key: ValueKey(token),
          initialSearch: state.uri.queryParameters['search'] ?? '',
          initialCategory: state.uri.queryParameters['category']);
      }),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final idStr = state.pathParameters['id'] ?? '0';
            final id = int.tryParse(idStr) ?? 0;
            return DestinationDetailScreen(id: id);
          },
        ),
      ],
    ),
  ],
);

class RootNavigationScreen extends ConsumerStatefulWidget {
  const RootNavigationScreen({super.key});

  @override
  ConsumerState<RootNavigationScreen> createState() => _RootNavigationScreenState();
}

class _RootNavigationScreenState extends ConsumerState<RootNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    TripWizardScreen(),
    MyTripsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        key: ValueKey(ref.watch(authNotifierProvider.select((user) => user.token))),
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFE0F2FE),
          elevation: 0,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.explore_outlined, color: Color(0xFF64748B)),
              selectedIcon: const Icon(Icons.explore, color: Color(0xFF0077B6)),
              label: AppLanguage.text(context, 'Khám phá'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.add_location_alt_outlined,
                  color: Color(0xFF64748B)),
              selectedIcon:
                  const Icon(Icons.add_location_alt, color: Color(0xFF0077B6)),
              label: AppLanguage.text(context, 'Tạo chuyến đi'),
            ),
            NavigationDestination(
              icon:
                  const Icon(Icons.calendar_month_outlined, color: Color(0xFF64748B)),
              selectedIcon:
                  const Icon(Icons.calendar_month, color: Color(0xFF0077B6)),
              label: AppLanguage.text(context, 'Lịch trình'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline, color: Color(0xFF64748B)),
              selectedIcon: const Icon(Icons.person, color: Color(0xFF0077B6)),
              label: AppLanguage.text(context, 'Hồ sơ'),
            ),
          ],
        ),
      ),
    );
  }
}
