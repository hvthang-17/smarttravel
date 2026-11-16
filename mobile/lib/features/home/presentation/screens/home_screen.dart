import 'package:smarttravel_mobile/core/localization/app_language.dart';
import 'dart:async';
import 'package:smarttravel_mobile/features/destination/data/models/discovery_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smarttravel_mobile/core/theme/app_theme.dart';
import 'package:smarttravel_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:smarttravel_mobile/features/destination/presentation/providers/destination_provider.dart';
import 'package:smarttravel_mobile/features/destination/presentation/widgets/destination_card_skeleton.dart';
import 'package:smarttravel_mobile/features/home/presentation/widgets/destination_card.dart';
import 'package:smarttravel_mobile/features/home/presentation/widgets/home_cta_banner.dart';
import 'package:smarttravel_mobile/features/home/presentation/widgets/home_top_bar.dart';
import 'package:smarttravel_mobile/features/weather/presentation/widgets/weather_pill.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _selectedCategory;
  String _search = '';
  Timer? _debounce;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _openDiscovery() {
    context.push(Uri(path: '/destinations', queryParameters: {
      if (_searchController.text.trim().isNotEmpty) 'search': _searchController.text.trim(),
      if (_selectedCategory != null) 'category': _selectedCategory!,
    }).toString());
  }

  @override
  Widget build(BuildContext context) {
    final DiscoveryQuery query = (search: _search, category: _selectedCategory, minPrice: null, maxPrice: null, page: 0);
    final destinationAsync = ref.watch(discoveryProvider(query));
    final catalog = ref.watch(destinationCatalogProvider);
    final userState = ref.watch(authNotifierProvider);
    final userName = userState.fullName?.isNotEmpty == true ? userState.fullName! : 'Bạn';
    final language = userState.travelerProfile?.language ?? 'vi';

    return Scaffold(
      backgroundColor: AppTheme.bgCanvas,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(discoveryProvider(query).future),
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
                          const AppText('Xin chào!', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
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
                            maxLength: 180,
                            onChanged: (value) {
                              _debounce?.cancel();
                              _debounce = Timer(const Duration(milliseconds: 350), () {
                                if (mounted) setState(() => _search = value.trim());
                              });
                            },
                            onSubmitted: (_) => _openDiscovery(),
                            decoration: const InputDecoration(
                              hint: AppText('Tìm địa điểm tại Đà Nẵng...'),
                              hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                              prefixIcon: Icon(Icons.search, color: AppTheme.textMuted, size: 20),
                              border: InputBorder.none,
                              counterText: '',
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
                            tooltip: AppLanguage.text(context, 'Mở bộ lọc địa điểm'),
                            onPressed: _openDiscovery,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Category Pills with real Material vector icons
              SliverToBoxAdapter(
                child: catalog.when(
                  loading: () => const SizedBox(height: 44),
                  error: (_, __) => TextButton(onPressed: () => ref.invalidate(destinationCatalogProvider),
                    child: const AppText('Thử tải lại danh mục')),
                  data: (categories) => SizedBox(
                    height: 48,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        ChoiceChip(label: const AppText('Tất cả'), selected: _selectedCategory == null,
                          onSelected: (_) => setState(() => _selectedCategory = null)),
                        for (final category in categories) Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: ChoiceChip(label: AppText(category.label(language)), selected: _selectedCategory == category.code,
                            onSelected: (_) => setState(() => _selectedCategory = category.code)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Section Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(child: AppText('Điểm đến', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary))),
                      InkWell(
                        onTap: _openDiscovery,
                        child: const Row(
                          children: [
                            AppText('Xem tất cả', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primaryBlue)),
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
                error: (_, __) => SliverToBoxAdapter(
                  child: Center(child: TextButton(onPressed: () => ref.invalidate(discoveryProvider(query)),
                    child: const AppText('Không tải được địa điểm. Thử lại'))),
                ),
                data: (page) {
                  final filtered = page.items.take(8).toList();
                  if (filtered.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(child: AppText('Không tìm thấy địa điểm phù hợp', style: TextStyle(color: AppTheme.textMuted))),
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
                            language: language,
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
