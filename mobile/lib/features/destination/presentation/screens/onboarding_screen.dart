import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = const [
    OnboardingData(
      title: 'Khám phá Đà Nẵng theo cách của bạn',
      description:
          'Nhập sở thích, ngân sách và số ngày. Hệ thống tạo lịch trình phù hợp ngay lập tức.',
      imagePath: 'assets/images/illustration_step1.png',
      fallbackIcon: Icons.map_outlined,
      iconBgColor: Color(0xFFEDF6F9),
      iconColor: Color(0xFF0077B6),
      buttonText: 'Tiếp tục',
      buttonColor: Color(0xFF0077B6),
    ),
    OnboardingData(
      title: 'Chi phí minh bạch, tuyến đường thực tế',
      description:
          'Xem ước tính chi phí theo ngày, quãng đường di chuyển và thời gian giữa các điểm trên bản đồ.',
      imagePath: 'assets/images/illustration_step2.png',
      fallbackIcon: Icons.timeline_outlined,
      iconBgColor: Color(0xFFFFF3E0),
      iconColor: Color(0xFFF77F00),
      buttonText: 'Bắt đầu ngay',
      buttonColor: Color(0xFFF77F00),
    ),
  ];

  void _onButtonPressed() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/');
    }
  }

  void _onSkipPressed() {
    context.go('/');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar with "Bỏ qua" (Skip) action
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48), // Balancer
                  TextButton(
                    onPressed: _onSkipPressed,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF64748B),
                      splashFactory: NoSplash.splashFactory,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    child: const Text(
                      'Bỏ qua',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Page View Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const Spacer(flex: 2),

                        // Center Illustration
                        Center(
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              color: page.iconBgColor,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Image.asset(
                                page.imagePath,
                                width: 96,
                                height: 96,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    page.fallbackIcon,
                                    size: 56,
                                    color: page.iconColor,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),

                        const Spacer(flex: 2),

                        // Headline Title
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Body Description
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 290),
                          child: Text(
                            page.description,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF475569),
                              height: 1.5,
                            ),
                          ),
                        ),

                        const Spacer(flex: 3),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation Indicators & Full-width Button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dot Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 20 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFF0077B6)
                              : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 28),

                  // Bottom Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _onButtonPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _pages[_currentPage].buttonColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        _pages[_currentPage].buttonText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final String imagePath;
  final IconData fallbackIcon;
  final Color iconBgColor;
  final Color iconColor;
  final String buttonText;
  final Color buttonColor;

  const OnboardingData({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.fallbackIcon,
    required this.iconBgColor,
    required this.iconColor,
    required this.buttonText,
    required this.buttonColor,
  });
}
