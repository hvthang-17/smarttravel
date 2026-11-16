import 'package:smarttravel_mobile/core/network/api_client.dart';
import '../../data/models/destination_model.dart';

String localizedText(String original, String? english, String language) =>
    language == 'en' && english?.trim().isNotEmpty == true
        ? english!.trim()
        : original;

String destinationName(DestinationModel destination, String language) =>
    localizedText(destination.name, destination.nameEn, language);

String destinationCategoryName(DestinationModel destination, String language) =>
    localizedText(destination.category, destination.categoryNameEn, language);

String formatDestinationPrice(int? min, int? max) {
  String vnd(int value) {
    final digits = value.toString();
    final grouped = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) grouped.write('.');
      grouped.write(digits[i]);
    }
    return '$grouped đ';
  }

  if (min == null && max == null) return 'Chưa rõ giá';
  if (min == 0 && max == 0) return 'Miễn phí';
  if (min == null) return 'Tối đa ${vnd(max!)}';
  if (max == null) return 'Từ ${vnd(min)}';
  return min == max ? vnd(min) : '${vnd(min)} – ${vnd(max)}';
}

String? destinationImageUrl(String? value) {
  final raw = value?.trim() ?? '';
  if (raw.isEmpty) return null;
  final uri = Uri.tryParse(raw);
  if (uri == null) return null;
  if ((uri.scheme == 'https' || uri.scheme == 'http') && uri.host.isNotEmpty) {
    return uri.toString();
  }
  if (!uri.hasAuthority && uri.path.startsWith('/uploads/')) {
    return Uri.parse(resolveBaseUrl()).resolveUri(uri).toString();
  }
  return null;
}

Uri? destinationMapUri(DestinationModel destination) {
  if (!destination.hasCoordinates) return null;
  return Uri.https('www.google.com', '/maps/search/', {
    'api': '1',
    'query': '${destination.latitude},${destination.longitude}',
  });
}

String formatOpeningSchedule(DestinationModel destination) {
  final week = destination.openingSchedule?['week'];
  if (week is! Map) return _compactLegacyHours(destination.openingHours);
  final hours = List.generate(7, (index) {
    final periods = week['${index + 1}'];
    if (periods is! List) return 'Chưa rõ';
    if (periods.isEmpty) return 'Đóng cửa';
    final ranges = <String>[];
    for (final period in periods) {
      if (period is! List ||
          period.length != 2 ||
          period[0] is! int ||
          period[1] is! int) {
        return 'Chưa rõ';
      }
      final start = period[0] as int;
      final end = period[1] as int;
      if (start < 0 || start >= end || end > 1440) return 'Chưa rõ';
      ranges.add(start == 0 && end == 1440
          ? 'Mở cả ngày'
          : '${_time(start)}–${_time(end)}');
    }
    return ranges.join(', ');
  });
  return hours.every((value) => value == 'Chưa rõ')
      ? 'Chưa rõ giờ hoạt động'
      : _groupHours(hours);
}

const _days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

String _groupHours(List<String> hours) {
  final result = <String>[];
  for (var start = 0; start < hours.length;) {
    var end = start;
    while (end + 1 < hours.length && hours[end + 1] == hours[start]) {
      end++;
    }
    final label = start == end ? _days[start] : '${_days[start]}–${_days[end]}';
    result.add('$label: ${hours[start]}');
    start = end + 1;
  }
  return result.join('\n');
}

String _compactLegacyHours(String? text) {
  if (text == null || text.trim().isEmpty) return 'Chưa rõ giờ hoạt động';
  final values = text.split(';').map((value) => value.trim()).toList();
  if (values.length != 7) return text;
  final hours = <String>[];
  for (var index = 0; index < 7; index++) {
    final prefix = '${_days[index]}:';
    if (!values[index].startsWith(prefix)) return text;
    hours.add(values[index].substring(prefix.length).trim());
  }
  return _groupHours(hours);
}

String _time(int minutes) =>
    '${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}';
