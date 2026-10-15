import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smarttravel_mobile/features/destination/data/models/itinerary_model.dart';
import 'package:smarttravel_mobile/features/destination/data/repositories/itinerary_repository.dart';
import 'package:smarttravel_mobile/features/destination/presentation/providers/itinerary_provider.dart';
import 'package:smarttravel_mobile/features/destination/presentation/widgets/itinerary/budget_health_meter.dart';
import 'package:smarttravel_mobile/features/destination/presentation/widgets/itinerary/itinerary_map_view.dart';
import 'package:smarttravel_mobile/features/destination/presentation/widgets/itinerary/share_itinerary_dialog.dart';
import 'package:smarttravel_mobile/features/destination/presentation/widgets/itinerary/timeline_activity_card.dart';
import 'package:smarttravel_mobile/features/destination/presentation/widgets/itinerary/travel_leg_connector.dart';

class ItineraryDetailScreen extends ConsumerStatefulWidget {
  final int id;
  final ItineraryResponseModel? initialData;

  const ItineraryDetailScreen({
    super.key,
    required this.id,
    this.initialData,
  });

  @override
  ConsumerState<ItineraryDetailScreen> createState() =>
      _ItineraryDetailScreenState();
}

class _ItineraryDetailScreenState extends ConsumerState<ItineraryDetailScreen> {
  int _selectedDayIndex = 0;
  int _activeViewIndex = 0; // 0 = Lịch trình (Timeline), 1 = Bản đồ (Map)
  ItineraryResponseModel? _itinerary;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _itinerary = widget.initialData;
    } else {
      _fetchItinerary();
    }
  }

  Future<void> _fetchItinerary() async {
    // Check if notifier already has generated itinerary with same ID
    final currentGen = ref.read(itineraryNotifierProvider).generatedItinerary;
    if (currentGen != null && currentGen.id == widget.id) {
      setState(() => _itinerary = currentGen);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(itineraryRepositoryProvider);
      final data = await repo.getItineraryById(widget.id);
      if (mounted) {
        setState(() {
          _itinerary = data;
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

  String _formatVnd(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }
    return buffer.toString().split('').reversed.join('');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0077B6)),
          ),
        ),
      );
    }

    if (_errorMessage != null || _itinerary == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(title: const Text('Chi tiết lịch trình')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_errorMessage ?? 'Không tìm thấy lịch trình'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _fetchItinerary,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    final itinerary = _itinerary!;
    final days = itinerary.days;
    final activeDay = _selectedDayIndex < days.length ? days[_selectedDayIndex] : days.first;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          itinerary.title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border, color: Color(0xFF0077B6)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã lưu lịch trình vào chuyến đi của bạn'),
                  backgroundColor: Color(0xFF2A9D8F),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Color(0xFF475569)),
            onPressed: () {
              ShareItineraryDialog.show(context, itinerary.id, itinerary.title);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Sticky Top Section: Day Chips & Dual-View Switcher
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(top: 10, bottom: 12),
            child: Column(
              children: [
                _buildDaySelectorRibbon(days),
                const SizedBox(height: 10),
                _buildDualViewSwitcher(),
              ],
            ),
          ),

          // Main View (Timeline vs Map)
          Expanded(
            child: IndexedStack(
              index: _activeViewIndex,
              children: [
                // View 0: Timeline Plan View
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Budget Health Meter (Task 4.3)
                      BudgetHealthMeter(
                        totalEstimatedCost: itinerary.totalEstimatedCost,
                        maxBudgetVnd: itinerary.maxBudgetVnd,
                        budgetUtilizationPercent:
                            itinerary.budgetUtilizationPercent,
                        budgetHealth: itinerary.budgetHealth,
                        categoryBreakdown: itinerary.categoryBreakdown,
                      ),
                      const SizedBox(height: 16),

                      // Daily Summary Card
                      _buildDailySummaryCard(activeDay),
                      const SizedBox(height: 16),

                      // Timeline Activity Cards with Travel Leg Connectors
                      ..._buildTimelineItems(activeDay.items),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                // View 1: Map View (Task 4.2)
                ItineraryMapView(
                  items: activeDay.items,
                  onItemTap: (item) {
                    if (item.destination != null) {
                      context.push('/destinations/${item.destination!.id}');
                    }
                  },
                ),
              ],
            ),
          ),

          // Sticky Bottom Bar
          _buildBottomActionButtons(),
        ],
      ),
    );
  }

  Widget _buildDaySelectorRibbon(List<ItineraryDayModel> days) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(days.length, (index) {
          final isSelected = index == _selectedDayIndex;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => setState(() => _selectedDayIndex = index),
              borderRadius: BorderRadius.circular(999),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF0077B6) : Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF0077B6)
                        : const Color(0xFFE2E8F0),
                  ),
                  boxShadow: isSelected
                      ? const [
                          BoxShadow(
                            color: Color(0x260077B6),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  'Ngày ${index + 1}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDualViewSwitcher() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 38,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildSwitcherTab(
                index: 0,
                icon: Icons.format_list_bulleted,
                label: 'Lịch trình',
              ),
            ),
            Expanded(
              child: _buildSwitcherTab(
                index: 1,
                icon: Icons.map_outlined,
                label: 'Bản đồ',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitcherTab({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isActive = _activeViewIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _activeViewIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: isActive
              ? const [
                  BoxShadow(
                    color: Color(0x0F0F172A),
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? const Color(0xFF0077B6) : const Color(0xFF475569),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color:
                    isActive ? const Color(0xFF0077B6) : const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailySummaryCard(ItineraryDayModel day) {
    final itinerary = _itinerary!;
    final totalDays = itinerary.totalDays > 0 ? itinerary.totalDays : 1;
    final dailyBudgetLimit = itinerary.maxBudgetVnd ~/ totalDays;
    final percent = dailyBudgetLimit > 0
        ? (day.dayCostVnd * 100 / dailyBudgetLimit).clamp(0, 150).toDouble()
        : 0.0;
    final isOver = percent > 100;
    final isWarning = percent >= 85 && !isOver;
    final healthColor = isOver
        ? const Color(0xFFE76F51)
        : isWarning
            ? const Color(0xFFE9C46A)
            : const Color(0xFF2A9D8F);

    final hours = day.totalDurationMinutes ~/ 60;
    final mins = day.totalDurationMinutes % 60;
    final timeFormatted = hours > 0 ? '${hours}h ${mins}p' : '${mins}p';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.credit_card_outlined, size: 14, color: Color(0xFF0077B6)),
                        const SizedBox(width: 4),
                        const Text(
                          'Chi phí',
                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDF2F7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'ƯỚC TÍNH',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatVnd(day.dayCostVnd)} VNĐ',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 36, color: const Color(0xFFF1F5F9)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.navigation_outlined, size: 14, color: Color(0xFF0077B6)),
                          SizedBox(width: 4),
                          Text(
                            'Quãng đường',
                            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${day.totalDistanceKm.toStringAsFixed(1)} km',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(width: 1, height: 36, color: const Color(0xFFF1F5F9)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.schedule, size: 14, color: Color(0xFF0077B6)),
                          SizedBox(width: 4),
                          Text(
                            'Thời gian',
                            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timeFormatted,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(color: healthColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isOver
                        ? 'Vượt hạn mức ngân sách ngày'
                        : isWarning
                            ? 'Gần chạm hạn mức ngân sách'
                            : 'Trong hạn mức ngân sách ngày',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
                  ),
                ],
              ),
              Text(
                '${percent.toStringAsFixed(0)}% (${(day.dayCostVnd / 1000).toStringAsFixed(0)}k / ${(dailyBudgetLimit / 1000).toStringAsFixed(0)}k)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: healthColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (percent / 100.0).clamp(0.0, 1.0),
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(healthColor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTimelineItems(List<ItineraryItemModel> items) {
    final list = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      if (i > 0) {
        list.add(
          TravelLegConnector(
            distanceKm: item.travelDistanceKm,
            durationMinutes: item.travelMinutes,
          ),
        );
      }
      list.add(
        TimelineActivityCard(
          item: item,
          onTap: () {
            if (item.destination != null) {
              context.push('/destinations/${item.destination!.id}');
            }
          },
        ),
      );
    }
    return list;
  }

  Widget _buildBottomActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF0077B6)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () async {
                if (_itinerary == null) return;
                final updated = await context.push<ItineraryResponseModel?>(
                  '/itineraries/${_itinerary!.id}/edit',
                  extra: _itinerary,
                );
                if (updated != null && mounted) {
                  setState(() => _itinerary = updated);
                }
              },
              child: const Text(
                'Chỉnh sửa lịch trình',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0077B6),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0077B6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lịch trình đã sẵn sàng cho chuyến đi của bạn!'),
                    backgroundColor: Color(0xFF2A9D8F),
                  ),
                );
              },
              child: const Text(
                'Lưu lịch trình',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
