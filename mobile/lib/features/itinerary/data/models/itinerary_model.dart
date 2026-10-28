import 'package:smarttravel_mobile/features/destination/data/models/destination_model.dart';

class ItineraryRequestModel {
  final String title;
  final String startDate;
  final String endDate;
  final int travelersCount;
  final int maxBudgetVnd;
  final String pace;
  final List<String> preferredCategories;

  const ItineraryRequestModel({
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.travelersCount,
    required this.maxBudgetVnd,
    required this.pace,
    required this.preferredCategories,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'startDate': startDate,
      'endDate': endDate,
      'travelersCount': travelersCount,
      'maxBudgetVnd': maxBudgetVnd,
      'pace': pace,
      'preferredCategories': preferredCategories,
    };
  }
}

class ItineraryResponseModel {
  final int id;
  final String title;
  final String startDate;
  final String endDate;
  final int totalDays;
  final int travelersCount;
  final int maxBudgetVnd;
  final String pace;
  final int totalEstimatedCost;
  final String status;
  final String? shareToken;
  final int version;
  final Map<String, int> categoryBreakdown;
  final double budgetUtilizationPercent;
  final String budgetHealth;
  final List<ItineraryDayModel> days;

  const ItineraryResponseModel({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.travelersCount,
    required this.maxBudgetVnd,
    required this.pace,
    required this.totalEstimatedCost,
    required this.status,
    this.shareToken,
    this.version = 1,
    required this.categoryBreakdown,
    required this.budgetUtilizationPercent,
    required this.budgetHealth,
    required this.days,
  });

  factory ItineraryResponseModel.fromJson(Map<String, dynamic> json) {
    final daysList = json['days'] as List<dynamic>? ?? [];

    final rawBreakdown = json['categoryBreakdown'] as Map<String, dynamic>? ?? {};
    final breakdown = <String, int>{};
    rawBreakdown.forEach((key, val) {
      if (val is num) breakdown[key] = val.toInt();
    });

    final totalCost = json['totalEstimatedCost'] as int? ?? 0;
    final maxBudget = json['maxBudgetVnd'] as int? ?? 0;
    final defaultPercent = maxBudget > 0 ? (totalCost * 100.0) / maxBudget : 0.0;
    final utilPercent = (json['budgetUtilizationPercent'] as num?)?.toDouble() ?? defaultPercent;

    String health = json['budgetHealth'] as String? ?? '';
    if (health.isEmpty) {
      if (utilPercent > 100.0) {
        health = 'OVERBUDGET';
      } else if (utilPercent >= 85.0) {
        health = 'WARNING';
      } else {
        health = 'HEALTHY';
      }
    }

    return ItineraryResponseModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
      totalDays: json['totalDays'] as int? ?? 1,
      travelersCount: json['travelersCount'] as int? ?? 1,
      maxBudgetVnd: maxBudget,
      pace: json['pace'] as String? ?? 'balanced',
      totalEstimatedCost: totalCost,
      status: json['status'] as String? ?? 'ACTIVE',
      shareToken: json['shareToken'] as String?,
      version: json['version'] as int? ?? 1,
      categoryBreakdown: breakdown,
      budgetUtilizationPercent: utilPercent,
      budgetHealth: health,
      days: daysList
          .map((d) => ItineraryDayModel.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ItineraryDayModel {
  final int id;
  final int dayNumber;
  final String? date;
  final int dayCostVnd;
  final double totalDistanceKm;
  final int totalDurationMinutes;
  final List<ItineraryItemModel> items;

  const ItineraryDayModel({
    required this.id,
    required this.dayNumber,
    this.date,
    required this.dayCostVnd,
    required this.totalDistanceKm,
    required this.totalDurationMinutes,
    required this.items,
  });

  factory ItineraryDayModel.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List<dynamic>? ?? [];
    final parsedItems = itemsList
        .map((item) => ItineraryItemModel.fromJson(item as Map<String, dynamic>))
        .toList();

    int calculatedCost = 0;
    for (final it in parsedItems) {
      calculatedCost += it.estimatedCostVnd ?? 0;
    }

    return ItineraryDayModel(
      id: json['id'] as int? ?? 0,
      dayNumber: json['dayNumber'] as int? ?? 1,
      date: json['date'] as String?,
      dayCostVnd: json['dayCostVnd'] as int? ?? calculatedCost,
      totalDistanceKm: (json['totalDistanceKm'] as num?)?.toDouble() ?? 0.0,
      totalDurationMinutes: json['totalDurationMinutes'] as int? ?? 0,
      items: parsedItems,
    );
  }
}

class ItineraryItemModel {
  final int id;
  final int sequenceOrder;
  final String? startTime;
  final int? durationMinutes;
  final int? estimatedCostVnd;
  final String? notes;
  final double travelDistanceKm;
  final int travelMinutes;
  final DestinationModel? destination;

  const ItineraryItemModel({
    required this.id,
    required this.sequenceOrder,
    this.startTime,
    this.durationMinutes,
    this.estimatedCostVnd,
    this.notes,
    this.travelDistanceKm = 0.0,
    this.travelMinutes = 0,
    this.destination,
  });

  factory ItineraryItemModel.fromJson(Map<String, dynamic> json) {
    DestinationModel? dest;
    if (json['destination'] != null) {
      dest = DestinationModel.fromJson(json['destination'] as Map<String, dynamic>);
    }
    return ItineraryItemModel(
      id: json['id'] as int? ?? 0,
      sequenceOrder: json['sequenceOrder'] as int? ?? 1,
      startTime: json['startTime'] as String?,
      durationMinutes: json['durationMinutes'] as int?,
      estimatedCostVnd: json['estimatedCostVnd'] as int?,
      notes: json['notes'] as String?,
      travelDistanceKm: (json['travelDistanceKm'] as num?)?.toDouble() ?? 0.0,
      travelMinutes: json['travelMinutes'] as int? ?? 0,
      destination: dest,
    );
  }
}

class UpdateActivitiesRequestModel {
  final List<DayUpdateModel> days;

  const UpdateActivitiesRequestModel({required this.days});

  Map<String, dynamic> toJson() {
    return {
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
  final int destinationId;
  final int sequenceOrder;
  final String? startTime;
  final int? durationMinutes;
  final int? estimatedCostVnd;
  final String? notes;

  const ItemUpdateModel({
    this.id,
    required this.destinationId,
    required this.sequenceOrder,
    this.startTime,
    this.durationMinutes,
    this.estimatedCostVnd,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'destinationId': destinationId,
      'sequenceOrder': sequenceOrder,
      if (startTime != null) 'startTime': startTime,
      if (durationMinutes != null) 'durationMinutes': durationMinutes,
      if (estimatedCostVnd != null) 'estimatedCostVnd': estimatedCostVnd,
      if (notes != null) 'notes': notes,
    };
  }
}

