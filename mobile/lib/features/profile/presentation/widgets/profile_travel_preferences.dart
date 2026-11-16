import 'package:smarttravel_mobile/core/localization/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarttravel_mobile/core/utils/destination_categories.dart';
import 'package:smarttravel_mobile/features/auth/data/models/traveler_profile.dart';
import 'package:smarttravel_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:smarttravel_mobile/features/auth/presentation/providers/auth_provider.dart';

class ProfileTravelPreferences extends ConsumerStatefulWidget {
  const ProfileTravelPreferences({super.key});

  @override
  ConsumerState<ProfileTravelPreferences> createState() => _ProfileTravelPreferencesState();
}

class _ProfileTravelPreferencesState extends ConsumerState<ProfileTravelPreferences> {
  final _budget = TextEditingController();
  late String _language;
  late String _pace;
  late String _transport;
  late Set<String> _categories;
  bool _saving = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(authNotifierProvider).travelerProfile ?? const TravelerProfile();
    _budget.text = profile.defaultBudgetVnd?.toString() ?? '';
    _language = profile.language;
    _pace = profile.defaultPace;
    _transport = profile.defaultTransport;
    _categories = profile.preferredCategories.toSet();
  }

  @override
  void dispose() {
    _budget.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final text = _budget.text.trim();
    final budget = int.tryParse(text);
    if (text.isNotEmpty && (budget == null || budget <= 0)) {
      setState(() => _message = 'Nhập ngân sách lớn hơn 0 hoặc để trống.');
      return;
    }
    final user = ref.read(authNotifierProvider);
    setState(() { _saving = true; _message = null; });
    try {
      await ref.read(authNotifierProvider.notifier).updateProfile(
        fullName: user.fullName ?? '',
        travelerProfile: TravelerProfile(
          language: _language, defaultBudgetVnd: budget, defaultPace: _pace,
          defaultTransport: _transport, preferredCategories: _categories.toList(),
        ),
      );
      if (mounted) setState(() => _message = 'Đã lưu tùy chọn du lịch.');
    } catch (error) {
      if (mounted) setState(() => _message = error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _select(String label, String value, Map<String, String> choices, ValueChanged<String> change) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: choices.containsKey(value) ? value : null,
      decoration: InputDecoration(label: AppText(label)),
      items: [for (final choice in choices.entries) DropdownMenuItem(value: choice.key, child: AppText(choice.value))],
      onChanged: _saving ? null : (next) { if (next != null) setState(() => change(next)); },
    );
  }

  @override
  Widget build(BuildContext context) {
    final available = ref.watch(profileCategoriesProvider);
    final activeCodes = available.valueOrNull ?? const <String>[];
    final unavailable = _categories.where((code) => !activeCodes.contains(code)).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AppText('Tùy chọn du lịch', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          _select('Ngôn ngữ ưu tiên', _language, travelerLanguages, (value) => _language = value),
          const SizedBox(height: 12),
          TextField(controller: _budget, enabled: !_saving, keyboardType: TextInputType.number,
            decoration: const InputDecoration(label: AppText('Ngân sách mặc định (VNĐ)'))),
          const SizedBox(height: 12),
          _select('Nhịp độ mặc định', _pace, travelerPaces, (value) => _pace = value),
          const SizedBox(height: 12),
          _select('Phương tiện mặc định', _transport, travelerTransports, (value) => _transport = value),
          const SizedBox(height: 16),
          const AppText('Danh mục yêu thích'),
          available.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => TextButton(onPressed: () => ref.invalidate(profileCategoriesProvider), child: const AppText('Thử tải lại danh mục')),
            data: (codes) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (codes.isEmpty) const AppText('Chưa có danh mục hoạt động.'),
              if (unavailable.isNotEmpty) const AppText('Hãy bỏ các danh mục đã ẩn hoặc mã cũ trước khi lưu.'),
              Wrap(spacing: 8, runSpacing: 4, children: [
                for (final code in [...codes, ...unavailable])
                  FilterChip(
                    label: AppText(codes.contains(code) ? categoryLabel(code) : '${categoryLabel(code)} (không khả dụng)'),
                    selected: _categories.contains(code),
                    onSelected: _saving ? null : (selected) => setState(() {
                      if (selected) { _categories.add(code); } else { _categories.remove(code); }
                    }),
                  ),
              ]),
            ]),
          ),
          if (_message != null) Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Semantics(liveRegion: true, child: AppText(_message!)),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _saving || !available.hasValue || unavailable.isNotEmpty ? null : _save,
            child: AppText(_saving ? 'Đang lưu…' : 'Lưu tùy chọn'),
          ),
        ]),
      ),
    );
  }
}
