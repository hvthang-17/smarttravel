class TravelerProfile {
  final String language;
  final int? defaultBudgetVnd;
  final String defaultPace;
  final String defaultTransport;
  final List<String> preferredCategories;

  const TravelerProfile({
    this.language = 'vi',
    this.defaultBudgetVnd,
    this.defaultPace = 'balanced',
    this.defaultTransport = 'unspecified',
    this.preferredCategories = const [],
  });

  factory TravelerProfile.fromJson(Map<String, dynamic> json) => TravelerProfile(
    language: json['language'] as String? ?? 'vi',
    defaultBudgetVnd: json['defaultBudgetVnd'] as int?,
    defaultPace: json['defaultPace'] as String? ?? 'balanced',
    defaultTransport: json['defaultTransport'] as String? ?? 'unspecified',
    preferredCategories: List.unmodifiable(
      (json['preferredCategories'] as List<dynamic>? ?? []).whereType<String>(),
    ),
  );

  Map<String, dynamic> toJson() => {
    'language': language,
    'defaultBudgetVnd': defaultBudgetVnd,
    'defaultPace': defaultPace,
    'defaultTransport': defaultTransport,
    'preferredCategories': preferredCategories,
  };
}

const travelerLanguages = {'vi': 'Tiếng Việt', 'en': 'English'};
const travelerPaces = {'relaxed': 'Thư thả', 'balanced': 'Cân bằng', 'packed': 'Năng động'};
const travelerTransports = {
  'unspecified': 'Chưa chọn', 'walking': 'Đi bộ', 'motorbike': 'Xe máy',
  'car': 'Ô tô', 'taxi': 'Taxi',
};

