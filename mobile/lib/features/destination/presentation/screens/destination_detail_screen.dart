import 'package:smarttravel_mobile/core/localization/app_language.dart';
import 'package:smarttravel_mobile/features/auth/presentation/providers/auth_provider.dart';
import '../providers/favorite_provider.dart';
import '../widgets/favorite_button.dart';
import '../widgets/destination_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smarttravel_mobile/core/theme/app_theme.dart';
import 'package:smarttravel_mobile/features/destination/presentation/providers/destination_provider.dart';
import 'package:smarttravel_mobile/features/destination/presentation/widgets/detail/destination_detail_header.dart';
import 'package:smarttravel_mobile/features/destination/presentation/widgets/detail/destination_main_info_card.dart';
import 'package:smarttravel_mobile/features/destination/presentation/widgets/detail/destination_visit_info_card.dart';
import '../widgets/detail/destination_reviews_section.dart';

class DestinationDetailScreen extends ConsumerWidget {
  final int id;

  const DestinationDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(authNotifierProvider.select((user) => user.travelerProfile?.language)) ?? 'vi';
    final saved = ref.watch(favoritesProvider).valueOrNull?.any((item) => item.id == id) ?? false;
    final detailAsync = ref.watch(destinationDetailProvider(id));

    return Scaffold(
      backgroundColor: AppTheme.bgCanvas,
      body: detailAsync.when(
        data: (destination) {
          if (destination == null) {
            return Scaffold(
              appBar: AppBar(title: const AppText('Chi tiết địa điểm')),
              body: const Center(
                child: AppText('Không tìm thấy thông tin địa điểm.'),
              ),
            );
          }

          final description = localizedText(destination.description ?? '', destination.descriptionEn, language);
          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: DestinationDetailHeader(destination: destination),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 16, 20, 112 + MediaQuery.paddingOf(context).bottom),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DestinationMainInfoCard(destination: destination, language: language),
                          const SizedBox(height: 16),
                          if (description.trim().isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceCard,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const AppText(
                                    'Mô tả điểm đến',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  AppText(
                                    description,
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
                          const SizedBox(height: 16),
                          DestinationReviewsSection(key: ValueKey(id), destinationId: id),
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
                  padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.paddingOf(context).bottom),
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
                      FavoriteButton(id: id),
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
                            context.push(saved ? '/trip-wizard?favorite=$id' : '/trip-wizard');
                          },
                          icon: const Icon(Icons.add, size: 20),
                          label: AppText(
                            saved ? 'Lập chuyến với điểm này' : 'Lập chuyến đi',
                            style: const TextStyle(
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
          appBar: AppBar(title: const AppText('Chi tiết địa điểm')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppText('Không thể tải chi tiết địa điểm.'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.invalidate(destinationDetailProvider(id)),
                  child: const AppText('Thử lại'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
