class DestinationModel {
  final int id;
  final String name;
  final String category;
  final String? description;
  final double latitude;
  final double longitude;
  final int? priceMinVnd;
  final int? priceMaxVnd;
  final String status;

  const DestinationModel({
    required this.id,
    required this.name,
    required this.category,
    this.description,
    required this.latitude,
    required this.longitude,
    this.priceMinVnd,
    this.priceMaxVnd,
    required this.status,
  });

  factory DestinationModel.fromJson(Map<String, dynamic> json) {
    return DestinationModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      description: json['description'] as String?,
      latitude: (json['latitude'] as num? ?? 0.0).toDouble(),
      longitude: (json['longitude'] as num? ?? 0.0).toDouble(),
      priceMinVnd: json['priceMinVnd'] as int?,
      priceMaxVnd: json['priceMaxVnd'] as int?,
      status: json['status'] as String? ?? 'ACTIVE',
    );
  }
}
