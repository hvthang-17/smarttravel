import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smarttravel_mobile/features/destination/presentation/providers/destination_provider.dart';

class DestinationDetailScreen extends ConsumerWidget {
  final int id;

  const DestinationDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(destinationDetailProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết địa điểm'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: detailAsync.when(
        data: (destination) {
          if (destination == null) {
            return const Center(
              child: Text('Không tìm thấy thông tin địa điểm.'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.teal.shade200),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.place,
                      size: 64,
                      color: Colors.teal.shade700,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        destination.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    Chip(
                      label: Text(destination.category),
                      backgroundColor: Colors.teal.shade100,
                      labelStyle: TextStyle(color: Colors.teal.shade900),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (destination.description != null &&
                    destination.description!.isNotEmpty) ...[
                  Text(
                    'Mô tả',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    destination.description!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                ],
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.attach_money, color: Colors.teal),
                            const SizedBox(width: 8),
                            Text(
                              'Chi phí ước tính: ',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text(
                              destination.priceMinVnd != null
                                  ? '${destination.priceMinVnd} - ${destination.priceMaxVnd ?? destination.priceMinVnd} VNĐ'
                                  : 'Miễn phí / Chưa cập nhật',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.teal),
                            const SizedBox(width: 8),
                            Text(
                              'Tọa độ: ',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text(
                              '${destination.latitude}, ${destination.longitude}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Không thể tải chi tiết: $err'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.refresh(destinationDetailProvider(id)),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
