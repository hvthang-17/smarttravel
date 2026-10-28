import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smarttravel_mobile/features/auth/data/models/user_model.dart';
import 'package:url_launcher/url_launcher.dart';

class ShareProfileBottomSheet extends StatelessWidget {
  final UserState userState;
  final Set<String> interests;

  const ShareProfileBottomSheet({
    super.key,
    required this.userState,
    required this.interests,
  });

  static Future<void> show(
    BuildContext context, {
    required UserState userState,
    required Set<String> interests,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ShareProfileBottomSheet(
        userState: userState,
        interests: interests,
      ),
    );
  }

  String get _shareUrl {
    final uid = userState.id ?? 101;
    return 'https://smarttravel.danang.vn/u/$uid';
  }

  String get _shareSummary {
    final name = userState.fullName?.isNotEmpty == true ? userState.fullName! : 'Du khách';
    final persona = userState.persona ?? 'Khách du lịch tự túc';
    final interestList = interests.isNotEmpty ? interests.join(', ') : 'Biển, Ẩm thực & Check-in Đà Nẵng';
    return '🌟 Hồ sơ du khách SmartTravel Đà Nẵng:\n'
        '• Du khách: $name\n'
        '• Phong cách: $persona\n'
        '• Sở thích: $interestList\n'
        '👉 Cùng khám phá lịch trình thông minh tại: $_shareUrl';
  }

  void _copyLink(BuildContext context) {
    Clipboard.setData(ClipboardData(text: _shareUrl));
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.link, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Đã sao chép liên kết hồ sơ du khách!'),
          ],
        ),
        backgroundColor: Color(0xFF2A9D8F),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _copySummary(BuildContext context) {
    Clipboard.setData(ClipboardData(text: _shareSummary));
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.copy_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Đã sao chép tóm tắt hồ sơ du lịch!'),
          ],
        ),
        backgroundColor: Color(0xFF0077B6),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _shareToPlatform(BuildContext context, String platform) async {
    Uri? uri;
    final encodedUrl = Uri.encodeComponent(_shareUrl);
    final encodedText = Uri.encodeComponent(_shareSummary);

    switch (platform) {
      case 'facebook':
        uri = Uri.parse('https://www.facebook.com/sharer/sharer.php?u=$encodedUrl');
        break;
      case 'telegram':
        uri = Uri.parse('https://t.me/share/url?url=$encodedUrl&text=$encodedText');
        break;
      case 'sms':
        uri = Uri(scheme: 'sms', queryParameters: {'body': _shareSummary});
        break;
      case 'zalo':
      default:
        _copyLink(context);
        return;
    }

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        _copyLink(context);
      }
    } catch (_) {
      if (context.mounted) {
        _copyLink(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = userState.fullName?.isNotEmpty == true ? userState.fullName! : 'Người dùng SmartTravel';
    final persona = userState.persona ?? 'Khách du lịch tự túc';

    final avatarPresets = [
      {'icon': Icons.person, 'color': const Color(0xFF0077B6)},
      {'icon': Icons.hiking, 'color': const Color(0xFFF77F00)},
      {'icon': Icons.camera_alt, 'color': const Color(0xFF2A9D8F)},
      {'icon': Icons.beach_access, 'color': const Color(0xFFE76F51)},
    ];
    final avatarData = avatarPresets[(userState.avatarIndex ?? 0).clamp(0, 3)];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.share_rounded, color: Color(0xFF0077B6), size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Chia sẻ hồ sơ du khách',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Travel Card Preview
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0077B6), Color(0xFF0096C7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0077B6).withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.white,
                            child: Icon(
                              avatarData['icon'] as IconData,
                              size: 28,
                              color: avatarData['color'] as Color,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.verified, size: 14, color: Colors.white70),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  persona,
                                  style: const TextStyle(
                                    color: Color(0xFFE0F2FE),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.location_on, size: 12, color: Colors.white),
                                SizedBox(width: 2),
                                Text(
                                  'Đà Nẵng',
                                  style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildCardMiniStat('3', 'Lịch trình'),
                            Container(width: 1, height: 20, color: Colors.white30),
                            _buildCardMiniStat('12', 'Điểm yêu thích'),
                            Container(width: 1, height: 20, color: Colors.white30),
                            _buildCardMiniStat('${interests.length}', 'Gu sở thích'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Link Share Field
                const Text(
                  'Liên kết hồ sơ công khai',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.link, size: 18, color: Color(0xFF0077B6)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _shareUrl,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF475569),
                            fontFamily: 'monospace',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      FilledButton(
                        onPressed: () => _copyLink(context),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF0077B6),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          visualDensity: VisualDensity.compact,
                        ),
                        child: const Text('Sao chép', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Share Channels
                const Text(
                  'Chia sẻ qua ứng dụng',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildShareChannel(
                      icon: Icons.chat_bubble_outline,
                      label: 'Zalo',
                      color: const Color(0xFF0068FF),
                      onTap: () => _copyLink(context),
                    ),
                    _buildShareChannel(
                      icon: Icons.facebook,
                      label: 'Facebook',
                      color: const Color(0xFF1877F2),
                      onTap: () => _shareToPlatform(context, 'facebook'),
                    ),
                    _buildShareChannel(
                      icon: Icons.send_rounded,
                      label: 'Telegram',
                      color: const Color(0xFF229ED9),
                      onTap: () => _shareToPlatform(context, 'telegram'),
                    ),
                    _buildShareChannel(
                      icon: Icons.sms_outlined,
                      label: 'SMS',
                      color: const Color(0xFF10B981),
                      onTap: () => _shareToPlatform(context, 'sms'),
                    ),
                    _buildShareChannel(
                      icon: Icons.copy_all_rounded,
                      label: 'Tóm tắt',
                      color: const Color(0xFFF77F00),
                      onTap: () => _copySummary(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildCardMiniStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        Text(
          label,
          style: const TextStyle(color: Color(0xFFE0F2FE), fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildShareChannel({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.2)),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF475569)),
            ),
          ],
        ),
      ),
    );
  }
}
