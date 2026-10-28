import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smarttravel_mobile/core/theme/app_theme.dart';
import 'package:smarttravel_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:smarttravel_mobile/features/destination/presentation/providers/destination_provider.dart';
import 'package:smarttravel_mobile/features/destination/presentation/widgets/destination_card_skeleton.dart';
import 'package:smarttravel_mobile/features/home/presentation/widgets/destination_card.dart';
import 'package:smarttravel_mobile/features/home/presentation/widgets/home_category_pills.dart';
import 'package:smarttravel_mobile/features/home/presentation/widgets/home_cta_banner.dart';
import 'package:smarttravel_mobile/features/home/presentation/widgets/home_filter_bottom_sheet.dart';
import 'package:smarttravel_mobile/features/home/presentation/widgets/home_top_bar.dart';
import 'package:smarttravel_mobile/features/weather/presentation/widgets/weather_pill.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedCategory = 'Tất cả';
  final TextEditingController _searchController = TextEditingController();
  final Set<int> _favorites = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleFavorite(int id) {
    setState(() {
      if (_favorites.contains(id)) {
        _favorites.remove(id);
      } else {
        _favorites.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final destinationAsync = ref.watch(destinationListProvider);
    final userState = ref.watch(authNotifierProvider);
    final userName = userState.fullName?.isNotEmpty == true ? userState.fullName! : 'Minh';

    return Scaffold(
      backgroundColor: AppTheme.bgCanvas,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(destinationListProvider),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: HomeTopBar(userName: userName, isAuthenticated: userState.isAuthenticated),
              ),

              // Greeting & Weather Pill (with real vector icons, no waving hand emoji)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Xin chào!', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 2),
                          Text(userName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                        ],
                      ),
                      const WeatherPill(),
                    ],
                  ),
                ),
              ),

              // Search & Filter Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(color: AppTheme.surfaceCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.borderSubtle)),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            decoration: const InputDecoration(
                              hintText: 'Tìm địa điểm tại Đà Nẵng...',
                              hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                              prefixIcon: Icon(Icons.search, color: AppTheme.textMuted, size: 20),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Semantics(
                        label: 'Mở bộ lọc danh mục',
                        button: true,
                        child: Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(color: AppTheme.primaryBlue, borderRadius: BorderRadius.circular(14)),
                          child: IconButton(
                            icon: const Icon(Icons.tune, color: Colors.white, size: 20),
                            tooltip: 'Lọc danh mục',
                            onPressed: () => HomeFilterBottomSheet.show(
                              context,
                              selectedCategory: _selectedCategory,
                              onSelectCategory: (cat) => setState(() => _selectedCategory = cat),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Category Pills with real Material vector icons
              SliverToBoxAdapter(
                child: HomeCategoryPills(
                  selectedCategory: _selectedCategory,
                  onSelectCategory: (cat) => setState(() => _selectedCategory = cat),
                ),
              ),

              // Section Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text('Điểm đến nổi bật', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: AppTheme.primarySurface, borderRadius: BorderRadius.circular(12)),
                            child: destinationAsync.maybeWhen(
                              data: (list) => Text('${list.length}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                              orElse: () => const Text('0', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () => context.push('/destinations'),
                        child: const Row(
                          children: [
                            Text('Xem tất cả', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primaryBlue)),
                            SizedBox(width: 2),
                            Icon(Icons.chevron_right, size: 16, color: AppTheme.primaryBlue),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Destination 2-Column Grid
              destinationAsync.when(
                loading: () => SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.68,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => const DestinationCardSkeleton(),
                      childCount: 4,
                    ),
                  ),
                ),
                error: (err, _) => SliverToBoxAdapter(
                  child: Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Lỗi tải dữ liệu: $err'))),
                ),
                data: (allDests) {
                  final query = _searchController.text.trim().toLowerCase();
                  var filtered = allDests.where((d) {
                    final matchesSearch = query.isEmpty || d.name.toLowerCase().contains(query) || d.category.toLowerCase().contains(query);
                    final matchesCategory = _selectedCategory == 'Tất cả' || d.category.toLowerCase().contains(_selectedCategory.toLowerCase());
                    return matchesSearch && matchesCategory;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(child: Text('Không tìm thấy địa điểm phù hợp', style: TextStyle(color: AppTheme.textMuted))),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.68,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final dest = filtered[index];
                          return DestinationCard(
                            destination: dest,
                            isFavorite: _favorites.contains(dest.id),
                            onToggleFavorite: () => _toggleFavorite(dest.id),
                          );
                        },
                        childCount: filtered.length,
                      ),
                    ),
                  );
                },
              ),

              const SliverToBoxAdapter(child: HomeCtaBanner()),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ),
      ),
    );
  }
}
