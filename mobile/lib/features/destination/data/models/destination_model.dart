class DestinationModel {
  final int id;
  final String name;
  final String category;
  final int? categoryId;
  final String? categoryCode;
  final String? categoryIcon;
  final String? categoryColor;
  final String? description;
  final String? address;
  final String? openingHours;
  final String? phone;
  final String? website;
  final String? imageUrl;
  final List<String> subImages;
  final double rating;
  final int reviewCount;
  final String? osmId;
  final double latitude;
  final double longitude;
  final int? priceMinVnd;
  final int? priceMaxVnd;
  final String status;

  const DestinationModel({
    required this.id,
    required this.name,
    required this.category,
    this.categoryId,
    this.categoryCode,
    this.categoryIcon,
    this.categoryColor,
    this.description,
    this.address,
    this.openingHours,
    this.phone,
    this.website,
    this.imageUrl,
    this.subImages = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
    this.osmId,
    required this.latitude,
    required this.longitude,
    this.priceMinVnd,
    this.priceMaxVnd,
    required this.status,
  });

  factory DestinationModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedSubImages = [];
    if (json['subImages'] is List) {
      parsedSubImages = (json['subImages'] as List)
          .map((item) => item.toString())
          .where((item) => item.trim().isNotEmpty)
          .toList();
    }

    return DestinationModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      categoryId: json['categoryId'] as int?,
      categoryCode: json['categoryCode'] as String?,
      categoryIcon: json['categoryIcon'] as String?,
      categoryColor: json['categoryColor'] as String?,
      description: json['description'] as String?,
      address: json['address'] as String?,
      openingHours: json['openingHours'] as String?,
      phone: json['phone'] as String?,
      website: json['website'] as String?,
      imageUrl: json['imageUrl'] as String?,
      subImages: parsedSubImages,
      rating: (json['rating'] as num? ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] as int? ?? 0,
      osmId: json['osmId'] as String?,
      latitude: (json['latitude'] as num? ?? 0.0).toDouble(),
      longitude: (json['longitude'] as num? ?? 0.0).toDouble(),
      priceMinVnd: json['priceMinVnd'] as int?,
      priceMaxVnd: json['priceMaxVnd'] as int?,
      status: json['status'] as String? ?? 'ACTIVE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      if (categoryId != null) 'categoryId': categoryId,
      if (categoryCode != null) 'categoryCode': categoryCode,
      if (categoryIcon != null) 'categoryIcon': categoryIcon,
      if (categoryColor != null) 'categoryColor': categoryColor,
      if (description != null) 'description': description,
      if (address != null) 'address': address,
      if (openingHours != null) 'openingHours': openingHours,
      if (phone != null) 'phone': phone,
      if (website != null) 'website': website,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'subImages': subImages,
      'rating': rating,
      'reviewCount': reviewCount,
      if (osmId != null) 'osmId': osmId,
      'latitude': latitude,
      'longitude': longitude,
      if (priceMinVnd != null) 'priceMinVnd': priceMinVnd,
      if (priceMaxVnd != null) 'priceMaxVnd': priceMaxVnd,
      'status': status,
    };
  }
}
