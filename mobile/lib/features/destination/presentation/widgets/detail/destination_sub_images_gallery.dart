import 'package:flutter/material.dart';
import 'package:smarttravel_mobile/core/theme/app_theme.dart';

class DestinationSubImagesGallery extends StatelessWidget {
  final List<String> images;

  const DestinationSubImagesGallery({super.key, required this.images});

  void _showImageDialog(BuildContext context, String imageUrl, int index) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.black54,
                  padding: const EdgeInsets.all(32),
                  child: const Text(
                    'Không thể tải ảnh',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thư viện hình ảnh',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final imgUrl = images[index];
              return InkWell(
                onTap: () => _showImageDialog(context, imgUrl, index),
                borderRadius: BorderRadius.circular(12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imgUrl,
                    width: 130,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 130,
                      height: 100,
                      color: AppTheme.surfaceSubtle,
                      child: const Icon(
                        Icons.broken_image_outlined,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
