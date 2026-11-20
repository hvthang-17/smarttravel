class UpdateActivitiesRequestModel {
  final List<DayUpdateModel> days;
  final int version;
  final bool recalculateAll;

  const UpdateActivitiesRequestModel({required this.days, required this.version, this.recalculateAll = false});

  Map<String, dynamic> toJson() {
    if (version < 1) throw StateError('Thiếu phiên bản lịch trình từ máy chủ');
    return {
      'version': version,
      if (recalculateAll) 'recalculateAll': true,
      'days': days.map((d) => d.toJson()).toList(),
    };
  }
}

class DayUpdateModel {
  final int? dayId;
  final int? dayNumber;
  final List<ItemUpdateModel> items;

  const DayUpdateModel({
    this.dayId,
    this.dayNumber,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      if (dayId != null) 'dayId': dayId,
      if (dayNumber != null) 'dayNumber': dayNumber,
      'items': items.map((i) => i.toJson()).toList(),
    };
  }
}

class ItemUpdateModel {
  final int? id;
  final int? destinationId;
  final int sequenceOrder;
  final String? startTime;
  final bool sendStartTime;
  final int? durationMinutes;
  final bool sendDuration;
  final int? estimatedCostVnd;
  final String? notes;

  const ItemUpdateModel({
    this.id,
    this.destinationId,
    required this.sequenceOrder,
    this.startTime,
    this.sendStartTime = false,
    this.durationMinutes,
    this.sendDuration = false,
    this.estimatedCostVnd,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    if (id != null && id! <= 0) throw StateError('ID hoạt động không hợp lệ');
    if (destinationId != null && destinationId! <= 0) throw StateError('ID địa điểm không hợp lệ');
    if (id == null && destinationId == null) throw StateError('Hoạt động mới cần địa điểm hợp lệ');
    return {
      if (id != null) 'id': id,
      'destinationId': destinationId,
      'sequenceOrder': sequenceOrder,
      if (startTime != null || sendStartTime) 'startTime': startTime,
      if (durationMinutes != null || sendDuration) 'durationMinutes': durationMinutes,
      if (estimatedCostVnd != null) 'estimatedCostVnd': estimatedCostVnd,
      if (notes != null) 'notes': notes,
    };
  }
}

