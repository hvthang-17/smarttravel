import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smarttravel_mobile/features/destination/presentation/providers/destination_provider.dart';

class DestinationListScreen extends ConsumerWidget {
  const DestinationListScreen({super.key});

  final List<String> categories = const [
    'Tất cả',
    'Tham quan',
    'Ăn uống',
    'Lưu trú',
    'Giải trí',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final destinationsState = ref.watch(destinationListProvider);

    return Scaffold(
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
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        ref.read(selectedCategoryProvider.notifier).state =
                            category;
                      }
                    },
                    selectedColor: Colors.teal.shade100,
                    checkmarkColor: Colors.teal.shade900,
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: destinationsState.when(
              data: (destinations) {
                if (destinations.isEmpty) {
                  return const Center(
                    child: Text('Chưa có địa điểm nào trong danh mục này.'),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: destinations.length,
                  itemBuilder: (context, index) {
                    final item = destinations[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal.shade100,
                          child: Icon(Icons.place, color: Colors.teal.shade800),
                        ),
                        title: Text(
                          item.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('${item.category} • ${item.latitude}, ${item.longitude}'),
                        trailing: Text(
                          item.priceMinVnd != null && item.priceMinVnd! > 0
                              ? '${item.priceMinVnd} VNĐ'
                              : 'Miễn phí',
                          style: TextStyle(
                            color: Colors.teal.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onTap: () => context.push('/destinations/${item.id}'),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Lỗi tải dữ liệu: $err'),
                    const SizedBox(height: 12),
                    ElevatedButton(
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
}

