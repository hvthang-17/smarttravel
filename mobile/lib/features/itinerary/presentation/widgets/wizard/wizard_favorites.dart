import 'package:smarttravel_mobile/core/localization/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarttravel_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:smarttravel_mobile/features/destination/presentation/providers/favorite_provider.dart';
import 'package:smarttravel_mobile/features/destination/presentation/widgets/destination_display.dart';

class WizardFavorites extends ConsumerWidget {
  const WizardFavorites({
    super.key,
    required this.selected,
    required this.capacity,
    this.excluded = const {},
    required this.onChange,
  });

  final Set<int> selected;
  final int capacity;
  final Set<int> excluded;
  final ValueChanged<Set<int>> onChange;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider);
    if (!user.isAuthenticated) return const SizedBox.shrink();
    final favorites = ref.watch(favoritesProvider);
    final reload = ref.read(favoritesProvider.notifier).reload;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AppText('Điểm đã lưu', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      AppText(
          'Chọn điểm muốn đưa vào lịch trình. Đã chọn ${selected.length}/$capacity.'),
      favorites.when(
        loading: () => const LinearProgressIndicator(),
        error: (_, __) => TextButton(
            onPressed: reload, child: const AppText('Tải lại điểm đã lưu')),
        data: (items) {
          final visibleIds = items.map((item) => item.id).toSet();
          final unavailable =
              selected.where((id) => !visibleIds.contains(id)).toSet();
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (items.isEmpty)
                  const AppText('Chưa có điểm đã lưu đang hiển thị.'),
                if (unavailable.isNotEmpty)
                  TextButton(
                    onPressed: () => onChange(selected.difference(unavailable)),
                    child: const AppText('Bỏ các điểm không còn khả dụng'),
                  ),
                for (final item in items)
                  if (item.id != null && !excluded.contains(item.id))
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(destinationName(
                          item, user.travelerProfile?.language ?? 'vi')),
                      value: selected.contains(item.id),
                      onChanged: selected.length >= capacity &&
                              !selected.contains(item.id)
                          ? null
                          : (enabled) {
                              final next = {...selected};
                              if (enabled == true) {
                                next.add(item.id!);
                              } else {
                                next.remove(item.id);
                              }
                              onChange(next);
                            },
                    ),
              ]);
        },
      ),
    ]);
  }
}
