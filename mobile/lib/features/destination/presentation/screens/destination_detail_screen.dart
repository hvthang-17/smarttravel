import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smarttravel_mobile/features/destination/data/models/destination_model.dart';
import 'package:smarttravel_mobile/features/destination/presentation/providers/destination_provider.dart';

class DestinationDetailScreen extends ConsumerStatefulWidget {
  final int id;

  const DestinationDetailScreen({super.key, required this.id});

  @override
  ConsumerState<DestinationDetailScreen> createState() => _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends ConsumerState<DestinationDetailScreen> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(destinationDetailProvider(widget.id));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
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
                  // Hero Header Image & Actions
                  SliverToBoxAdapter(
                    child: Stack(
                      children: [
                        Container(
                          height: 320,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF0077B6),
                                const Color(0xFF03045E),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              destination.category.contains('Biển')
                                  ? Icons.beach_access
                                  : destination.category.contains('Văn hóa')
                                      ? Icons.account_balance
                                      : destination.category.contains('Ẩm thực')
                                          ? Icons.restaurant
                                          : Icons.landscape,
                              size: 80,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ),

                        // Gradient bottom shadow on image
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 80,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.5),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),

                        // Floating Back Button
                        Positioned(
                          top: 48,
                          left: 20,
                          child: InkWell(
                            onTap: () => context.pop(),
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.arrow_back,
                                color: Color(0xFF0F172A),
                                size: 20,
                              ),
                            ),
                          ),
                        ),

                        // Floating Favorite Button
                        Positioned(
                          top: 48,
                          right: 20,
                          child: InkWell(
                            onTap: () {
                              setState(() => _isFavorite = !_isFavorite);
                            },
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Icon(
                                _isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: _isFavorite
                                    ? const Color(0xFFE76F51)
                                    : const Color(0xFF0F172A),
                                size: 20,
                              ),
                            ),
                          ),
                        ),

                        // Rating Tag
                        Positioned(
                          bottom: 16,
                          left: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.65),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.star, size: 14, color: Color(0xFFF59E0B)),
                                SizedBox(width: 4),
                                Text(
                                  '4.8 (320+ đánh giá)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Photo Count Tag
                        Positioned(
                          bottom: 16,
                          right: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.65),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.photo_camera_outlined, size: 14, color: Colors.white),
                                SizedBox(width: 4),
                                Text(
                                  '1/6 ảnh',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Detail Body
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Main Info Card
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE0F2FE),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        destination.category,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF0284C7),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8F9FA),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: const Color(0xFFE2E8F0)),
                                      ),
                                      child: const Icon(
                                        Icons.share_outlined,
                                        size: 18,
                                        color: Color(0xFF475569),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  destination.name,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time, size: 16, color: Color(0xFF0077B6)),
                                    const SizedBox(width: 4),
                                    const Text(
                                      '06:00 - 18:00',
                                      style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
                                    ),
                                    const SizedBox(width: 14),
                                    const Icon(Icons.confirmation_number_outlined, size: 16, color: Color(0xFF2A9D8F)),
                                    const SizedBox(width: 4),
                                    Text(
                                      (destination.priceMinVnd == null || destination.priceMinVnd == 0)
                                          ? 'Miễn phí'
                                          : '${destination.priceMinVnd}đ',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2A9D8F),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    const Icon(Icons.near_me_outlined, size: 16, color: Color(0xFFF77F00)),
                                    const SizedBox(width: 4),
                                    const Text(
                                      '8.5 km từ TT',
                                      style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Mô tả điểm đến
                          if (destination.description?.isNotEmpty == true) ...[
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Mô tả điểm đến',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    destination.description!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      height: 1.6,
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Thông tin tham quan
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Thông tin tham quan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                _buildInfoRow(
                                  Icons.location_on_outlined,
                                  'Địa chỉ',
                                  'Sơn Trà, TP. Đà Nẵng',
                                ),
                                const Divider(height: 20, color: Color(0xFFF1F5F9)),
                                _buildInfoRow(
                                  Icons.schedule,
                                  'Thời lượng gợi ý',
                                  'Khoảng 2 - 3 giờ',
                                ),
                                const Divider(height: 20, color: Color(0xFFF1F5F9)),
                                _buildInfoRow(
                                  Icons.directions_car_outlined,
                                  'Phương tiện',
                                  'Xe máy, Ô tô, Taxi / Grab',
                                ),
                                const Divider(height: 20, color: Color(0xFFF1F5F9)),
                                _buildInfoRow(
                                  Icons.explore_outlined,
                                  'Tọa độ GPS',
                                  '${destination.latitude}, ${destination.longitude}',
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: const Color(0xFFF0F9FF),
                                      side: const BorderSide(color: Color(0xFFBAE6FD)),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () {},
                                    icon: const Icon(
                                      Icons.map_outlined,
                                      size: 18,
                                      color: Color(0xFF0284C7),
                                    ),
                                    label: const Text(
                                      'Xem vị trí trên Google Maps',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF0284C7),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Mẹo du lịch banner
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7ED),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFFED7AA)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF97316),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.priority_high,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: TextStyle(fontSize: 13, color: Color(0xFF9A3412), height: 1.5),
                                      children: [
                                        TextSpan(
                                          text: 'Mẹo du lịch: ',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(
                                          text: 'Thời điểm lý tưởng nhất để tham quan là sáng sớm (6:00 - 8:00) hoặc chiều muộn để ngắm hoàng hôn và quan sát cảnh quan đẹp nhất.',
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Bottom Sticky Action Bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.star_outline, color: Color(0xFF0077B6)),
                          onPressed: () {},
                          tooltip: 'Tạo tour',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF0077B6),
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
          body: Center(child: CircularProgressIndicator()),
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF0077B6)),
        const SizedBox(width: 10),
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }
}
