import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smarttravel_mobile/core/theme/app_theme.dart';
import 'package:smarttravel_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:smarttravel_mobile/features/itinerary/data/models/itinerary_model.dart';
import 'package:smarttravel_mobile/features/itinerary/data/repositories/itinerary_repository.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/widgets/itinerary/my_trip_card.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/widgets/itinerary/my_trips_empty_state.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/widgets/itinerary/my_trips_summer_tip.dart';

class MyTripsScreen extends ConsumerStatefulWidget {
  const MyTripsScreen({super.key});

  @override
  ConsumerState<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends ConsumerState<MyTripsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<ItineraryResponseModel> _trips = [];

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(itineraryRepositoryProvider);
      final list = await repo.getMyItineraries();
      if (mounted) {
        setState(() {
          _trips = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void _handleDeleteTrip(int tripId) {
    setState(() {
      _trips.removeWhere((t) => t.id == tripId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã xóa lịch trình thành công'),
        backgroundColor: AppTheme.statusSuccess,
      ),
    );
  }

  void _showNotificationsSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.notifications_active_outlined, color: AppTheme.primaryBlue),
                SizedBox(width: 8),
                Text('Thông báo chuyến đi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE0F2FE),
                child: Icon(Icons.flight_takeoff, color: AppTheme.primaryBlue, size: 20),
              ),
              title: const Text('Chuẩn bị cho chuyến đi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: Text(
                _trips.isNotEmpty ? 'Lịch trình "${_trips.first.title}" sắp bắt đầu!' : 'Tạo lịch trình đầu tiên để nhận nhắc nhở tự động.',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(authNotifierProvider);
    final userName = userState.fullName?.isNotEmpty == true ? userState.fullName! : 'Minh';

    return Scaffold(
      backgroundColor: AppTheme.bgCanvas,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Lịch Trình',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
        ),
        actions: [
          IconButton(
            tooltip: 'Thông báo chuyến đi',
            icon: const Icon(Icons.notifications_none_outlined, color: AppTheme.textPrimary),
            onPressed: _showNotificationsSheet,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Semantics(
              label: 'Hồ sơ người dùng',
              button: true,
              child: InkWell(
                onTap: () => context.push('/profile'),
                borderRadius: BorderRadius.circular(16),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.primaryBlue,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'M',
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue)),
            )
          : _errorMessage != null
              ? _buildErrorView()
              : RefreshIndicator(
                  onRefresh: _loadTrips,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Lịch trình của tôi',
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${_trips.length} chuyến đi đã lưu',
                                style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                              ),
                            ],
                          ),
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppTheme.primaryBlue,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            onPressed: () => context.push('/trip-wizard'),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Tạo mới', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      if (_trips.isEmpty)
                        const MyTripsEmptyState()
                      else
                        ..._trips.asMap().entries.map((entry) {
                          return MyTripCard(
                            trip: entry.value,
                            index: entry.key,
                            onDelete: _handleDeleteTrip,
                          );
                        }),
                      const SizedBox(height: 12),
                      const MyTripsSummerTip(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_errorMessage!),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _loadTrips,
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}
