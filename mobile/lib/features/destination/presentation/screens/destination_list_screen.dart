import 'package:smarttravel_mobile/core/localization/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarttravel_mobile/features/auth/presentation/providers/auth_provider.dart';
import '../../data/models/discovery_models.dart';
import '../providers/destination_provider.dart';
import '../widgets/destination_result_tile.dart';

class DestinationListScreen extends ConsumerStatefulWidget {
  const DestinationListScreen(
      {super.key, this.initialSearch = '', this.initialCategory});
  final String initialSearch;
  final String? initialCategory;

  @override
  ConsumerState<DestinationListScreen> createState() =>
      _DestinationListScreenState();
}

class _DestinationListScreenState extends ConsumerState<DestinationListScreen> {
  late final _search = TextEditingController(text: widget.initialSearch);
  final _min = TextEditingController();
  final _max = TextEditingController();
  final _form = GlobalKey<FormState>();
  late String? _category = widget.initialCategory;
  late DiscoveryQuery _query = (
    search: widget.initialSearch,
    category: widget.initialCategory,
    minPrice: null,
    maxPrice: null,
    page: 0
  );

  @override
  void dispose() {
    _search.dispose();
    _min.dispose();
    _max.dispose();
    super.dispose();
  }

  String? _priceError(String? raw) {
    final text = raw?.trim() ?? '';
    if (text.isEmpty) return null;
    final value = int.tryParse(text);
    return value == null || value < 0 ? 'Nhập số tiền từ 0 đ' : null;
  }

  void _apply(String? codes) {
    if (_form.currentState?.validate() != true) return;
    FocusScope.of(context).unfocus();
    setState(() => _query = (
          search: _search.text.trim(),
          category: codes,
          minPrice: int.tryParse(_min.text.trim()),
          maxPrice: int.tryParse(_max.text.trim()),
          page: 0,
        ));
  }

  void _openPage(int page) {
    setState(() => _query = (
          search: _query.search,
          category: _query.category,
          minPrice: _query.minPrice,
          maxPrice: _query.maxPrice,
          page: page
        ));
  }

  @override
  Widget build(BuildContext context) {
    final profile =
        ref.watch(authNotifierProvider.select((user) => user.travelerProfile));
    final language = profile?.language ?? 'vi';
    final catalog = ref.watch(destinationCatalogProvider);
    final categories = catalog.valueOrNull ?? const <DestinationCategory>[];
    final interests = categories
        .where((category) =>
            profile?.preferredCategories.contains(category.code) == true)
        .map((category) => category.code)
        .toList();
    final options = {
      '': 'Tất cả danh mục',
      if (interests.isNotEmpty) 'interests': 'Danh mục yêu thích của tôi',
      for (final category in categories)
        category.code: category.label(language),
    };
    final dropdown = options.containsKey(_category) ? _category! : '';
    String? codes() => _category == 'interests'
        ? (interests.isEmpty ? null : interests.join(','))
        : _category;
    final results = ref.watch(discoveryProvider(_query));

    return Scaffold(
      appBar: AppBar(title: const AppText('Khám phá địa điểm')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Form(
            key: _form,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _search,
                    maxLength: 180,
                    textInputAction: TextInputAction.search,
                    onFieldSubmitted: (_) => _apply(codes()),
                    decoration: const InputDecoration(
                        label: AppText('Tên địa điểm'),
                        prefixIcon: Icon(Icons.search),
                        counterText: ''),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    key: ValueKey(dropdown),
                    isExpanded: true,
                    initialValue: dropdown,
                    decoration: const InputDecoration(label: AppText('Danh mục')),
                    items: [
                      for (final entry in options.entries)
                        DropdownMenuItem(
                            value: entry.key,
                            child: AppText(entry.value,
                                overflow: TextOverflow.ellipsis))
                    ],
                    onChanged: catalog.hasValue
                        ? (value) => setState(
                            () => _category = value == '' ? null : value)
                        : null,
                  ),
                  if (catalog.hasError)
                    TextButton(
                        onPressed: () =>
                            ref.invalidate(destinationCatalogProvider),
                        child: const AppText('Thử tải lại danh mục')),
                  const SizedBox(height: 12),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(
                        child: TextFormField(
                            controller: _min,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                label: AppText('Giá từ (đ/người)')),
                            validator: _priceError)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: TextFormField(
                            controller: _max,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                label: AppText('Giá đến (đ/người)')),
                            validator: (value) {
                              final error = _priceError(value);
                              if (error != null) return error;
                              final low = int.tryParse(_min.text.trim());
                              final high = int.tryParse(value?.trim() ?? '');
                              return low != null && high != null && high < low
                                  ? 'Thấp hơn giá từ'
                                  : null;
                            })),
                  ]),
                  if (_query.minPrice != null || _query.maxPrice != null)
                    const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: AppText(
                            'Đang lọc theo giá. Kết quả bỏ qua địa điểm chưa có giá tham khảo.')),
                  const SizedBox(height: 12),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    FilledButton(
                        onPressed: () => _apply(codes()),
                        child: const AppText('Áp dụng bộ lọc')),
                    TextButton(
                        onPressed: () {
                          _search.clear();
                          _min.clear();
                          _max.clear();
                          setState(() => _category = null);
                          _apply(null);
                        },
                        child: const AppText('Xóa bộ lọc')),
                  ]),
                ]),
          ),
          const SizedBox(height: 16),
          ...results.when(
            skipLoadingOnRefresh: false,
            loading: () => <Widget>[const LinearProgressIndicator()],
            error: (_, __) => <Widget>[
              const AppText('Không tải được địa điểm.'),
              TextButton(
                  onPressed: () => ref.invalidate(discoveryProvider(_query)),
                  child: const AppText('Thử lại')),
            ],
            data: (page) => <Widget>[
              if (page.items.isEmpty)
                const AppText('Không có địa điểm khớp với bộ lọc.'),
              for (final item in page.items)
                DestinationResultTile(destination: item, language: language),
              if (_query.page > 0 || page.hasNext)
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          tooltip: AppLanguage.text(context, 'Trang trước'),
                          onPressed: _query.page == 0
                              ? null
                              : () => _openPage(_query.page - 1),
                          icon: const Icon(Icons.chevron_left)),
                      AppText('Trang ${_query.page + 1}'),
                      IconButton(
                          tooltip: AppLanguage.text(context, 'Trang tiếp'),
                          onPressed: page.hasNext
                              ? () => _openPage(_query.page + 1)
                              : null,
                          icon: const Icon(Icons.chevron_right)),
                    ]),
            ],
          ),
        ],
      ),
    );
  }
}
