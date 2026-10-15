import 'package:flutter/material.dart';
import 'package:smarttravel_mobile/features/destination/data/models/itinerary_model.dart';

class ItineraryMapView extends StatefulWidget {
  final List<ItineraryItemModel> items;
  final ValueChanged<ItineraryItemModel>? onItemTap;

  const ItineraryMapView({
    super.key,
    required this.items,
    this.onItemTap,
  });

  @override
  State<ItineraryMapView> createState() => _ItineraryMapViewState();
}

class _ItineraryMapViewState extends State<ItineraryMapView> {
  int _selectedItemIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const Center(
        child: Text(
          'Không có điểm đến nào trong ngày này',
          style: TextStyle(color: Color(0xFF64748B)),
        ),
      );
    }

    final selectedItem = _selectedItemIndex < widget.items.length
        ? widget.items[_selectedItemIndex]
        : widget.items.first;

    return Stack(
      children: [
        // Map Canvas Area
        Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xFFE8F1F5), // Coastal water/land tint
          child: CustomPaint(
            painter: _DaNangMapPainter(
              items: widget.items,
              selectedIndex: _selectedItemIndex,
            ),
          ),
        ),

        // Interactive Markers Overlay
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: List.generate(widget.items.length, (index) {
                final it = widget.items[index];
                final isSelected = index == _selectedItemIndex;

                // Calculate relative normalized coordinates
                final pos = _calculateMarkerPosition(
                  index,
                  widget.items.length,
                  constraints.maxWidth,
                  constraints.maxHeight,
                );

                return Positioned(
                  left: pos.dx - 18,
                  top: pos.dy - 36,
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedItemIndex = index);
                      widget.onItemTap?.call(it);
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: isSelected ? 36 : 28,
                          height: isSelected ? 36 : 28,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFF77F00)
                                : const Color(0xFF0077B6),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x33000000),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        CustomPaint(
                          size: const Size(8, 6),
                          painter: _PinTrianglePainter(
                            color: isSelected
                                ? const Color(0xFFF77F00)
                                : const Color(0xFF0077B6),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            );
          },
        ),

        // Map Legend / Badge
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(230),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.map_outlined, size: 14, color: Color(0xFF0077B6)),
                SizedBox(width: 4),
                Text(
                  'Bản đồ tuyến đường Đà Nẵng',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom Stop Card Preview (Peek State)
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x180F172A),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF6F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Color(0xFF0077B6),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0077B6),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Điểm ${_selectedItemIndex + 1}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              selectedItem.destination?.name ?? 'Điểm đến',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${selectedItem.startTime ?? "08:30"} • ${selectedItem.destination?.category ?? "Tham quan"}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Offset _calculateMarkerPosition(
      int index, int total, double width, double height) {
    if (total == 1) return Offset(width * 0.5, height * 0.45);
    final t = index / (total - 1);
    // Draw an S-curve across the map suggesting coastal route
    final x = width * (0.25 + 0.5 * (1 - (2 * t - 1).abs()));
    final y = height * (0.18 + t * 0.52);
    return Offset(x, y);
  }
}

class _DaNangMapPainter extends CustomPainter {
  final List<ItineraryItemModel> items;
  final int selectedIndex;

  _DaNangMapPainter({
    required this.items,
    required this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw sea / land curve
    final coastPaint = Paint()
      ..color = const Color(0xFFD6E9F0)
      ..style = PaintingStyle.fill;

    final coastPath = Path()
      ..moveTo(size.width * 0.6, 0)
      ..quadraticBezierTo(
        size.width * 0.45,
        size.height * 0.5,
        size.width * 0.7,
        size.height,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(coastPath, coastPaint);

    // Draw route connecting lines
    if (items.length > 1) {
      final routePaint = Paint()
        ..color = const Color(0xFF0077B6).withAlpha(180)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;

      final path = Path();
      for (int i = 0; i < items.length; i++) {
        final t = i / (items.length - 1);
        final x = size.width * (0.25 + 0.5 * (1 - (2 * t - 1).abs()));
        final y = size.height * (0.18 + t * 0.52);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, routePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DaNangMapPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.items.length != items.length;
  }
}

class _PinTrianglePainter extends CustomPainter {
  final Color color;
  _PinTrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
