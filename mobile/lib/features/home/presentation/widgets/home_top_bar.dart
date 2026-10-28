import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smarttravel_mobile/core/theme/app_theme.dart';

class HomeTopBar extends StatelessWidget {
  final String userName;
  final bool isAuthenticated;

  const HomeTopBar({
    super.key,
    required this.userName,
    required this.isAuthenticated,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.explore,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  children: [
                    TextSpan(
                      text: 'Smart',
                      style: TextStyle(color: AppTheme.primaryBlue),
                    ),
                    TextSpan(text: 'Travel'),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              Semantics(
                label: 'Thông báo',
                button: true,
                child: IconButton(
                  icon: const Icon(
                    Icons.notifications_none_outlined,
                    color: AppTheme.textPrimary,
                    size: 26,
                  ),
                  tooltip: 'Thông báo',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Không có thông báo mới.'),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: () {
                  if (!isAuthenticated) {
                    context.push('/login');
                  } else {
                    context.push('/profile');
                  }
                },
                borderRadius: BorderRadius.circular(20),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.primaryBlue,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'M',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
