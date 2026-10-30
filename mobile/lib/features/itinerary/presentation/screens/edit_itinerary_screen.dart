import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarttravel_mobile/core/theme/app_theme.dart';
import 'package:smarttravel_mobile/features/destination/presentation/providers/destination_provider.dart';
import 'package:smarttravel_mobile/features/itinerary/data/models/itinerary_model.dart';
import 'package:smarttravel_mobile/features/itinerary/data/repositories/itinerary_repository.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/widgets/itinerary/add_destination_bottom_sheet.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/widgets/itinerary/edit_itinerary_activity_list.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/widgets/itinerary/edit_itinerary_day_selector.dart';

class EditItineraryScreen extends ConsumerStatefulWidget {
  final int id;
  final ItineraryResponseModel? initialData;

  const EditItineraryScreen({
    super.key,
    required this.id,
    this.initialData,
  });

  @override
  ConsumerState<EditItineraryScreen> createState() => _EditItineraryScreenState();
}

class _EditItineraryScreenState extends ConsumerState<EditItineraryScreen> {
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  ItineraryResponseModel? _itinerary;
  int _selectedDayIndex = 0;
  List<List<ItineraryItemModel>> _dayItems = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _itinerary = widget.initialData;
      _dayItems = widget.initialData!.days.map((d) => List<ItineraryItemModel>.from(d.items)).toList();
      _isLoading = false;
    } else {
      _loadItinerary();
    }
  }

  Future<void> _loadItinerary() async {
    try {
      final repo = ref.read(itineraryRepositoryProvider);
      final data = await repo.getItineraryById(widget.id);
      if (mounted) {
        setState(() {
          if (data != null) {
            _itinerary = data;
            _dayItems = data.days.map((d) => List<ItineraryItemModel>.from(d.items)).toList();
          } else {
            _errorMessage = 'Không tìm thấy thông tin lịch trình';
          }
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

  int _calculateDayCost(int idx) =>
      idx < _dayItems.length ? _dayItems[idx].fold(0, (sum, it) => sum + (it.estimatedCostVnd ?? 0)) : 0;

  void _reindexCurrentDay() {
    for (int i = 0; i < _dayItems[_selectedDayIndex].length; i++) {
      final it = _dayItems[_selectedDayIndex][i];
      _dayItems[_selectedDayIndex][i] = ItineraryItemModel(
        id: it.id,
        sequenceOrder: i + 1,
        startTime: it.startTime,
        durationMinutes: it.durationMinutes,
        estimatedCostVnd: it.estimatedCostVnd,
        notes: it.notes,
        destination: it.destination,
      );
    }
  }

  void _moveItem(int oldIndex, int newIndex) {
    if (newIndex < 0 || newIndex >= _dayItems[_selectedDayIndex].length) return;
    setState(() {
      final item = _dayItems[_selectedDayIndex].removeAt(oldIndex);
      _dayItems[_selectedDayIndex].insert(newIndex, item);
      _reindexCurrentDay();
    });
  }

  void _removeItem(int index) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa hoạt động'),
        content: const Text('Bạn có chắc chắn muốn xóa điểm đến này khỏi ngày?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Hủy', style: TextStyle(color: AppTheme.textMuted))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.statusError),
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _dayItems[_selectedDayIndex].removeAt(index);
                _reindexCurrentDay();
              });
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showAddDestinationSheet() async {
    final destRepo = ref.read(destinationRepositoryProvider);
    final allDestinations = await destRepo.getDestinations();
    if (!mounted) return;

    AddDestinationBottomSheet.show(
      context: context,
      dayNumber: _selectedDayIndex + 1,
      destinations: allDestinations,
      onSelectDestination: (dest) {
        setState(() {
          final currentList = _dayItems[_selectedDayIndex];
          final travelers = _itinerary?.travelersCount ?? 1;
          currentList.add(
            ItineraryItemModel(
              id: 0,
              sequenceOrder: currentList.length + 1,
              startTime: '14:00',
              durationMinutes: 90,
              estimatedCostVnd: (dest.priceMinVnd ?? 0) * travelers,
              notes: 'Khám phá ${dest.name}',
              destination: dest,
            ),
          );
        });
      },
    );
  }

  Future<void> _saveChanges() async {
    if (_itinerary == null) return;
    setState(() => _isSaving = true);

    try {
      final daysPayload = <DayUpdateModel>[];
      for (int i = 0; i < _itinerary!.days.length; i++) {
        final originalDay = _itinerary!.days[i];
        final items = _dayItems[i];
        final itemUpdates = items.map((it) => ItemUpdateModel(
          id: it.id > 0 ? it.id : null,
          destinationId: it.destination?.id ?? 1,
          sequenceOrder: it.sequenceOrder,
          startTime: it.startTime ?? '09:00',
          durationMinutes: it.durationMinutes ?? 90,
          estimatedCostVnd: it.estimatedCostVnd ?? 0,
          notes: it.notes,
        )).toList();

        daysPayload.add(DayUpdateModel(dayId: originalDay.id, dayNumber: originalDay.dayNumber, items: itemUpdates));
      }

      final repo = ref.read(itineraryRepositoryProvider);
      final updated = await repo.updateActivities(widget.id, UpdateActivitiesRequestModel(days: daysPayload));

      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật lịch trình thành công!'), backgroundColor: AppTheme.statusSuccess),
        );
        Navigator.of(context).pop(updated);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: AppTheme.statusError),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.bgCanvas,
        body: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue))),
      );
    }

    if (_errorMessage != null || _itinerary == null) {
      return Scaffold(
        backgroundColor: AppTheme.bgCanvas,
        appBar: AppBar(title: const Text('Chỉnh sửa lịch trình')),
        body: Center(child: Text(_errorMessage ?? 'Lỗi tải dữ liệu')),
      );
    }

    final days = _itinerary!.days;
    final currentItems = _dayItems[_selectedDayIndex];
    final dayCost = _calculateDayCost(_selectedDayIndex);

    return Scaffold(
      backgroundColor: AppTheme.bgCanvas,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Đóng',
          icon: const Icon(Icons.close, color: AppTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          children: [
            const Text(
              'Chỉnh sửa Lịch trình',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            Text(
              '${_itinerary!.title} • ${_itinerary!.startDate} - ${_itinerary!.endDate}',
              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: _isSaving ? null : _saveChanges,
              icon: _isSaving
                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.check, size: 16),
              label: const Text('Hoàn tất', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          EditItineraryDaySelector(
            days: days,
            selectedDayIndex: _selectedDayIndex,
            onSelectDay: (idx) => setState(() => _selectedDayIndex = idx),
          ),
          Expanded(
            child: EditItineraryActivityList(
              selectedDayIndex: _selectedDayIndex,
              currentItems: currentItems,
              dayCost: dayCost,
              onMoveItem: _moveItem,
              onRemoveItem: _removeItem,
              onAddDestination: _showAddDestinationSheet,
            ),
          ),
        ],
      ),
    );
  }
}
