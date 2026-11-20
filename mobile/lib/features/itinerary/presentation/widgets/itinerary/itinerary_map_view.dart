import 'package:smarttravel_mobile/core/localization/app_language.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:smarttravel_mobile/features/itinerary/data/models/itinerary_model.dart';
import 'package:url_launcher/url_launcher.dart';

List<LatLng> itineraryRoutePoints(ItineraryItemModel item) {
  final geometry = item.routePolyline;
  if ((item.routeSource != 'PROVIDER' && item.routeSource != 'CACHE') ||
      geometry == null || geometry.isEmpty) {
    return const [];
  }
  try {
    final coordinates = jsonDecode(geometry);
    if (coordinates is! List || coordinates.length < 2 || coordinates.length > 10000) {
      return const [];
    }
    final points = <LatLng>[];
    for (final coordinate in coordinates) {
      if (coordinate is! List || coordinate.length != 2 ||
          coordinate[0] is! num || coordinate[1] is! num) {
        return const [];
      }
      final lon = (coordinate[0] as num).toDouble();
      final lat = (coordinate[1] as num).toDouble();
      if (!lat.isFinite || !lon.isFinite || lat.abs() > 90 || lon.abs() > 180) {
        return const [];
      }
      points.add(LatLng(lat, lon));
    }
    return points;
  } on FormatException {
    return const [];
  }
}

class ItineraryMapView extends StatefulWidget {
  final List<ItineraryItemModel> items;
  final ValueChanged<ItineraryItemModel>? onItemTap;
  final String transport;

  const ItineraryMapView({
    super.key,
    required this.items,
    this.transport = 'unspecified',
    this.onItemTap,
  });

  @override
  State<ItineraryMapView> createState() => _ItineraryMapViewState();
}

class _ItineraryMapViewState extends State<ItineraryMapView> {
  int? _selectedItemIndex;
  final MapController _mapController = MapController();

  static const LatLng _daNangCenter = LatLng(16.0544, 108.2022);

  @override
  void didUpdateWidget(covariant ItineraryMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _selectedItemIndex = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _extractValidCoordinates().isNotEmpty) _fitBounds();
      });
    }
  }

  bool _isValidCoordinate(double? lat, double? lng) {
    if (lat == null || lng == null) return false;
    return lat >= -90.0 && lat <= 90.0 && lng >= -180.0 && lng <= 180.0;
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  List<LatLng> _extractValidCoordinates() {
    final List<LatLng> points = [];
    for (final item in widget.items) {
      final dest = item.destination;
      if (dest != null && _isValidCoordinate(dest.latitude, dest.longitude)) {
        points.add(LatLng(dest.latitude!, dest.longitude!));
      }
    }
    return points;
  }

  void _fitBounds() {
    final points = {
      ..._extractValidCoordinates(),
      for (final item in widget.items) ...itineraryRoutePoints(item),
    }.toList();
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

    final Uri targetUri;

    if (_isValidCoordinate(lat, lng)) {
      final mode = switch (widget.transport) {
        'walking' => 'walking',
        'motorbike' => 'two-wheeler',
        'car' || 'taxi' => 'driving',
        _ => null,
      };
      targetUri = Uri.https('www.google.com', '/maps/dir/', {
        'api': '1',
        'destination': '$lat,$lng',
        if (mode != null) 'travelmode': mode,
      });
    } else {
      final encodedQuery = Uri.encodeComponent('$name Đà Nẵng');
      targetUri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$encodedQuery',
      );
    }

    if (await _launch(targetUri, LaunchMode.externalApplication) ||
        await _launch(targetUri, LaunchMode.platformDefault)) {
      return;
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: AppText('Không thể mở Google Maps trên thiết bị này.')),
      );
    }
  }

  Future<bool> _launch(Uri uri, LaunchMode mode) async {
    try {
      return await launchUrl(uri, mode: mode);
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const Center(
        child: AppText(
          'Không có điểm đến nào trong ngày này',
          style: TextStyle(color: Color(0xFF64748B)),
        ),
      );
    }

    final validPoints = _extractValidCoordinates();
    if (validPoints.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: AppText('Các điểm trong ngày này chưa có tọa độ. Bạn vẫn có thể xem lịch theo ngày.',
              textAlign: TextAlign.center),
        ),
      );
    }
    final selectedIndex = _selectedItemIndex ?? widget.items.indexWhere(
      (item) => _isValidCoordinate(item.destination?.latitude, item.destination?.longitude),
    );
    final selectedItem = widget.items[selectedIndex];
    final routes = widget.items.map(itineraryRoutePoints).where((points) => points.isNotEmpty);

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

            PolylineLayer(polylines: [
              for (final points in routes)
                Polyline(points: points, color: const Color(0xFF0077B6), strokeWidth: 4),
            ]),
            MarkerLayer(
              markers: List<Marker?>.generate(widget.items.length, (index) {
                final item = widget.items[index];
                final dest = item.destination;

                if (dest == null ||
                    !_isValidCoordinate(dest.latitude, dest.longitude)) {
                  return null;
                }

                final point = LatLng(dest.latitude!, dest.longitude!);
                final isSelected = index == selectedIndex;

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
                          child: AppText(
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
              }).nonNulls.toList(),
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
                        AppText(
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
                child: const AppText(
                'Esri · © OpenStreetMap',
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
                        LatLng(dest.latitude!, dest.longitude!),
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
                              child: AppText(
                                'Điểm ${selectedIndex + 1}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: AppText(
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
                        AppText(
                          [
                            selectedItem.startTime,
                            if (selectedItem.routeSource == 'HAVERSINE') 'Chặng đến ước tính',
                            if (selectedItem.routeSource == 'UNKNOWN') 'Chặng đến chưa có dữ liệu',
                          ].nonNulls.join(' · '),
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
                  label: const AppText('Chỉ đường'),
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
