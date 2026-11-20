import 'package:smarttravel_mobile/core/localization/app_language.dart';
import 'package:flutter/material.dart';
import 'package:smarttravel_mobile/features/itinerary/data/models/itinerary_model.dart';

Future<ItineraryResponseModel?> resolveItineraryConflict(BuildContext context,
    Future<ItineraryResponseModel?> Function() loadLatest) async {
  final reload = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
    title: const AppText('Lịch trình đã thay đổi'),
    content: const AppText('Bản sửa hiện tại vẫn được giữ. Bạn có thể tiếp tục xem bản sửa hoặc tải bản mới từ máy chủ.'),
    actions: [
      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const AppText('Giữ bản sửa')),
      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const AppText('Xem bản mới')),
    ],
  ));
  if (reload != true || !context.mounted) return null;
  try {
    final latest = await loadLatest();
    if (!context.mounted) return null;
    if (latest == null) throw StateError('Không tìm thấy lịch trình');
    final discard = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const AppText('Bản mới từ máy chủ'),
      content: AppText('${latest.title}, phiên bản ${latest.version}. Tải lại sẽ bỏ bản sửa cục bộ. Bạn có muốn thay thế?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const AppText('Giữ bản sửa')),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const AppText('Bỏ bản sửa và tải lại')),
      ],
    ));
    return discard == true ? latest : null;
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: AppText('Không tải được bản mới. Bản sửa vẫn được giữ.')));
    }
    return null;
  }
}
