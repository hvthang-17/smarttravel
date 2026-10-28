import 'package:flutter/material.dart';
import 'package:smarttravel_mobile/features/auth/data/models/user_model.dart';
import 'package:smarttravel_mobile/features/profile/presentation/widgets/edit_profile_dialog.dart';
import 'package:smarttravel_mobile/features/profile/presentation/widgets/share_profile_dialog.dart';

class ProfileHeaderCard extends StatelessWidget {
  final UserState authState;
  final Set<String> selectedInterests;

  const ProfileHeaderCard({
    super.key,
    required this.authState,
    required this.selectedInterests,
  });

  @override
  Widget build(BuildContext context) {
    final String name = authState.fullName?.isNotEmpty == true ? authState.fullName! : 'Người dùng';
    final String email = authState.email?.isNotEmpty == true ? authState.email! : 'user@example.com';
    final String persona = authState.persona?.isNotEmpty == true ? authState.persona! : 'Khách du lịch tự túc';

    final avatarPresets = [
      {'icon': Icons.person, 'color': const Color(0xFF0077B6)},
      {'icon': Icons.hiking, 'color': const Color(0xFFF77F00)},
      {'icon': Icons.camera_alt, 'color': const Color(0xFF2A9D8F)},
      {'icon': Icons.beach_access, 'color': const Color(0xFFE76F51)},
    ];
    final avatarData = avatarPresets[(authState.avatarIndex ?? 0).clamp(0, 3)];
    final IconData avatarIcon = avatarData['icon'] as IconData;
    final Color avatarColor = avatarData['color'] as Color;

    return Container(
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
              Semantics(
                label: 'Thay đổi ảnh đại diện',
                button: true,
                child: GestureDetector(
                  onTap: () => EditProfileBottomSheet.show(context, authState),
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: avatarColor.withValues(alpha: 0.15),
                        child: Icon(avatarIcon, size: 38, color: avatarColor),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(color: avatarColor, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
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
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.verified, size: 16, color: Color(0xFF0077B6)),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(email, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        persona,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF0284C7)),
                      ),
                    ),
                    if (authState.bio != null && authState.bio!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        authState.bio!,
                        style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Color(0xFF64748B)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => EditProfileBottomSheet.show(context, authState),
                  icon: const Icon(Icons.edit, size: 16, color: Color(0xFF0F172A)),
                  label: const Text('Chỉnh sửa', style: TextStyle(color: Color(0xFF0F172A), fontSize: 13)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => ShareProfileBottomSheet.show(
                    context,
                    userState: authState,
                    interests: selectedInterests,
                  ),
                  icon: const Icon(Icons.share_outlined, size: 16, color: Color(0xFF0F172A)),
                  label: const Text('Chia sẻ', style: TextStyle(color: Color(0xFF0F172A), fontSize: 13)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
