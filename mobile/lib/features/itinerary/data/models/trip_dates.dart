DateTime planningToday([DateTime? now]) {
  final inDaNang = (now ?? DateTime.now()).toUtc().add(const Duration(hours: 7));
  return DateTime.utc(inDaNang.year, inDaNang.month, inDaNang.day);
}

DateTime tripDateOnly(DateTime value) => DateTime.utc(value.year, value.month, value.day);
