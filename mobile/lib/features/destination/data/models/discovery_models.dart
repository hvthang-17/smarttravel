import 'destination_model.dart';

typedef DiscoveryQuery = ({
  String search,
  String? category,
  int? minPrice,
  int? maxPrice,
  int page,
});

class DiscoveryPage {
  final List<DestinationModel> items;
  final bool hasNext;

  const DiscoveryPage(this.items, this.hasNext);
}

class DestinationCategory {
  final String code;
  final String name;
  final String? nameEn;

  const DestinationCategory(this.code, this.name, this.nameEn);

  String label(String language) =>
      language == 'en' && nameEn?.trim().isNotEmpty == true
          ? nameEn!.trim()
          : name;
}
