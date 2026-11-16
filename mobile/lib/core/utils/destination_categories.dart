const destinationCategoryLabels = <String, String>{
  'BEACH': 'Biển', 'FOOD': 'Ăn uống', 'CULTURE': 'Văn hóa',
  'CHECKIN': 'Check-in', 'CAFE': 'Cà phê', 'NIGHTLIFE': 'Giải trí đêm',
};
const destinationCategoryLabelsEn = <String, String>{
  'BEACH': 'Beach', 'FOOD': 'Food', 'CULTURE': 'Culture',
  'CHECKIN': 'Check-in', 'CAFE': 'Cafe', 'NIGHTLIFE': 'Nightlife',
};
String categoryLabel(String code, {String language = 'vi'}) =>
    (language == 'en' ? destinationCategoryLabelsEn[code] : destinationCategoryLabels[code])
        ?? (language == 'en' ? 'Other category' : 'Danh mục khác');
