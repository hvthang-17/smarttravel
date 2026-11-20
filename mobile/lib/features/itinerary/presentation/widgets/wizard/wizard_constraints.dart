import 'package:smarttravel_mobile/core/localization/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarttravel_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:smarttravel_mobile/features/destination/data/models/destination_model.dart';
import 'package:smarttravel_mobile/features/destination/data/models/discovery_models.dart';
import 'package:smarttravel_mobile/features/destination/presentation/providers/destination_provider.dart';
import 'package:smarttravel_mobile/features/destination/presentation/providers/favorite_provider.dart';
import 'package:smarttravel_mobile/features/destination/presentation/widgets/destination_display.dart';

class WizardConstraints extends ConsumerWidget {
  const WizardConstraints({
    super.key,
    required this.requiredPoints,
    required this.excludedPoints,
    required this.favoriteIds,
    required this.onPick,
    required this.onRemove,
  });

  final List<DestinationModel> requiredPoints;
  final List<DestinationModel> excludedPoints;
  final Set<int> favoriteIds;
  final void Function(bool required, DestinationModel destination) onPick;
  final void Function(bool required, int id) onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(authNotifierProvider.select((user) => user.travelerProfile?.language)) ?? 'vi';
    Future<void> pick(bool required) async {
      final blocked = {
        ...requiredPoints.map((point) => point.id),
        ...excludedPoints.map((point) => point.id),
        if (!required) ...favoriteIds,
      };
      final result = await showDialog<DestinationModel>(
        context: context,
        builder: (_) => _ConstraintPicker(required: required, blocked: blocked, language: language),
      );
      if (result != null && context.mounted) onPick(required, result);
    }

    Widget group(bool required, List<DestinationModel> points) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(required ? 'Điểm bắt buộc' : 'Điểm muốn bỏ qua',
          style: Theme.of(context).textTheme.titleSmall),
        Wrap(spacing: 8, runSpacing: 4, children: [
          for (final point in points)
            InputChip(label: Text(destinationName(point, language)),
              onDeleted: () => onRemove(required, point.id!)),
        ]),
        TextButton.icon(
          onPressed: points.length < 5 ? () => pick(required) : null,
          icon: const Icon(Icons.add),
          label: AppText('Chọn địa điểm (${points.length}/5)'),
        ),
      ],
    );

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      group(true, requiredPoints),
      const SizedBox(height: 12),
      group(false, excludedPoints),
    ]);
  }
}

class _ConstraintPicker extends ConsumerStatefulWidget {
  const _ConstraintPicker({required this.required, required this.blocked, required this.language});
  final bool required;
  final Set<int?> blocked;
  final String language;

  @override
  ConsumerState<_ConstraintPicker> createState() => _ConstraintPickerState();
}

class _ConstraintPickerState extends ConsumerState<_ConstraintPicker> {
  final _search = TextEditingController();
  String _term = '';
  int _page = 0;
  bool _saved = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = (search: _term, category: null, minPrice: null, maxPrice: null, page: _page) as DiscoveryQuery;
    final AsyncValue<DiscoveryPage> results = _saved
        ? ref.watch(favoritesProvider).whenData((items) => DiscoveryPage(
            items.where((point) => destinationName(point, widget.language).toLowerCase().contains(_term.toLowerCase())).toList(), false))
        : ref.watch(discoveryProvider(query));
    void search() => setState(() { _term = _search.text.trim(); _page = 0; });

    return AlertDialog(
      title: AppText(widget.required ? 'Chọn điểm bắt buộc' : 'Chọn điểm muốn bỏ qua'),
      content: SizedBox(
        width: 420,
        height: 430,
        child: Column(children: [
          Wrap(spacing: 8, children: [
            ChoiceChip(label: const AppText('Catalog'), selected: !_saved,
              onSelected: (_) => setState(() { _saved = false; _page = 0; })),
            ChoiceChip(label: const AppText('Đã lưu'), selected: _saved,
              onSelected: (_) => setState(() { _saved = true; _page = 0; })),
          ]),
          TextField(controller: _search, maxLength: 180, textInputAction: TextInputAction.search,
            onSubmitted: (_) => search(),
            decoration: InputDecoration(label: const AppText('Tìm địa điểm'), counterText: '',
              suffixIcon: IconButton(onPressed: search, icon: const Icon(Icons.search), tooltip: AppLanguage.text(context, 'Tìm')))),
          const SizedBox(height: 8),
          Expanded(child: results.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => Center(child: TextButton(
              onPressed: () {
                if (_saved) {
                  ref.read(favoritesProvider.notifier).reload();
                } else {
                  ref.invalidate(discoveryProvider(query));
                }
              },
              child: const AppText('Không tải được địa điểm. Thử lại'),
            )),
            data: (page) {
              final points = page.items.where((point) => point.id != null).toList();
              return Column(children: [
                Expanded(child: points.isEmpty ? const Center(child: AppText('Không có địa điểm phù hợp.')) :
                  ListView.builder(itemCount: points.length, itemBuilder: (context, index) {
                    final point = points[index];
                    final blocked = widget.blocked.contains(point.id);
                    return ListTile(contentPadding: EdgeInsets.zero,
                      title: Text(destinationName(point, widget.language)),
                      subtitle: AppText(blocked ? 'Đã chọn' : destinationCategoryName(point, widget.language)),
                      enabled: !blocked,
                      onTap: blocked ? null : () => Navigator.of(context).pop(point));
                  })),
                if (!_saved && (_page > 0 || page.hasNext))
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    IconButton(tooltip: AppLanguage.text(context, 'Trang trước'), onPressed: _page == 0 ? null : () => setState(() => _page--),
                      icon: const Icon(Icons.chevron_left)),
                    AppText('Trang ${_page + 1}'),
                    IconButton(tooltip: AppLanguage.text(context, 'Trang tiếp'), onPressed: page.hasNext ? () => setState(() => _page++) : null,
                      icon: const Icon(Icons.chevron_right)),
                  ]),
              ]);
            },
          )),
        ]),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const AppText('Đóng'))],
    );
  }
}
