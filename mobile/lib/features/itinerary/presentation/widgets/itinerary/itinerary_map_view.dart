import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:smarttravel_mobile/features/itinerary/data/models/itinerary_model.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final MapController _mapController = MapController();

  static const LatLng _daNangCenter = LatLng(16.0544, 108.2022);

  @override
  void didUpdateWidget(covariant ItineraryMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      if (_selectedItemIndex >= widget.items.length) {
        _selectedItemIndex = 0;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fitBounds();
      });
    }
  }

  bool _isValidCoordinate(double? lat, double? lng) {
    if (lat == null || lng == null) return false;
    if (lat == 0.0 && lng == 0.0) return false;
    return lat >= -90.0 && lat <= 90.0 && lng >= -180.0 && lng <= 180.0;
  }

  List<LatLng> _extractValidCoordinates() {
    final List<LatLng> points = [];
    for (final item in widget.items) {
      final dest = item.destination;
      if (dest != null && _isValidCoordinate(dest.latitude, dest.longitude)) {
        points.add(LatLng(dest.latitude, dest.longitude));
      }
    }
    return points;
  }

  void _fitBounds() {
    final points = _extractValidCoordinates();
    if (points.isEmpty) {
      _mapController.move(_daNangCenter, 12.0);
      return;
    }
    if (points.length == 1) {
      _mapController.move(points.first, 14.5);
      return;
    }

    final bounds = LatLngBounds.fromPoints(points);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.fromLTRB(40, 60, 40, 160),
      ),
    );
  }

  Future<void> _openGoogleMaps(ItineraryItemModel item) async {
    final dest = item.destination;
    final lat = dest?.latitude;
    final lng = dest?.longitude;
    final name = dest?.name ?? 'Điểm đến';

    Uri? targetUri;

    if (_isValidCoordinate(lat, lng)) {
      final encodedName = Uri.encodeComponent(name);
      targetUri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&destination_place_id=$encodedName',
      );
    } else {
      final encodedQuery = Uri.encodeComponent('$name Đà Nẵng');
      targetUri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$encodedQuery',
      );
    }

    try {
      final canLaunch = await canLaunchUrl(targetUri);
      if (canLaunch) {
        await launchUrl(targetUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(targetUri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể mở Google Maps trên thiết bị này.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

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

    final validPoints = _extractValidCoordinates();
    final selectedItem = _selectedItemIndex < widget.items.length
        ? widget.items[_selectedItemIndex]
        : widget.items.first;

    final initialCenter =
        validPoints.isNotEmpty ? validPoints.first : _daNangCenter;

    return Stack(
      children: [
        // Real Geographic Map Layer (OpenStreetMap via FlutterMap)
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: initialCenter,
            initialZoom: validPoints.length > 1 ? 12.0 : 13.5,
            minZoom: 4.0,
            maxZoom: 18.0,
            onMapReady: () {
              _fitBounds();
            },
          ),
          children: [
            // Geographic Map Tiles with full CORS support on Web and Mobile
            TileLayer(
              urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
              maxZoom: 19,
            ),

            // Polyline connecting stops in itinerary order
            if (validPoints.length > 1)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: validPoints,
                    strokeWidth: 4.0,
                    color: const Color(0xFF0077B6).withValues(alpha: 0.85),
                    strokeCap: StrokeCap.round,
                    strokeJoin: StrokeJoin.round,
                  ),
                ],
              ),

            // Destination Markers
            MarkerLayer(
              markers: List.generate(widget.items.length, (index) {
                final item = widget.items[index];
                final dest = item.destination;

                if (dest == null ||
                    !_isValidCoordinate(dest.latitude, dest.longitude)) {
                  return const Marker(
                    point: LatLng(0, 0),
                    child: SizedBox.shrink(),
                  );
                }

                final point = LatLng(dest.latitude, dest.longitude);
                final isSelected = index == _selectedItemIndex;

                return Marker(
                  point: point,
                  width: isSelected ? 42 : 34,
                  height: isSelected ? 48 : 40,
                  alignment: Alignment.topCenter,
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedItemIndex = index);
                      _mapController.move(
                          point, math.max(_mapController.camera.zoom, 14.0));
                      widget.onItemTap?.call(item);
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
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
            ),
          ],
        ),

        // Map Header Badge with Recenter Button
        Positioned(
          top: 12,
          right: 12,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(8),
                elevation: 2,
                child: InkWell(
                  onTap: _fitBounds,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.crop_free,
                            size: 14, color: Color(0xFF0077B6)),
                        SizedBox(width: 4),
                        Text(
                          'Căn chỉnh',
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
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Text(
                  '© OpenStreetMap',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Bottom Stop Card Preview (Peek State) with Direct Navigation Action
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
                GestureDetector(
                  onTap: () {
                    final dest = selectedItem.destination;
                    if (dest != null &&
                        _isValidCoordinate(dest.latitude, dest.longitude)) {
                      _mapController.move(
                        LatLng(dest.latitude, dest.longitude),
                        math.max(_mapController.camera.zoom, 14.5),
                      );
                    }
                  },
                  child: Container(
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
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => widget.onItemTap?.call(selectedItem),
                    borderRadius: BorderRadius.circular(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1,
                              ),
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
                ),
                const SizedBox(width: 8),

                // Button: Open in Google Maps for Navigation
                ElevatedButton.icon(
                  onPressed: () => _openGoogleMaps(selectedItem),
                  icon: const Icon(Icons.directions, size: 16),
                  label: const Text('Chỉ đường'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0077B6),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
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
