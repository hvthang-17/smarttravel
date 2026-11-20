import 'package:smarttravel_mobile/core/localization/app_language.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/widgets/itinerary/itinerary_conflict_dialog.dart';
import 'package:flutter/material.dart';
import 'package:smarttravel_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/widgets/itinerary/itinerary_guest_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarttravel_mobile/core/theme/app_theme.dart';
import 'package:smarttravel_mobile/features/destination/presentation/providers/destination_provider.dart';
import 'package:smarttravel_mobile/features/itinerary/data/models/itinerary_model.dart';
import 'package:smarttravel_mobile/features/itinerary/data/repositories/itinerary_repository.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/widgets/itinerary/add_destination_bottom_sheet.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/widgets/itinerary/edit_itinerary_activity_list.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/widgets/itinerary/edit_itinerary_day_selector.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/widgets/itinerary/edit_activity_dialog.dart';
import '../providers/itinerary_provider.dart';

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
  bool _loadingCatalog = false;
  final _dirtyDays = <int>{};
  String? _errorMessage;
  ItineraryResponseModel? _itinerary;
  int _selectedDayIndex = 0;
  List<List<ItineraryItemModel>> _dayItems = [];

  @override
  void initState() {
    super.initState();
    if (!ref.read(authNotifierProvider).isAuthenticated) return;
    if (widget.initialData != null) {
      _itinerary = widget.initialData;
      _dayItems = widget.initialData!.days.map((d) => List<ItineraryItemModel>.from(d.items)).toList();
      _isLoading = false;
    } else {
      _loadItinerary();
    }
  }

  Future<void> _requestClose() async {
    if (_isSaving || _loadingCatalog) return;
    if (_dirtyDays.isEmpty) { Navigator.of(context).pop(); return; }
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const AppText('Có thay đổi chưa lưu'),
        content: const AppText('Rời màn hình sẽ bỏ các thay đổi chưa lưu. Bạn muốn tiếp tục chỉnh sửa hay bỏ thay đổi?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const AppText('Tiếp tục chỉnh sửa')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const AppText('Bỏ thay đổi')),
        ],
      ),
    );
    if (discard == true && mounted) {
      setState(_dirtyDays.clear);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  Future<void> _loadItinerary() async {
    final token = ref.read(authNotifierProvider).token;
    try {
      final repo = ref.read(itineraryRepositoryProvider);
      final data = await repo.getItineraryById(widget.id);
      if (mounted && ref.read(authNotifierProvider).token == token) {
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
      if (mounted && ref.read(authNotifierProvider).token == token) {
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
      _dayItems[_selectedDayIndex][i] = it.edited(
        sequence: i + 1, time: it.startTime, duration: it.durationMinutes, note: it.notes,
      );
    }
    _dirtyDays.add(_selectedDayIndex);
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
    final token = ref.read(authNotifierProvider).token;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const AppText('Xóa hoạt động'),
        content: const AppText('Bạn có chắc chắn muốn xóa điểm đến này khỏi ngày?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const AppText('Hủy', style: TextStyle(color: AppTheme.textMuted))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.statusError),
            onPressed: () {
              Navigator.of(ctx).pop();
              if (!mounted || ref.read(authNotifierProvider).token != token) return;
              setState(() {
                _dayItems[_selectedDayIndex].removeAt(index);
                _reindexCurrentDay();
              });
            },
            child: const AppText('Xóa'),
          ),
        ],
      ),
    );
  }

  Future<void> _editItem(int index) async {
    final day = _selectedDayIndex;
    final token = ref.read(authNotifierProvider).token;
    final original = _dayItems[day][index];
    final item = await showDialog<ItineraryItemModel>(
      context: context,
      builder: (_) => EditActivityDialog(item: original),
    );
    if (item == null || !mounted || ref.read(authNotifierProvider).token != token) return;
    setState(() {
      _dayItems[day][index] = item;
      _dirtyDays.add(day);
    });
  }

  Future<void> _showDestinationSheet({int? replaceIndex}) async {
    if (_loadingCatalog || _isSaving) return;
    final token = ref.read(authNotifierProvider).token;
    final day = _selectedDayIndex;
    final travelers = _itinerary!.travelersCount;
    final previous = replaceIndex == null ? null : _dayItems[day][replaceIndex];
    setState(() => _loadingCatalog = true);
    try {
      final destinations = await ref.read(destinationRepositoryProvider).getDestinations();
      if (!mounted || ref.read(authNotifierProvider).token != token) return;
      setState(() => _loadingCatalog = false);
      final excluded = _itinerary!.constraints
          .where((constraint) => constraint.type == 'EXCLUDED')
          .map((constraint) => constraint.destinationId).toSet();
      await AddDestinationBottomSheet.show(
        context: context, dayNumber: day + 1, replacing: replaceIndex != null,
        destinations: destinations.where((dest) =>
          (dest.id ?? 0) > 0 && dest.id != previous?.destination?.id && !excluded.contains(dest.id)).toList(),
        onSelectDestination: (dest) {
          if (!mounted || ref.read(authNotifierProvider).token != token) return;
          setState(() {
            final items = _dayItems[day];
            final unitPrice = dest.priceMaxVnd ?? dest.priceMinVnd;
            final item = ItineraryItemModel(
              id: previous?.id, sequenceOrder: previous?.sequenceOrder ?? items.length + 1,
              startTime: previous?.startTime, notes: previous?.notes,
              estimatedCostVnd: unitPrice == null ? null : unitPrice * travelers,
              unitPriceVnd: unitPrice, upperPriceKnown: dest.priceMaxVnd != null,
              categoryCode: dest.categoryCode, destination: dest,
            );
            if (replaceIndex == null) {
              items.add(item);
            } else {
              items[replaceIndex] = item;
            }
            _dirtyDays.add(day);
          });
        },
      );
    } catch (_) {
      if (mounted && ref.read(authNotifierProvider).token == token) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: AppText('Không tải được địa điểm. Hãy thử lại.')),
        );
      }
    } finally {
      if (mounted && ref.read(authNotifierProvider).token == token) {
        setState(() => _loadingCatalog = false);
      }
    }
  }

  Future<void> _saveChanges() async {
    if (_itinerary == null || _isSaving || _loadingCatalog) return;
    final token = ref.read(authNotifierProvider).token;
    setState(() => _isSaving = true);

    try {
      final daysPayload = <DayUpdateModel>[];
      for (final i in _dirtyDays.toList()..sort()) {
        final originalDay = _itinerary!.days[i];
        final items = _dayItems[i];
        final itemUpdates = items.map((it) => ItemUpdateModel(
          id: it.id,
          destinationId: it.destination?.id,
          sequenceOrder: it.sequenceOrder,
          startTime: it.startTime,
          sendStartTime: true,
          durationMinutes: it.durationMinutes,
          sendDuration: true,
          notes: it.notes,
        )).toList();

        daysPayload.add(DayUpdateModel(dayId: originalDay.id > 0 ? originalDay.id : null,
          dayNumber: originalDay.dayNumber, items: itemUpdates));
      }

      final repo = ref.read(itineraryRepositoryProvider);
      final updated = await repo.updateActivities(widget.id, UpdateActivitiesRequestModel(
        days: daysPayload, version: _itinerary!.version, recalculateAll: daysPayload.isEmpty,
      ));

      if (mounted && ref.read(authNotifierProvider).token == token) {
        setState(() => _isSaving = false);
        ref.read(tripListsRevisionProvider.notifier).state++;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: AppText('Đã cập nhật lịch trình thành công!'), backgroundColor: AppTheme.statusSuccess),
        );
        setState(_dirtyDays.clear);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) Navigator.of(context).pop(updated);
        });
      }
    } on ItineraryConflictException {
      if (mounted && ref.read(authNotifierProvider).token == token) {
        setState(() => _isSaving = false);
        await _showConflict();
      }
    } catch (e) {
      if (mounted && ref.read(authNotifierProvider).token == token) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: AppText(e.toString().replaceFirst('Exception: ', '')), backgroundColor: AppTheme.statusError),
        );
      }
    }
  }

  Future<void> _showConflict() async {
    final token = ref.read(authNotifierProvider).token;
    final latest = await resolveItineraryConflict(context,
      () async {
        final repo = ref.read(itineraryRepositoryProvider);
        final latest = await repo.getItineraryById(widget.id);
        if (repo.usedCachedTrip(widget.id)) throw StateError('Chưa tải được bản mới từ máy chủ');
        return latest;
      });
    if (latest != null && mounted && ref.read(authNotifierProvider).token == token) {
      setState(() {
        _itinerary = latest;
        _selectedDayIndex = 0;
        _dirtyDays.clear();
        _dayItems = latest.days.map((day) => List<ItineraryItemModel>.from(day.items)).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authNotifierProvider.select((user) => user.token), (_, token) {
      setState(() {
        _itinerary = null;
        _dayItems = [];
        _dirtyDays.clear();
        _selectedDayIndex = 0;
        _errorMessage = null;
        _isLoading = token != null;
        _isSaving = false;
        _loadingCatalog = false;
      });
      if (token != null) _loadItinerary();
    });
    if (!ref.watch(authNotifierProvider).isAuthenticated) {
      return const Scaffold(body: ItineraryGuestView());
    }
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.bgCanvas,
        body: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue))),
      );
    }

    if (_errorMessage != null || _itinerary == null || _dayItems.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.bgCanvas,
        appBar: AppBar(title: const AppText('Chỉnh sửa lịch trình')),
        body: Center(child: AppText(_errorMessage ?? 'Lịch trình chưa có ngày để chỉnh sửa')),
      );
    }

    final days = _itinerary!.days;
    final currentItems = _dayItems[_selectedDayIndex];
    final dayCost = _calculateDayCost(_selectedDayIndex);

    return PopScope(
      canPop: _dirtyDays.isEmpty && !_isSaving && !_loadingCatalog,
      onPopInvokedWithResult: (didPop, result) { if (!didPop) _requestClose(); },
      child: Scaffold(
      backgroundColor: AppTheme.bgCanvas,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          tooltip: AppLanguage.text(context, 'Đóng'),
          icon: const Icon(Icons.close, color: AppTheme.textPrimary),
          onPressed: _isSaving ? null : _requestClose,
        ),
        title: Column(
          children: [
            const AppText(
              'Chỉnh sửa Lịch trình',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            AppText(
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
              onPressed: _isSaving || _loadingCatalog ? null : _saveChanges,
              icon: _isSaving
                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.check, size: 16),
              label: AppText(_isSaving ? 'Đang tính…' : 'Hoàn tất',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isSaving || _loadingCatalog)
            const LinearProgressIndicator(),
          EditItineraryDaySelector(
            days: days,
            selectedDayIndex: _selectedDayIndex,
            onSelectDay: (idx) => setState(() => _selectedDayIndex = idx),
          ),
          Expanded(
            child: AbsorbPointer(
              absorbing: _isSaving || _loadingCatalog,
              child: EditItineraryActivityList(
              selectedDayIndex: _selectedDayIndex,
              currentItems: currentItems,
              dayCost: dayCost,
              onMoveItem: _moveItem,
              onRemoveItem: _removeItem,
              onAddDestination: _showDestinationSheet,
              onEditItem: _editItem,
              onReplaceItem: (index) => _showDestinationSheet(replaceIndex: index),
              saving: _isSaving,
              savedDayCost: days[_selectedDayIndex].dayCostVnd,
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
