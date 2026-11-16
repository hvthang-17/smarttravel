import 'package:smarttravel_mobile/core/localization/app_language.dart';
import '../destination_display.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smarttravel_mobile/features/destination/data/models/destination_model.dart';

class DestinationDetailHeader extends StatefulWidget {
  final DestinationModel destination;

  const DestinationDetailHeader({super.key, required this.destination});

  @override
  State<DestinationDetailHeader> createState() => _DestinationDetailHeaderState();
}

class _DestinationDetailHeaderState extends State<DestinationDetailHeader> {
  late final PageController _pageController;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dest = widget.destination;
    final images = [dest.imageUrl, ...dest.subImages]
        .map(destinationImageUrl).whereType<String>().toSet().toList();
    final totalPhotos = images.length;
    final displayIndex = (totalPhotos > 0)
        ? (_currentImageIndex.clamp(0, totalPhotos - 1) + 1)
        : 0;

    return Stack(
      children: [
        // Image Carousel (Horizontal swipe right-to-left) or Fallback
        SizedBox(
          height: 320,
          width: double.infinity,
          child: images.isEmpty
              ? _buildFallbackCover(dest)
              : PageView.builder(
                  controller: _pageController,
                  itemCount: totalPhotos,
                  onPageChanged: (index) {
                    setState(() => _currentImageIndex = index);
                  },
                  itemBuilder: (context, index) {
                    final imgUrl = images[index];
                    return Image.network(
                      imgUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildFallbackCover(dest),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: const Color(0xFFE2E8F0),
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),

        // Gradient bottom shadow on image for readability
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 90,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.6),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),

        // Floating Back Button (44x44 minimum touch target & Semantics)
        Positioned(
          top: 48,
          left: 20,
          child: Semantics(
            label: 'Quay lại',
            button: true,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Material(
                color: Colors.white.withValues(alpha: 0.9),
                shape: const CircleBorder(),
                elevation: 3,
                shadowColor: Colors.black.withValues(alpha: 0.2),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/destinations');
                    }
                  },
                  child: const Center(
                    child: Icon(
                      Icons.arrow_back,
                      color: Color(0xFF0F172A),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Photo Count Tag (Real dynamic index based on swipe position)
        if (totalPhotos > 0)
          Positioned(
            bottom: 16,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.photo_camera_outlined, size: 14, color: Colors.white),
                  const SizedBox(width: 4),
                  AppText(
                    '$displayIndex/$totalPhotos ảnh',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFallbackCover(DestinationModel dest) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0077B6),
            Color(0xFF03045E),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Icon(
          dest.category.contains('Biển')
              ? Icons.beach_access
              : dest.category.contains('Văn hóa')
                  ? Icons.account_balance
                  : dest.category.contains('Ẩm thực')
                      ? Icons.restaurant
                      : Icons.landscape,
          size: 72,
          color: Colors.white.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}
