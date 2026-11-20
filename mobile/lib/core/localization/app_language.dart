import 'package:flutter/material.dart';

class AppLanguage extends InheritedWidget {
  final String language;
  final Map<String, String> english;

  const AppLanguage({
    super.key,
    required this.language,
    required this.english,
    required super.child,
  });

  static String text(BuildContext context, String text) {
    final locale = context.dependOnInheritedWidgetOfExactType<AppLanguage>();
    if (locale?.language != 'en') return text;
    final exact = locale!.english[text];
    if (exact != null) return exact;
    final patterns = <(RegExp, String Function(Match))>[
      (RegExp(r'^Ngày (\d+)$'), (m) => 'Day ${m[1]}'),
      (RegExp(r'^Bước (\d+) / (\d+)$'), (m) => 'Step ${m[1]} / ${m[2]}'),
      (RegExp(r'^(\d+) ngày (\d+) đêm$'), (m) => '${m[1]} days, ${m[2]} nights'),
      (RegExp(r'^(\d+) người$'), (m) => '${m[1]} travelers'),
      (RegExp(r'^(\d+) phút$'), (m) => '${m[1]} minutes'),
      (RegExp(r'^Chọn địa điểm \((\d+)/5\)$'), (m) => 'Choose places (${m[1]}/5)'),
      (RegExp(r'^Thêm địa điểm vào Ngày (\d+)$'), (m) => 'Add a place to day ${m[1]}'),
      (RegExp(r'^Ngày (\d+) · (.*)$'), (m) => 'Day ${m[1]} · ${m[2]}'),
      (RegExp(r'^(\d+)/5 sao(.*)$'), (m) => '${m[1]}/5 stars${m[2]}'),
      (RegExp(r'^(\d+) sao$'), (m) => '${m[1]} stars'),
      (RegExp(r'^(\d+) chuyến đi$'), (m) => '${m[1]} trips'),
      (RegExp(r'^(\d+)/(\d+) ảnh$'), (m) => '${m[1]}/${m[2]} photos'),
      (RegExp(r'^(.*)% ngân sách$'), (m) => '${m[1]}% of budget'),
      (RegExp(r'^Chi phí đã biết: (.*)$'), (m) => 'Known cost: ${m[1]}'),
      (RegExp(r'^Cảm giác như (.*)$'), (m) => 'Feels like ${m[1]}'),
      (RegExp(r'^Hết hạn lúc (.*)$'), (m) => 'Expires at ${m[1]}'),
      (RegExp(r'^Điểm (\d+)$'), (m) => 'Place ${m[1]}'),
      (RegExp(r'^Điểm xuất phát · (.*)$'), (m) => 'Starting point · ${m[1]}'),
      (RegExp(r'^Ước tính: ~(.*) đ / người$'), (m) => 'Estimate: ~${m[1]} VND / person'),
      (RegExp(r'^(.*) · (\d+) ngày$'), (m) => '${m[1]} · ${m[2]} days'),
      (RegExp(r'^(.*) · Chỉ xem$'), (m) => '${m[1]} · Read only'),
      (RegExp(r'^(.*) VNĐ \(đã biết\)$'), (m) => '${m[1]} VND (known)'),
      (RegExp(r'^Lịch trình “(.*)” sẽ bị xóa và liên kết chia sẻ sẽ mất hiệu lực\.$'),
        (m) => 'Itinerary “${m[1]}” will be deleted and its shared links will stop working.'),
      (RegExp(r'^Chọn điểm muốn đưa vào lịch trình\. Đã chọn (.*)\.$'),
        (m) => 'Choose places for this trip. Selected ${m[1]}.'),
      (RegExp(r'^Tổng chi phí vượt (.*) VNĐ so với hạn mức ban đầu\. Hãy cân nhắc điều chỉnh hoặc tăng ngân sách\.$'),
        (m) => 'Known cost exceeds the budget by ${m[1]} VND. Adjust activities or increase the budget.'),
    ];
    for (final (pattern, translate) in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) return translate(match);
    }
    const days = {'T2': 'Mon', 'T3': 'Tue', 'T4': 'Wed', 'T5': 'Thu', 'T6': 'Fri', 'T7': 'Sat', 'CN': 'Sun'};
    return text.replaceAllMapped(RegExp(r'\b(T[2-7]|CN)\b'), (match) => days[match[0]]!)
      .replaceAll('Chưa rõ giờ mở cửa', 'Opening hours unknown')
      .replaceAll('Chưa đặt giờ', 'Time not set')
      .replaceAll('phút', 'minutes').replaceAll('đ/khách', 'VND/person')
      .replaceAll('(không khả dụng)', '(unavailable)');
  }

  @override
  bool updateShouldNotify(AppLanguage oldWidget) =>
      language != oldWidget.language || english != oldWidget.english;
}

class AppText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final TextScaler? textScaler;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;

  const AppText(this.data, {
    super.key, this.style, this.strutStyle, this.textAlign, this.textDirection,
    this.locale, this.softWrap, this.overflow, this.textScaler, this.maxLines,
    this.semanticsLabel, this.textWidthBasis, this.textHeightBehavior,
    this.selectionColor,
  });

  @override
  Widget build(BuildContext context) => Text(
    AppLanguage.text(context, data),
    style: style, strutStyle: strutStyle, textAlign: textAlign,
    textDirection: textDirection, locale: locale, softWrap: softWrap,
    overflow: overflow, textScaler: textScaler, maxLines: maxLines,
    semanticsLabel: semanticsLabel == null ? null : AppLanguage.text(context, semanticsLabel!),
    textWidthBasis: textWidthBasis, textHeightBehavior: textHeightBehavior,
    selectionColor: selectionColor,
  );
}
