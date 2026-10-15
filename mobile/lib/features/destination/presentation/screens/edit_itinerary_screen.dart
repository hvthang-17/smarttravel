import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarttravel_mobile/features/destination/data/models/destination_model.dart';
import 'package:smarttravel_mobile/features/destination/data/models/itinerary_model.dart';
import 'package:smarttravel_mobile/features/destination/data/repositories/destination_repository.dart';
import 'package:smarttravel_mobile/features/destination/data/repositories/itinerary_repository.dart';
import 'package:smarttravel_mobile/features/destination/presentation/providers/destination_provider.dart';

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
        if (data != null) {
          setState(() {
            _itinerary = data;
            _dayItems = data.days.map((d) => List<ItineraryItemModel>.from(d.items)).toList();
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'Không tìm thấy thông tin lịch trình';
            _isLoading = false;
          });
        }
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

  int _calculateTotalEstimatedCost() {
    int total = 0;
    for (final day in _dayItems) {
      for (final it in day) {
        total += it.estimatedCostVnd ?? 0;
      }
    }
    return total;
  }

  int _calculateDayCost(int dayIndex) {
    if (dayIndex >= _dayItems.length) return 0;
    int total = 0;
    for (final it in _dayItems[dayIndex]) {
      total += it.estimatedCostVnd ?? 0;
    }
    return total;
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

  void _moveItem(int oldIndex, int newIndex) {
    if (newIndex < 0 || newIndex >= _dayItems[_selectedDayIndex].length) return;
    setState(() {
      final item = _dayItems[_selectedDayIndex].removeAt(oldIndex);
      _dayItems[_selectedDayIndex].insert(newIndex, item);
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
    });
  }

  void _removeItem(int index) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa hoạt động'),
        content: const Text('Bạn có chắc chắn muốn xóa điểm đến này khỏi ngày?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy', style: TextStyle(color: Color(0xFF64748B))),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE76F51)),
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _dayItems[_selectedDayIndex].removeAt(index);
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

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Thêm điểm đến vào Ngày ${_selectedDayIndex + 1}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: allDestinations.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final d = allDestinations[i];
                    return ListTile(
                      title: Text(d.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text('${d.category} • ${d.priceMinVnd != null ? _formatVnd(d.priceMinVnd!) : "Miễn phí"} VNĐ'),
                      trailing: const Icon(Icons.add_circle_outline, color: Color(0xFF0077B6)),
                      onTap: () {
                        Navigator.of(ctx).pop();
                        _addDestinationToCurrentDay(d);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addDestinationToCurrentDay(DestinationModel dest) {
    setState(() {
      final currentList = _dayItems[_selectedDayIndex];
      final newSeq = currentList.length + 1;
      final travelers = _itinerary?.travelersCount ?? 1;
      final cost = (dest.priceMinVnd ?? 0) * travelers;

      currentList.add(
        ItineraryItemModel(
          id: 0,
          sequenceOrder: newSeq,
          startTime: '14:00',
          durationMinutes: 90,
          estimatedCostVnd: cost,
          notes: 'Khám phá ${dest.name}',
          destination: dest,
        ),
      );
    });
  }

  Future<void> _saveChanges() async {
    if (_itinerary == null) return;
    setState(() => _isSaving = true);

    try {
      final daysPayload = <DayUpdateModel>[];
      for (int i = 0; i < _itinerary!.days.length; i++) {
        final originalDay = _itinerary!.days[i];
        final items = _dayItems[i];
        final itemUpdates = items.map((it) {
          return ItemUpdateModel(
            id: it.id > 0 ? it.id : null,
            destinationId: it.destination?.id ?? 1,
            sequenceOrder: it.sequenceOrder,
            startTime: it.startTime ?? '09:00',
            durationMinutes: it.durationMinutes ?? 90,
            estimatedCostVnd: it.estimatedCostVnd ?? 0,
            notes: it.notes,
          );
        }).toList();

        daysPayload.add(
          DayUpdateModel(
            dayId: originalDay.id,
            dayNumber: originalDay.dayNumber,
            items: itemUpdates,
          ),
        );
      }

      final repo = ref.read(itineraryRepositoryProvider);
      final updated = await repo.updateActivities(
        widget.id,
        UpdateActivitiesRequestModel(days: daysPayload),
      );

      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã cập nhật lịch trình thành công!'),
            backgroundColor: Color(0xFF2A9D8F),
          ),
        );
        Navigator.of(context).pop(updated);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: const Color(0xFFE76F51),
          ),
        );
      }
    }
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
        appBar: AppBar(title: const Text('Chỉnh sửa lịch trình')),
        body: Center(child: Text(_errorMessage ?? 'Lỗi tải dữ liệu')),
      );
    }

    final days = _itinerary!.days;
    final currentItems = _dayItems[_selectedDayIndex];
    final dayCost = _calculateDayCost(_selectedDayIndex);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          children: [
            const Text(
              'Chỉnh sửa Lịch trình',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              '${_itinerary!.title} • ${_itinerary!.startDate} - ${_itinerary!.endDate}',
              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0077B6),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: _isSaving ? null : _saveChanges,
              icon: _isSaving
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.check, size: 16),
              label: const Text('Hoàn tất', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Day Selector Chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(days.length, (index) {
                  final isSelected = index == _selectedDayIndex;
                  final day = days[index];
                  final dateFormatted = (day.date != null && day.date!.isNotEmpty)
                      ? ' (${day.date!.split('-').reversed.take(2).join('/')})'
                      : '';
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => setState(() => _selectedDayIndex = index),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF0077B6) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF0077B6) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Text(
                          'Ngày ${index + 1}$dateFormatted',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // Main Reorderable Activity List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              children: [
                // Instruction card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F9FF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFBAE6FD)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0077B6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.swap_vert, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Chỉnh sửa thứ tự hoạt động',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0369A1),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Dùng nút mũi tên ↑ ↓ hoặc giữ biểu tượng kéo để thay đổi thứ tự các điểm tham quan.',
                              style: TextStyle(fontSize: 11, color: Color(0xFF0284C7), height: 1.4),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          side: const BorderSide(color: Color(0xFF0077B6)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('AI đã tối ưu lại tuyến đường ngắn nhất!'),
                              backgroundColor: Color(0xFF2A9D8F),
                            ),
                          );
                        },
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome, size: 12, color: Color(0xFF0077B6)),
                            SizedBox(width: 4),
                            Text('Tối ưu AI', style: TextStyle(fontSize: 11, color: Color(0xFF0077B6), fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Activity Items
                ...currentItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isLast = index == currentItems.length - 1;

                  return Column(
                    children: [
                      _buildActivityEditCard(item, index, currentItems.length),
                      if (!isLast)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              const SizedBox(width: 44),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0077B6),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.directions_car, size: 12, color: Color(0xFF64748B)),
                                    SizedBox(width: 4),
                                    Text(
                                      '15p • 4.2 km di chuyển',
                                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                }),
                const SizedBox(height: 16),

                // Dashed Add Button
                InkWell(
                  onTap: _showAddDestinationSheet,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F9FF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF0077B6),
                        style: BorderStyle.solid,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFF0077B6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add, size: 14, color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Thêm địa điểm vào Ngày ${_selectedDayIndex + 1}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0077B6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Bottom Summary Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.bar_chart, color: Color(0xFF0077B6), size: 18),
                              const SizedBox(width: 6),
                              Text(
                                'Tổng quan Ngày ${_selectedDayIndex + 1} sau chỉnh sửa',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2FE),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Tự động cập nhật',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0284C7),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatColumn('Số địa điểm', '${currentItems.length} điểm đến'),
                          _buildStatColumn('Ước tính chi phí', '${_formatVnd(dayCost)} VNĐ'),
                          _buildStatColumn('Thời gian di chuyển', '~${(currentItems.length * 1.5).toStringAsFixed(1)} giờ'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityEditCard(ItineraryItemModel item, int index, int total) {
    final dest = item.destination;
    final emoji = dest?.category.contains('Biển') == true
        ? '🏖️'
        : dest?.category.contains('Ẩm thực') == true
            ? '🍜'
            : dest?.category.contains('Văn hóa') == true
                ? '🛕'
                : '📸';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Drag handle icon
          const Icon(Icons.drag_indicator, color: Color(0xFF94A3B8), size: 20),
          const SizedBox(width: 8),

          // Sequence Node
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Color(0xFF0077B6),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '0${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        dest?.name ?? 'Điểm tham quan',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.startTime ?? "08:00"} - ${item.durationMinutes ?? 90}p • ${item.notes ?? ""}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.estimatedCostVnd != null && item.estimatedCostVnd! > 0
                            ? '${_formatVnd(item.estimatedCostVnd!)}đ'
                            : 'Miễn phí',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0284C7),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '• ${dest?.category ?? "Đà Nẵng"}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action Controls: Up, Down, Delete
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: index > 0 ? () => _moveItem(index, index - 1) : null,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: index > 0 ? const Color(0xFFF1F5F9) : const Color(0xFFF8F9FA),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_up,
                    size: 18,
                    color: index > 0 ? const Color(0xFF0F172A) : const Color(0xFFCBD5E1),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: index < total - 1 ? () => _moveItem(index, index + 1) : null,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: index < total - 1 ? const Color(0xFFF1F5F9) : const Color(0xFFF8F9FA),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: index < total - 1 ? const Color(0xFF0F172A) : const Color(0xFFCBD5E1),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: () => _removeItem(index),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEE2E2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: Color(0xFFEF4444),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
