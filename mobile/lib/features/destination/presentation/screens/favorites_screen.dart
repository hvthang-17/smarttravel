import 'package:smarttravel_mobile/core/localization/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smarttravel_mobile/features/auth/presentation/providers/auth_provider.dart';
import '../providers/favorite_provider.dart';
import '../widgets/destination_result_tile.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(favoritesProvider.notifier).reload();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider);
    final favorites = ref.watch(favoritesProvider);
    final language = user.travelerProfile?.language ?? 'vi';
    return Scaffold(
      appBar: AppBar(title: const AppText('Địa điểm đã lưu')),
      body: !user.isAuthenticated
          ? Center(
              child: FilledButton(
                  onPressed: () => context.push('/login'),
                  child: const AppText('Đăng nhập để xem địa điểm đã lưu')))
          : favorites.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => Center(
                  child: TextButton(
                onPressed: () => ref.read(favoritesProvider.notifier).reload(),
                child: const AppText('Không tải được địa điểm đã lưu. Thử lại'),
              )),
              data: (items) => RefreshIndicator(
                onRefresh: () => ref.read(favoritesProvider.notifier).reload(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (items.isEmpty)
                      const AppText('Bạn chưa có địa điểm đã lưu đang hiển thị.'),
                    for (final item in items)
                      DestinationResultTile(
                          destination: item, language: language),
                  ],
                ),
              ),
            ),
    );
  }
}
