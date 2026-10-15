import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smarttravel_mobile/features/destination/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final Set<String> _selectedInterests = {
    'Biển & Nghỉ dưỡng',
    'Ẩm thực đường phố',
    'Check-in & Sống ảo',
  };

  int _selectedPace = 1; // 0 = Thư thả, 1 = Cân bằng, 2 = Dày đặc
  int _selectedVehicle = 0; // 0 = Xe máy, 1 = Ô tô, 2 = Đi bộ
  bool _weatherAlert = true;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final name = authState.fullName?.isNotEmpty == true ? authState.fullName! : 'Minh Nguyễn';
    final email = authState.email?.isNotEmpty == true ? authState.email! : 'minh.nguyen@example.com';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // User Profile Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Stack(
                      children: [
                        const CircleAvatar(
                          radius: 36,
                          backgroundColor: Color(0xFFE0F2FE),
                          child: Icon(
                            Icons.person,
                            size: 42,
                            color: Color(0xFF0077B6),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: Color(0xFF0077B6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified,
                                size: 16,
                                color: Color(0xFF0077B6),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            email,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2FE),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Khách du lịch tự túc',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0284C7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {},
                        icon: const Icon(Icons.edit, size: 16, color: Color(0xFF0F172A)),
                        label: const Text(
                          'Chỉnh sửa hồ sơ',
                          style: TextStyle(color: Color(0xFF0F172A), fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {},
                        icon: const Icon(Icons.share_outlined, size: 16, color: Color(0xFF0F172A)),
                        label: const Text(
                          'Chia sẻ',
                          style: TextStyle(color: Color(0xFF0F172A), fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Stats Row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('3', 'Lịch trình đã tạo', const Color(0xFF0077B6)),
                Container(height: 32, width: 1, color: const Color(0xFFE2E8F0)),
                _buildStatItem('2', 'Chuyến đi xong', const Color(0xFF0F172A)),
                Container(height: 32, width: 1, color: const Color(0xFFE2E8F0)),
                _buildStatItem('12', 'Điểm yêu thích', const Color(0xFFF77F00)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Sở thích trải nghiệm Đà Nẵng
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_awesome, size: 18, color: Color(0xFF0077B6)),
                  SizedBox(width: 6),
                  Text(
                    'Sở thích trải nghiệm Đà Nẵng',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_selectedInterests.length}/6 đã chọn',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0284C7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Trí tuệ nhân tạo sẽ ưu tiên sắp xếp các điểm đến và cung đường theo gu du lịch riêng của bạn.',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildInterestChip('🏖️ Biển & Nghỉ dưỡng'),
              _buildInterestChip('🍜 Ẩm thực đường phố'),
              _buildInterestChip('📸 Check-in & Sống ảo'),
              _buildInterestChip('🏛️ Văn hóa & Di sản'),
              _buildInterestChip('🌿 Thiên nhiên & Sơn Trà'),
              _buildInterestChip('🎆 Chợ đêm & Cầu Rồng'),
            ],
          ),
          const SizedBox(height: 24),

          // Cài đặt lập kế hoạch mặc định
          const Row(
            children: [
              Icon(Icons.tune, size: 18, color: Color(0xFF0077B6)),
              SizedBox(width: 6),
              Text(
                'Cài đặt lập kế hoạch mặc định',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nhịp độ di chuyển mặc định',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
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
                const Divider(height: 28, color: Color(0xFFF1F5F9)),
                const Text(
                  'Phương tiện di chuyển chính',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
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
          const SizedBox(height: 24),

          // Tài khoản & Cài đặt
          const Row(
            children: [
              Icon(Icons.manage_accounts_outlined, size: 18, color: Color(0xFF0077B6)),
              SizedBox(width: 6),
              Text(
                'Tài khoản & Cài đặt',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.bookmark_border, color: Color(0xFF0077B6)),
                  ),
                  title: const Text('Địa điểm đã lưu', style: TextStyle(fontWeight: FontWeight.w500)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEDD5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('12 địa điểm', style: TextStyle(fontSize: 12, color: Color(0xFFC2410C))),
                  ),
                  onTap: () => context.push('/destinations'),
                ),
                const Divider(height: 1, indent: 64, color: Color(0xFFF1F5F9)),
                SwitchListTile(
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.cloud_outlined, color: Color(0xFF0077B6)),
                  ),
                  title: const Text('Cảnh báo thời tiết & mưa', style: TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: const Text('Thông báo trước 1 giờ khi trời chuyển mưa', style: TextStyle(fontSize: 12)),
                  value: _weatherAlert,
                  activeThumbColor: const Color(0xFF0077B6),
                  onChanged: (val) => setState(() => _weatherAlert = val),
                ),
                const Divider(height: 1, indent: 64, color: Color(0xFFF1F5F9)),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.support_agent, color: Color(0xFF64748B)),
                  ),
                  title: const Text('Trợ giúp & Góp ý du khách', style: TextStyle(fontWeight: FontWeight.w500)),
                  trailing: const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 64, color: Color(0xFFF1F5F9)),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.logout, color: Color(0xFFEF4444)),
                  ),
                  title: const Text('Đăng xuất tài khoản', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w500)),
                  trailing: const Icon(Icons.chevron_right, color: Color(0xFFEF4444)),
                  onTap: () async {
                    await ref.read(authNotifierProvider.notifier).logout();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF0077B6),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã cập nhật sở thích & cấu hình!'),
                  backgroundColor: Color(0xFF2A9D8F),
                ),
              );
            },
            icon: const Icon(Icons.auto_fix_high),
            label: const Text('Lưu sở thích & Tối ưu lộ trình'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStatItem(String number, String label, Color numColor) {
    return Column(
      children: [
        Text(
          number,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: numColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
      ],
    );
  }

  Widget _buildInterestChip(String name) {
    final isSelected = _selectedInterests.contains(name.replaceAll(RegExp(r'^[^\s]+\s'), ''));
    final plainName = name.replaceAll(RegExp(r'^[^\s]+\s'), '');
    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedInterests.remove(plainName);
          } else {
            _selectedInterests.add(plainName);
          }
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0077B6) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF0077B6) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              isSelected ? Icons.check : Icons.add,
              size: 14,
              color: isSelected ? Colors.white : const Color(0xFF94A3B8),
            ),
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
            color: isSelected ? const Color(0xFFE0F2FE) : const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? const Color(0xFF0077B6) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? const Color(0xFF0077B6) : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sub,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
              ),
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
            color: isSelected ? const Color(0xFFE0F2FE) : const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? const Color(0xFF0077B6) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected ? const Color(0xFF0077B6) : const Color(0xFF64748B),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? const Color(0xFF0077B6) : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
