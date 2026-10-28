import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smarttravel_mobile/core/theme/app_theme.dart';
import 'package:smarttravel_mobile/features/destination/presentation/providers/destination_provider.dart';
import 'package:smarttravel_mobile/features/destination/presentation/widgets/detail/destination_detail_header.dart';
import 'package:smarttravel_mobile/features/destination/presentation/widgets/detail/destination_main_info_card.dart';
import 'package:smarttravel_mobile/features/destination/presentation/widgets/detail/destination_visit_info_card.dart';

class DestinationDetailScreen extends ConsumerStatefulWidget {
  final int id;

  const DestinationDetailScreen({super.key, required this.id});

  @override
  ConsumerState<DestinationDetailScreen> createState() => _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends ConsumerState<DestinationDetailScreen> {
  bool _isSavedToPlan = false;

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(destinationDetailProvider(widget.id));

    return Scaffold(
      backgroundColor: AppTheme.bgCanvas,
      body: detailAsync.when(
        data: (destination) {
          if (destination == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Chi tiết địa điểm')),
              body: const Center(
                child: Text('Không tìm thấy thông tin địa điểm.'),
              ),
            );
          }

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: DestinationDetailHeader(destination: destination),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DestinationMainInfoCard(destination: destination),
                          const SizedBox(height: 16),
                          if (destination.description?.isNotEmpty == true) ...[
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceCard,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Mô tả điểm đến',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    destination.description!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      height: 1.6,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          DestinationVisitInfoCard(destination: destination),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCard,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Semantics(
                        label: _isSavedToPlan ? 'Đã lưu điểm đến' : 'Lưu điểm đến',
                        button: true,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _isSavedToPlan
                                ? AppTheme.secondarySurface
                                : AppTheme.primarySurface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: Icon(
                              _isSavedToPlan ? Icons.bookmark : Icons.bookmark_border,
                              color: _isSavedToPlan
                                  ? AppTheme.secondaryCoral
                                  : AppTheme.primaryBlue,
                            ),
                            onPressed: () {
                              setState(() => _isSavedToPlan = !_isSavedToPlan);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    _isSavedToPlan
                                        ? 'Đã lưu điểm đến vào danh sách yêu thích'
                                        : 'Đã bỏ lưu điểm đến',
                                  ),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            tooltip: 'Lưu điểm đến',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            context.push('/trip-wizard');
                          },
                          icon: const Icon(Icons.add, size: 20),
                          label: const Text(
                            'Thêm vào lịch trình',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        error: (err, stack) => Scaffold(
          appBar: AppBar(title: const Text('Chi tiết địa điểm')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Không thể tải chi tiết: $err'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.refresh(destinationDetailProvider(widget.id)),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
