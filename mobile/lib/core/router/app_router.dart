import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smarttravel_mobile/features/destination/presentation/screens/destination_detail_screen.dart';
import 'package:smarttravel_mobile/features/destination/presentation/screens/destination_list_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const RootNavigationScreen(),
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

class RootNavigationScreen extends StatelessWidget {
  const RootNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SmartTravel Đà Nẵng')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Lên kế hoạch cho chuyến đi Đà Nẵng',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          const Text(
            'Nhập sở thích, ngân sách và thời lượng để nhận lịch trình phù hợp.',
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Tạo lịch trình'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => context.push('/destinations'),
            icon: const Icon(Icons.explore),
            label: const Text('Khám phá địa điểm'),
          ),
        ],
      ),
    );
  }
}

