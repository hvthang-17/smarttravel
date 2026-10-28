import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smarttravel_mobile/core/theme/app_theme.dart';
import 'package:smarttravel_mobile/features/destination/presentation/providers/destination_provider.dart';
import 'package:smarttravel_mobile/features/destination/presentation/widgets/destination_card_skeleton.dart';

class DestinationListScreen extends ConsumerWidget {
  const DestinationListScreen({super.key});

  final List<String> categories = const [
    'Tất cả',
    'Biển',
    'Văn hóa',
    'Ẩm thực',
    'Thiên nhiên',
    'Check-in',
  ];

  String _formatPrice(int amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}tr';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}k';
    }
    return '$amountđ';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final destinationsState = ref.watch(destinationListProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgCanvas,
      appBar: AppBar(
        title: const Text('Danh sách điểm đến'),
      ),
      body: Column(
        children: [
          // Category filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: categories.map((category) {
                final isSelected = selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(
                      category,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppTheme.primaryBlue : AppTheme.textPrimary,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        ref.read(selectedCategoryProvider.notifier).state = category;
                      }
                    },
                    selectedColor: AppTheme.primarySurface,
                    checkmarkColor: AppTheme.primaryBlue,
                    backgroundColor: AppTheme.surfaceCard,
                    side: BorderSide(
                      color: isSelected ? AppTheme.primaryBlue : AppTheme.borderSubtle,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1, color: AppTheme.borderSubtle),
          Expanded(
            child: destinationsState.when(
              data: (destinations) {
                final filtered = destinations.where((item) {
                  if (selectedCategory == 'Tất cả') return true;
                  return item.category.toLowerCase().contains(selectedCategory.toLowerCase());
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text(
                      'Chưa có địa điểm nào trong danh mục này.',
                      style: TextStyle(color: AppTheme.textMuted),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    final isFree = (item.priceMinVnd == null || item.priceMinVnd == 0);
                    final location = item.address?.trim().isNotEmpty == true
                        ? (item.address!.contains(',')
                            ? item.address!.split(',').first.trim()
                            : item.address!)
                        : 'Đà Nẵng';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: AppTheme.borderSubtle),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => context.push('/destinations/${item.id}'),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: item.imageUrl?.trim().isNotEmpty == true
                                      ? Image.network(
                                          item.imageUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => _buildFallbackThumbnail(item.category),
                                        )
                                      : _buildFallbackThumbnail(item.category),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${item.category} • $location • ★ ${item.rating > 0 ? item.rating.toStringAsFixed(1) : "Mới"}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isFree ? 'Miễn phí' : _formatPrice(item.priceMinVnd!),
                                style: TextStyle(
                                  color: isFree
                                      ? AppTheme.statusSuccess
                                      : AppTheme.secondaryCoral,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const DestinationListSkeleton(),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Lỗi tải dữ liệu: $err'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => ref.refresh(destinationListProvider),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackThumbnail(String category) {
    return Container(
      color: AppTheme.primarySurface,
      child: Icon(
        category.contains('Biển')
            ? Icons.beach_access
            : category.contains('Ẩm thực')
                ? Icons.restaurant
                : category.contains('Văn hóa')
                    ? Icons.account_balance
                    : Icons.landscape,
        color: AppTheme.primaryBlue,
        size: 28,
      ),
    );
  }
}
