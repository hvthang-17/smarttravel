import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarttravel_mobile/core/network/api_client.dart';
import 'package:smarttravel_mobile/core/theme/app_theme.dart';

class InterestPreferenceItem {
  final String label;
  final IconData icon;

  const InterestPreferenceItem({required this.label, required this.icon});
}

const List<InterestPreferenceItem> availableInterests = [
  InterestPreferenceItem(label: 'Biển & Nghỉ dưỡng', icon: Icons.beach_access),
  InterestPreferenceItem(label: 'Ẩm thực đường phố', icon: Icons.restaurant),
  InterestPreferenceItem(label: 'Check-in & Sống ảo', icon: Icons.camera_alt_outlined),
  InterestPreferenceItem(label: 'Văn hóa & Lịch sử', icon: Icons.museum_outlined),
  InterestPreferenceItem(label: 'Thiên nhiên & Sinh thái', icon: Icons.park_outlined),
  InterestPreferenceItem(label: 'Cà phê chill phố biển', icon: Icons.coffee_outlined),
];

class ProfileTravelPreferences extends ConsumerStatefulWidget {
  final Set<String> initialInterests;
  final Function(Set<String>) onInterestsChanged;

  const ProfileTravelPreferences({
    super.key,
    required this.initialInterests,
    required this.onInterestsChanged,
  });

  @override
  ConsumerState<ProfileTravelPreferences> createState() => _ProfileTravelPreferencesState();
}

class _ProfileTravelPreferencesState extends ConsumerState<ProfileTravelPreferences> {
  late Set<String> _selectedInterests;
  int _selectedPace = 1;
  int _selectedVehicle = 0;

  @override
  void initState() {
    super.initState();
    _selectedInterests = Set.from(widget.initialInterests);
    _loadSavedPreferences();
  }

  Future<void> _loadSavedPreferences() async {
    try {
      final storage = ref.read(secureStorageProvider);
      final savedInterests = await storage.read(key: 'pref_interests');
      final savedPace = await storage.read(key: 'pref_pace');
      final savedVehicle = await storage.read(key: 'pref_vehicle');

      if (mounted) {
        setState(() {
          if (savedInterests != null && savedInterests.isNotEmpty) {
            _selectedInterests = savedInterests.split(',').where((s) => s.isNotEmpty).toSet();
            widget.onInterestsChanged(_selectedInterests);
          }
          if (savedPace != null) _selectedPace = int.tryParse(savedPace) ?? 1;
          if (savedVehicle != null) _selectedVehicle = int.tryParse(savedVehicle) ?? 0;
        });
      }
    } catch (_) {}
  }

  Future<void> _savePreferences() async {
    final storage = ref.read(secureStorageProvider);
    await storage.write(key: 'pref_interests', value: _selectedInterests.join(','));
    await storage.write(key: 'pref_pace', value: _selectedPace.toString());
    await storage.write(key: 'pref_vehicle', value: _selectedVehicle.toString());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã lưu tùy chọn & sở thích du lịch thành công!'),
          backgroundColor: AppTheme.statusSuccess,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.auto_awesome, size: 18, color: AppTheme.primaryBlue),
                SizedBox(width: 6),
                Text('Sở thích trải nghiệm Đà Nẵng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(10)),
              child: Text('${_selectedInterests.length}/6 đã chọn', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Trí tuệ nhân tạo sẽ ưu tiên sắp xếp các điểm đến và cung đường theo gu du lịch riêng của bạn.',
          style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableInterests.map(_buildInterestChip).toList(),
        ),
        const SizedBox(height: 24),
        const Row(
          children: [
            Icon(Icons.speed_outlined, size: 18, color: AppTheme.primaryBlue),
            SizedBox(width: 6),
            Text('Phong cách & Nhịp độ chuyến đi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.borderSubtle)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nhịp độ tham quan mặc định', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildPaceOption(0, 'Thư thả', '2-3 điểm/ngày'),
                  const SizedBox(width: 8),
                  _buildPaceOption(1, 'Cân bằng', '3-4 điểm/ngày'),
                  const SizedBox(width: 8),
                  _buildPaceOption(2, 'Dày đặc', '4-5 điểm/ngày'),
                ],
              ),
              const Divider(height: 28, color: AppTheme.surfaceSubtle),
              const Text('Phương tiện di chuyển chính', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildVehicleOption(0, Icons.two_wheeler, 'Xe máy / Grab'),
                  const SizedBox(width: 8),
                  _buildVehicleOption(1, Icons.directions_car, 'Ô tô riêng'),
                  const SizedBox(width: 8),
                  _buildVehicleOption(2, Icons.directions_walk, 'Đi bộ dạo phố'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _savePreferences,
          icon: const Icon(Icons.auto_fix_high),
          label: const Text('Lưu sở thích & Tối ưu lộ trình'),
        ),
      ],
    );
  }

  Widget _buildInterestChip(InterestPreferenceItem item) {
    final isSelected = _selectedInterests.contains(item.label);
    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedInterests.remove(item.label);
          } else {
            _selectedInterests.add(item.label);
          }
        });
        widget.onInterestsChanged(_selectedInterests);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppTheme.primaryBlue : AppTheme.borderSubtle),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              size: 16,
              color: isSelected ? Colors.white : AppTheme.primaryBlue,
            ),
            const SizedBox(width: 6),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(isSelected ? Icons.check : Icons.add, size: 14, color: isSelected ? Colors.white : const Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  Widget _buildPaceOption(int index, String title, String sub) {
    final isSelected = _selectedPace == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedPace = index),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE0F2FE) : AppTheme.bgCanvas,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? AppTheme.primaryBlue : AppTheme.borderSubtle),
          ),
          child: Column(
            children: [
              Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isSelected ? AppTheme.primaryBlue : AppTheme.textPrimary)),
              const SizedBox(height: 2),
              Text(sub, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleOption(int index, IconData icon, String title) {
    final isSelected = _selectedVehicle == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedVehicle = index),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE0F2FE) : AppTheme.bgCanvas,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? AppTheme.primaryBlue : AppTheme.borderSubtle),
          ),
          child: Column(
            children: [
              Icon(icon, size: 22, color: isSelected ? AppTheme.primaryBlue : AppTheme.textMuted),
              const SizedBox(height: 6),
              Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isSelected ? AppTheme.primaryBlue : AppTheme.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }
}
