import 'package:flutter/material.dart';

class SocialLoginButtons extends StatelessWidget {
  final ValueChanged<String> onSelectProvider;

  const SocialLoginButtons({super.key, required this.onSelectProvider});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text('Hoặc đăng nhập bằng', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
            ),
            const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => onSelectProvider('Google'),
                icon: const Icon(Icons.g_mobiledata, color: Color(0xFFEA4335), size: 24),
                label: const Text('Google', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => onSelectProvider('Apple'),
                icon: const Icon(Icons.apple, color: Colors.black, size: 22),
                label: const Text('Apple', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
