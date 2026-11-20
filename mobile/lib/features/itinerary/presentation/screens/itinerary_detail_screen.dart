import 'package:smarttravel_mobile/core/localization/app_language.dart';
import 'package:flutter/material.dart';
import 'package:smarttravel_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/widgets/itinerary/itinerary_guest_view.dart';
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
  bool _saving = false;
  bool _offline = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (!ref.read(authNotifierProvider).isAuthenticated) return;
    if (widget.initialData != null) {
      _itinerary = widget.initialData;
    } else {
      _fetchItinerary();
    }
  }

  Future<void> _fetchItinerary() async {
    final token = ref.read(authNotifierProvider).token;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(itineraryRepositoryProvider);
      final data = await repo.getItineraryById(widget.id);
      if (mounted && ref.read(authNotifierProvider).token == token) {
        setState(() {
          _itinerary = data;
          _offline = repo.usedCachedTrip(widget.id);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted && ref.read(authNotifierProvider).token == token) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveDraft() async {
    final token = ref.read(authNotifierProvider).token;
    if (_saving || token == null || _itinerary?.status != 'DRAFT') return;
    setState(() => _saving = true);
    try {
      final updated = await ref.read(itineraryRepositoryProvider).saveDraft(widget.id, token);
      if (!mounted || ref.read(authNotifierProvider).token != token) return;
      setState(() => _itinerary = updated);
      ref.read(tripListsRevisionProvider.notifier).state++;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: AppText('Đã lưu lịch trình')));
    } catch (error) {
      if (mounted && ref.read(authNotifierProvider).token == token) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: AppText(error.toString().replaceFirst('Exception: ', ''))));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  List<Widget> _buildTimelineItems(List<ItineraryItemModel> items, String? origin) {
    final list = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      if (i > 0 || item.routeSource != 'UNKNOWN' || origin?.isNotEmpty == true) {
        list.add(
          TravelLegConnector(
            distanceKm: item.travelDistanceKm,
            durationMinutes: item.travelMinutes,
            routeSource: item.routeSource,
            fromOrigin: i == 0,
          ),
        );
      }
      list.add(
        TimelineActivityCard(
          item: item,
          onTap: () {
            if (item.destination?.id != null) {
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
    ref.listen(authNotifierProvider.select((user) => user.token), (_, token) {
      setState(() {
        _itinerary = null;
        _offline = false;
        _errorMessage = null;
        _isLoading = false;
        _selectedDayIndex = 0;
      });
      if (token != null) _fetchItinerary();
    });
    if (!ref.watch(authNotifierProvider).isAuthenticated) {
      return const Scaffold(body: ItineraryGuestView());
    }
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
        appBar: AppBar(title: const AppText('Chi tiết lịch trình')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText(_errorMessage ?? 'Không tìm thấy lịch trình'),
              const SizedBox(height: 12),
              FilledButton(onPressed: _fetchItinerary, child: const AppText('Thử lại')),
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
        title: AppText(
          itinerary.title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
        ),
        actions: [
          if (itinerary.status == 'SAVED') IconButton(
            tooltip: AppLanguage.text(context, 'Chia sẻ lịch trình'),
            icon: const Icon(Icons.share_outlined, color: AppTheme.textSecondary),
            onPressed: () {
              ShareItineraryDialog.show(context, itinerary.id, itinerary.title);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_offline)
            const ListTile(dense: true, leading: Icon(Icons.cloud_off),
              title: AppText('Đang xem bản tải gần nhất')),
          if (itinerary.status == 'DRAFT')
            const ListTile(dense: true, leading: Icon(Icons.edit_note),
              title: AppText('Bản nháp riêng tư'),
              subtitle: AppText('Lưu lịch trình để đưa vào danh sách chuyến đã lưu.')),
          ItineraryDayRibbon(
            days: days,
            selectedDayIndex: _selectedDayIndex,
            activeViewIndex: _activeViewIndex,
            onDaySelected: (idx) => setState(() => _selectedDayIndex = idx),
            onViewChanged: (idx) => setState(() => _activeViewIndex = idx),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: AppText('Chưa tính chặng quay về điểm xuất phát.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          ),
          Expanded(
            child: _activeViewIndex == 0
                ? SingleChildScrollView(
                    key: const ValueKey('timeline_view'),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (itinerary.originName?.isNotEmpty == true)
                          Padding(padding: const EdgeInsets.only(bottom: 12),
                            child: AppText('Điểm xuất phát · ${itinerary.originName}')),
                        for (final rule in itinerary.constraints)
                          AppText('${rule.type == 'REQUIRED' ? 'Bắt buộc' : 'Bỏ qua'} · ${rule.name ?? 'Địa điểm ${rule.destinationId}'}'),
                        for (final warning in itinerary.warnings)
                          Padding(padding: const EdgeInsets.only(bottom: 8), child: AppText(warning)),
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
                        ..._buildTimelineItems(activeDay.items, itinerary.originName),
                        const SizedBox(height: 20),
                      ],
                    ),
                  )
                : ItineraryMapView(
                    key: ValueKey('map_view_day_${activeDay.id}'),
                    items: activeDay.items,
                    transport: itinerary.transport,
                    onItemTap: (item) {
                      if (item.destination?.id != null) {
                        context.push('/destinations/${item.destination!.id}');
                      }
                    },
                  ),
          ),
          ItineraryBottomBar(
            itinerary: itinerary,
            onSave: _saveDraft,
            saving: _saving,
            onItineraryUpdated: (updated) => setState(() {
              _itinerary = updated;
              _offline = false;
            }),
          ),
        ],
      ),
    );
  }
}
