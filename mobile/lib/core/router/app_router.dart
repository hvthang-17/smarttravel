import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smarttravel_mobile/features/destination/data/models/itinerary_model.dart';
import 'package:smarttravel_mobile/features/destination/presentation/screens/home_screen.dart';
import 'package:smarttravel_mobile/features/destination/presentation/screens/profile_screen.dart';
import 'package:smarttravel_mobile/features/destination/presentation/screens/destination_detail_screen.dart';
import 'package:smarttravel_mobile/features/destination/presentation/screens/destination_list_screen.dart';
import 'package:smarttravel_mobile/features/destination/presentation/screens/edit_itinerary_screen.dart';
import 'package:smarttravel_mobile/features/destination/presentation/screens/my_trips_screen.dart';
import 'package:smarttravel_mobile/features/destination/presentation/screens/trip_wizard_screen.dart';
import 'package:smarttravel_mobile/features/destination/presentation/screens/itinerary_detail_screen.dart';
import 'package:smarttravel_mobile/features/destination/presentation/screens/login_screen.dart';
import 'package:smarttravel_mobile/features/destination/presentation/screens/register_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
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
      builder: (context, state) => const TripWizardScreen(),
    ),
    GoRoute(
      path: '/my-trips',
      builder: (context, state) => const MyTripsScreen(),
    ),
    GoRoute(
      path: '/itineraries/:id',
      builder: (context, state) {
        final idStr = state.pathParameters['id'] ?? '0';
        final id = int.tryParse(idStr) ?? 0;
        final initialData = state.extra is ItineraryResponseModel
            ? state.extra as ItineraryResponseModel
            : null;
        return ItineraryDetailScreen(id: id, initialData: initialData);
      },
    ),
    GoRoute(
      path: '/itineraries/:id/edit',
      builder: (context, state) {
        final idStr = state.pathParameters['id'] ?? '0';
        final id = int.tryParse(idStr) ?? 0;
        final initialData = state.extra is ItineraryResponseModel
            ? state.extra as ItineraryResponseModel
            : null;
        return EditItineraryScreen(id: id, initialData: initialData);
      },
    ),

    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),

    GoRoute(
      path: '/destinations',
      builder: (context, state) => const DestinationListScreen(),
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

class RootNavigationScreen extends StatefulWidget {
  const RootNavigationScreen({super.key});

  @override
  State<RootNavigationScreen> createState() => _RootNavigationScreenState();
}

class _RootNavigationScreenState extends State<RootNavigationScreen> {
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
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.explore_outlined, color: Color(0xFF64748B)),
              selectedIcon: Icon(Icons.explore, color: Color(0xFF0077B6)),
              label: 'Khám phá',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_location_alt_outlined, color: Color(0xFF64748B)),
              selectedIcon: Icon(Icons.add_location_alt, color: Color(0xFF0077B6)),
              label: 'Tạo chuyến đi',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined, color: Color(0xFF64748B)),
              selectedIcon: Icon(Icons.calendar_month, color: Color(0xFF0077B6)),
              label: 'Lịch trình',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline, color: Color(0xFF64748B)),
              selectedIcon: Icon(Icons.person, color: Color(0xFF0077B6)),
              label: 'Hồ sơ',
            ),
          ],
        ),
      ),
    );
  }
}


