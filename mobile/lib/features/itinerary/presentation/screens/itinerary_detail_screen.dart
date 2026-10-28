import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smarttravel_mobile/core/theme/app_theme.dart';
import 'package:smarttravel_mobile/features/itinerary/data/models/itinerary_model.dart';
import 'package:smarttravel_mobile/features/itinerary/data/repositories/itinerary_repository.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/providers/itinerary_provider.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/widgets/itinerary/budget_health_meter.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/widgets/itinerary/itinerary_bottom_bar.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/widgets/itinerary/itinerary_daily_summary_card.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/widgets/itinerary/itinerary_day_ribbon.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/widgets/itinerary/itinerary_map_view.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/widgets/itinerary/share_itinerary_dialog.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/widgets/itinerary/timeline_activity_card.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/widgets/itinerary/travel_leg_connector.dart';

class ItineraryDetailScreen extends ConsumerStatefulWidget {
  final int id;
  final ItineraryResponseModel? initialData;

  const ItineraryDetailScreen({
    super.key,
    required this.id,
    this.initialData,
  });

  @override
  ConsumerState<ItineraryDetailScreen> createState() => _ItineraryDetailScreenState();
}

class _ItineraryDetailScreenState extends ConsumerState<ItineraryDetailScreen> {
  int _selectedDayIndex = 0;
  int _activeViewIndex = 0;
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.bgCanvas,
        body: Center(
          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue)),
        ),
      );
    }

    if (_errorMessage != null || _itinerary == null) {
      return Scaffold(
        backgroundColor: AppTheme.bgCanvas,
        appBar: AppBar(title: const Text('Chi tiết lịch trình')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_errorMessage ?? 'Không tìm thấy lịch trình'),
              const SizedBox(height: 12),
              FilledButton(onPressed: _fetchItinerary, child: const Text('Thử lại')),
            ],
          ),
        ),
      );
    }

    final itinerary = _itinerary!;
    final days = itinerary.days;
    final activeDay = _selectedDayIndex < days.length ? days[_selectedDayIndex] : days.first;

    return Scaffold(
      backgroundColor: AppTheme.bgCanvas,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          itinerary.title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
        ),
        actions: [
          IconButton(
            tooltip: 'Lưu vào chuyến đi',
            icon: const Icon(Icons.bookmark_border, color: AppTheme.primaryBlue),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã lưu lịch trình vào chuyến đi của bạn'),
                  backgroundColor: AppTheme.statusSuccess,
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Chia sẻ lịch trình',
            icon: const Icon(Icons.share_outlined, color: AppTheme.textSecondary),
            onPressed: () {
              ShareItineraryDialog.show(context, itinerary.id, itinerary.title);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          ItineraryDayRibbon(
            days: days,
            selectedDayIndex: _selectedDayIndex,
            activeViewIndex: _activeViewIndex,
            onDaySelected: (idx) => setState(() => _selectedDayIndex = idx),
            onViewChanged: (idx) => setState(() => _activeViewIndex = idx),
          ),
          Expanded(
            child: _activeViewIndex == 0
                ? SingleChildScrollView(
                    key: const ValueKey('timeline_view'),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BudgetHealthMeter(
                          totalEstimatedCost: itinerary.totalEstimatedCost,
                          maxBudgetVnd: itinerary.maxBudgetVnd,
                          budgetUtilizationPercent: itinerary.budgetUtilizationPercent,
                          budgetHealth: itinerary.budgetHealth,
                          categoryBreakdown: itinerary.categoryBreakdown,
                        ),
                        const SizedBox(height: 16),
                        ItineraryDailySummaryCard(
                          day: activeDay,
                          totalDays: itinerary.totalDays,
                          maxBudgetVnd: itinerary.maxBudgetVnd,
                        ),
                        const SizedBox(height: 16),
                        ..._buildTimelineItems(activeDay.items),
                        const SizedBox(height: 20),
                      ],
                    ),
                  )
                : ItineraryMapView(
                    key: ValueKey('map_view_day_${activeDay.id}'),
                    items: activeDay.items,
                    onItemTap: (item) {
                      if (item.destination != null) {
                        context.push('/destinations/${item.destination!.id}');
                      }
                    },
                  ),
          ),
          ItineraryBottomBar(
            itinerary: itinerary,
            onItineraryUpdated: (updated) => setState(() => _itinerary = updated),
          ),
        ],
      ),
    );
  }
}
