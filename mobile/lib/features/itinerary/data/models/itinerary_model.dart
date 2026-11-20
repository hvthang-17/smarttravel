import 'package:smarttravel_mobile/features/destination/data/models/destination_model.dart';
export 'itinerary_update_models.dart';

class ItineraryRequestModel {
  final String title;
  final String startDate;
  final String endDate;
  final int travelersCount;
  final int maxBudgetVnd;
  final String pace;
  final String transport;
  final String? originName;
  final double? originLatitude;
  final double? originLongitude;
  final List<String> preferredCategories;
  final List<int> favoriteDestinationIds;
  final List<int> requiredDestinationIds;
  final List<int> excludedDestinationIds;
  final String? generationKey;

  const ItineraryRequestModel({
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.travelersCount,
    required this.maxBudgetVnd,
    required this.pace,
    this.transport = 'unspecified', this.originName, this.originLatitude, this.originLongitude,
    required this.preferredCategories,
    this.favoriteDestinationIds = const [],
    this.requiredDestinationIds = const [],
    this.excludedDestinationIds = const [],
    this.generationKey,
  });

  ItineraryRequestModel withGenerationKey(String key) => ItineraryRequestModel(
    title: title, startDate: startDate, endDate: endDate, travelersCount: travelersCount,
    maxBudgetVnd: maxBudgetVnd, pace: pace, transport: transport, originName: originName,
    originLatitude: originLatitude, originLongitude: originLongitude,
    preferredCategories: preferredCategories, favoriteDestinationIds: favoriteDestinationIds,
    requiredDestinationIds: requiredDestinationIds, excludedDestinationIds: excludedDestinationIds,
    generationKey: key,
  );

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'startDate': startDate,
      'endDate': endDate,
      'travelersCount': travelersCount,
      'maxBudgetVnd': maxBudgetVnd,
      'pace': pace, 'transport': transport, 'originName': originName, 'originLatitude': originLatitude, 'originLongitude': originLongitude,
      'preferredCategories': preferredCategories,
      if (favoriteDestinationIds.isNotEmpty) 'favoriteDestinationIds': favoriteDestinationIds,
      if (requiredDestinationIds.isNotEmpty) 'requiredDestinationIds': requiredDestinationIds,
      if (excludedDestinationIds.isNotEmpty) 'excludedDestinationIds': excludedDestinationIds,
      if (generationKey != null) 'generationKey': generationKey,
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
  final String? period;
  final int version;
  final Map<String, int> categoryBreakdown;
  final double budgetUtilizationPercent;
  final String budgetHealth;
  final bool costComplete;
  final String transport;
  final List<String> warnings;
  final String generationStatus;
  final String? originName;
  final List<TripConstraintModel> constraints;
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
    this.period,
    this.version = 0,
    required this.categoryBreakdown,
    required this.budgetUtilizationPercent,
    required this.budgetHealth,
    this.costComplete = false, this.transport = 'unspecified', this.warnings = const [], this.generationStatus = 'PARTIAL',
    this.originName,
    this.constraints = const [],
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
    if (json['costComplete'] != true) {
      health = 'UNKNOWN';
    } else if (health.isEmpty) {
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
      status: json['status'] as String? ?? 'DRAFT',
      shareToken: json['shareToken'] as String?,
      period: json['period'] as String?,
      version: json['version'] as int? ?? 0,
      categoryBreakdown: breakdown,
      budgetUtilizationPercent: utilPercent,
      budgetHealth: health,
      costComplete: json['costComplete'] == true, transport: json['transport'] as String? ?? 'unspecified',
      originName: json['originName'] as String?,
      constraints: (json['constraints'] as List<dynamic>? ?? []).whereType<Map<String, dynamic>>()
          .map(TripConstraintModel.fromJson).toList(),
      warnings: (json['warnings'] as List<dynamic>? ?? []).cast<String>(), generationStatus: json['generationStatus'] as String? ?? 'PARTIAL',
      days: daysList
          .map((d) => ItineraryDayModel.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TripConstraintModel {
  const TripConstraintModel(this.destinationId, this.type, this.name);
  final int destinationId;
  final String type;
  final String? name;

  factory TripConstraintModel.fromJson(Map<String, dynamic> json) {
    final snapshot = json['snapshot'] as Map<String, dynamic>?;
    return TripConstraintModel(json['destinationId'] as int, json['type'] as String, snapshot?['name'] as String?);
  }
}

class ItineraryDayModel {
  final int id;
  final int dayNumber;
  final String? date;
  final int dayCostVnd;
  final double? totalDistanceKm;
  final int? totalDurationMinutes;
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

  bool get costComplete =>
      items.every((item) => item.estimatedCostVnd != null && item.upperPriceKnown);

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
      totalDistanceKm: (json['totalDistanceKm'] as num?)?.toDouble(),
      totalDurationMinutes: json['totalDurationMinutes'] as int?,
      items: parsedItems,
    );
  }
}

class ItineraryItemModel {
  final int? id;
  final int sequenceOrder;
  final String? startTime;
  final int? durationMinutes;
  final int? estimatedCostVnd;
  final String? notes;
  final String? recommendationReason;
  final bool featuredRecommendation;
  final bool upperPriceKnown;
  final String? categoryCode;
  final int? unitPriceVnd;
  final String routeSource;
  final String? routePolyline;
  final double? travelDistanceKm;
  final int? travelMinutes;
  final DestinationModel? destination;

  const ItineraryItemModel({
    required this.id,
    required this.sequenceOrder,
    this.startTime,
    this.durationMinutes,
    this.estimatedCostVnd,
    this.notes,
    this.recommendationReason,
    this.featuredRecommendation = false,
    this.upperPriceKnown = true,
    this.categoryCode, this.unitPriceVnd, this.routeSource = 'UNKNOWN', this.routePolyline,
    this.travelDistanceKm,
    this.travelMinutes,
    this.destination,
  });

  int? get previewDurationMinutes => durationMinutes ?? destination?.suggestedVisitDurationMinutes ?? destination?.visitDurationMinutes;

  ItineraryItemModel edited({
    required int sequence,
    required String? time,
    required int? duration,
    required String? note,
  }) => ItineraryItemModel(
    id: id, sequenceOrder: sequence, startTime: time, durationMinutes: duration,
    estimatedCostVnd: estimatedCostVnd, notes: note, recommendationReason: recommendationReason,
    featuredRecommendation: featuredRecommendation, upperPriceKnown: upperPriceKnown,
    categoryCode: categoryCode, unitPriceVnd: unitPriceVnd, routeSource: routeSource,
    routePolyline: routePolyline, travelDistanceKm: travelDistanceKm, travelMinutes: travelMinutes,
    destination: destination,
  );

  factory ItineraryItemModel.fromJson(Map<String, dynamic> json) {
    DestinationModel? dest;
    if (json['destination'] != null) {
      dest = DestinationModel.fromJson(json['destination'] as Map<String, dynamic>);
    }
    return ItineraryItemModel(
      id: json['id'] as int?,
      sequenceOrder: json['sequenceOrder'] as int? ?? 1,
      startTime: json['startTime'] as String?,
      durationMinutes: json['durationMinutes'] as int?,
      estimatedCostVnd: json['estimatedCostVnd'] as int?,
      notes: json['notes'] as String?,
      recommendationReason: json['recommendationReason'] as String?,
      featuredRecommendation: json['featuredRecommendation'] == true,
      upperPriceKnown: json['upperPriceKnown'] != false,
      categoryCode: json['categoryCode'] as String?, unitPriceVnd: json['unitPriceVnd'] as int?,
      routeSource: json['routeSource'] as String? ?? 'UNKNOWN', routePolyline: json['routePolyline'] as String?,
      travelDistanceKm: (json['travelDistanceKm'] as num?)?.toDouble(),
      travelMinutes: json['travelMinutes'] as int?,
      destination: dest,
    );
  }
}

