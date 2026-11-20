import 'itinerary_model.dart';

class SavedTripPage {
  final List<ItineraryResponseModel> items;
  final bool hasNext;
  final int total;
  final bool cached;

  const SavedTripPage(this.items, this.hasNext, this.total, {this.cached = false});

  factory SavedTripPage.fromJson(Map<String, dynamic> data) => SavedTripPage(
    (data['items'] as List).map((item) =>
      ItineraryResponseModel.fromJson(item as Map<String, dynamic>)).toList(),
    data['hasNext'] == true,
    data['total'] as int,
  );
}

class TripShareLink {
  final String state;
  final Uri? url;
  final DateTime? expiresAt;
  const TripShareLink(this.state, this.url, this.expiresAt);

  factory TripShareLink.fromJson(Map<String, dynamic> data, String apiBase) {
    final path = data['shareUrl'] as String?;
    final expires = data['expiresAt'] as String?;
    return TripShareLink(
      data['state'] as String,
      path == null ? null : Uri.parse(apiBase).resolve(path),
      expires == null ? null : DateTime.parse(expires),
    );
  }
}

class SharedTrip {
  final String title;
  final String startDate;
  final String endDate;
  final List<ItineraryDayModel> days;
  const SharedTrip(this.title, this.startDate, this.endDate, this.days);

  factory SharedTrip.fromJson(Map<String, dynamic> data) => SharedTrip(
    data['title'] as String, data['startDate'] as String, data['endDate'] as String,
    (data['days'] as List).map((day) =>
      ItineraryDayModel.fromJson(day as Map<String, dynamic>)).toList(),
  );
}

class SharedTripUnavailable implements Exception {
  final bool expired;
  const SharedTripUnavailable({required this.expired});
}
