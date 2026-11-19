import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import '../services/location_service.dart';
import '../theme/app_colors.dart';

/// Renders a real interactive OpenStreetMap route view with live courier,
/// donor pickup marker, NGO shelter destination pin, and real navigation polyline.
class RouteMapView extends StatefulWidget {
  final double? height;
  final String pickupAddress;
  final String destinationAddress;
  final String etaText;
  final VoidCallback? onRefresh;
  final LatLng? pickupLocation;
  final LatLng? destinationLocation;
  final LatLng? courierLocation;

  const RouteMapView({
    super.key,
    this.height = 280,
    this.pickupAddress = 'Powai Naka, Satara',
    this.destinationAddress = 'Asha Shelter, Sadar Bazar, Satara',
    this.etaText = 'Pickup in 24 min',
    this.onRefresh,
    this.pickupLocation,
    this.destinationLocation,
    this.courierLocation,
  });

  @override
  State<RouteMapView> createState() => _RouteMapViewState();
}

class _RouteMapViewState extends State<RouteMapView> {
  late final MapController _mapController;
  List<LatLng> _liveRoutePoints = [];

  // Default coordinate anchors (Satara Core Hub: Powai Naka -> Sadar Bazar -> MIDC)
  static const LatLng _defaultPickup = LatLng(17.6805, 73.9934);
  static const LatLng _defaultCourier = LatLng(17.6850, 73.9980);
  static const LatLng _defaultDestination = LatLng(17.6920, 74.0020);

  LatLng get _pickup => widget.pickupLocation ?? _defaultPickup;
  LatLng get _destination => widget.destinationLocation ?? _defaultDestination;
  LatLng get _courier => widget.courierLocation ?? _defaultCourier;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _liveRoutePoints = _buildRealisticRoute();
    _loadLiveRoadRoute();
  }

  @override
  void didUpdateWidget(RouteMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.courierLocation != widget.courierLocation ||
        oldWidget.pickupLocation != widget.pickupLocation ||
        oldWidget.destinationLocation != widget.destinationLocation) {
      _loadLiveRoadRoute();
      if (widget.courierLocation != null) {
        try {
          _mapController.move(widget.courierLocation!, _mapController.camera.zoom);
        } catch (_) {}
      }
    }
  }

  void _fitBounds() {
    try {
      final bounds = LatLngBounds.fromPoints([_pickup, _courier, _destination]);
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(48),
        ),
      );
    } catch (_) {}
  }

  Future<void> _loadLiveRoadRoute() async {
    final bool isTestMode = !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
    if (isTestMode) return;
    try {
      final route = await LocationService.instance.fetchRoadRoute(_pickup, _destination);
      if (mounted && route.isNotEmpty) {
        setState(() {
          _liveRoutePoints = route;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _recenter() async {
    if (widget.courierLocation != null) {
      _mapController.move(widget.courierLocation!, 14.5);
    } else {
      final currentPos = await LocationService.instance.getCurrentPosition();
      _mapController.move(currentPos, 14.5);
    }
  }

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, (currentZoom + 1).clamp(5.0, 18.5));
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, (currentZoom - 1).clamp(5.0, 18.5));
  }

  List<LatLng> _buildRealisticRoute() {
    final p = _pickup;
    final c = _courier;
    final d = _destination;

    return [
      p,
      LatLng(p.latitude - 0.0028, p.longitude - 0.0012),
      LatLng(p.latitude - 0.0055, p.longitude + 0.0004),
      c,
      LatLng(d.latitude + 0.0052, d.longitude - 0.0016),
      LatLng(d.latitude + 0.0024, d.longitude - 0.0006),
      d,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isTestMode = !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
    final bool isFullScreen = widget.height == null;

    Widget mapContent = isTestMode
        ? _buildTestFallbackPainter()
        : _buildRealMap(isDark);

    Widget wrapped = Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : const Color(0xFFE5ECE7),
        borderRadius: BorderRadius.circular(isFullScreen ? 0 : 20),
        boxShadow: isFullScreen
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isFullScreen ? 0 : 20),
        child: Stack(
          children: [
            Positioned.fill(child: mapContent),

            // Top Floating Controls: Recenter, Zoom In/Out, Refresh
            Positioned(
              top: isFullScreen ? 100 : 12,
              right: 14,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _mapButton(
                    icon: Icons.my_location,
                    tooltip: 'Recenter on Courier',
                    onTap: _recenter,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 6),
                  _mapButton(
                    icon: Icons.fit_screen_outlined,
                    tooltip: 'Fit Entire Route',
                    onTap: _fitBounds,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 6),
                  _mapButton(
                    icon: Icons.add,
                    tooltip: 'Zoom In',
                    onTap: _zoomIn,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 6),
                  _mapButton(
                    icon: Icons.remove,
                    tooltip: 'Zoom Out',
                    onTap: _zoomOut,
                    isDark: isDark,
                  ),
                  if (widget.onRefresh != null) ...[
                    const SizedBox(height: 6),
                    _mapButton(
                      icon: Icons.refresh,
                      tooltip: 'Refresh Route',
                      onTap: widget.onRefresh!,
                      isDark: isDark,
                    ),
                  ],
                ],
              ),
            ),

            // Live GPS indicator chip on top left (embedded card mode)
            if (!isFullScreen)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.cardDark : Colors.white).withOpacity(0.92),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primaryGreen.withOpacity(0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Live GPS Tracking',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Bottom overlay indicator with legend (embedded card mode)
            if (!isFullScreen)
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.cardDark : AppColors.white).withOpacity(0.94),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? Colors.white12 : AppColors.mintLight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: AppColors.errorRed,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Donor Pickup',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textDarkPrimary : AppColors.charcoal,
                            ),
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_forward, size: 14, color: AppColors.mutedGrey),
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'NGO Shelter',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textDarkPrimary : AppColors.charcoal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    if (widget.height != null) {
      return SizedBox(
        height: widget.height,
        width: double.infinity,
        child: wrapped,
      );
    }
    return wrapped;
  }

  Widget _buildRealMap(bool isDark) {
    final routePoints = _liveRoutePoints.isNotEmpty ? _liveRoutePoints : _buildRealisticRoute();

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _courier,
        initialZoom: 13.8,
        minZoom: 6.0,
        maxZoom: 18.5,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        // OpenStreetMap raster tiles
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'org.foodbridge.app',
          maxZoom: 19,
        ),

        // Route polyline (casing halo + core line)
        PolylineLayer(
          polylines: [
            Polyline(
              points: routePoints,
              strokeWidth: 8.0,
              color: const Color(0xFF1E88E5).withOpacity(0.3),
              strokeCap: StrokeCap.round,
              strokeJoin: StrokeJoin.round,
            ),
            Polyline(
              points: routePoints,
              strokeWidth: 4.5,
              color: const Color(0xFF1E88E5),
              strokeCap: StrokeCap.round,
              strokeJoin: StrokeJoin.round,
            ),
          ],
        ),

        // Markers for Pickup, Destination, and Live Courier
        MarkerLayer(
          markers: [
            // 1. Donor Pickup Marker
            Marker(
              point: _pickup,
              width: 120,
              height: 64,
              alignment: Alignment.topCenter,
              child: _buildPinMarker(
                color: AppColors.errorRed,
                icon: Icons.storefront,
                tooltip: 'Pickup: ${widget.pickupAddress}',
                label: 'Donor Pickup (पिकअप)',
              ),
            ),

            // 2. NGO Shelter Destination Marker
            Marker(
              point: _destination,
              width: 120,
              height: 64,
              alignment: Alignment.topCenter,
              child: _buildPinMarker(
                color: AppColors.primaryGreen,
                icon: Icons.home_work,
                tooltip: 'Drop-off: ${widget.destinationAddress}',
                label: 'NGO Shelter (डिलिव्हरी)',
              ),
            ),

            // 3. Live Courier with floating ETA callout bubble
            Marker(
              point: _courier,
              width: 140,
              height: 72,
              alignment: Alignment.topCenter,
              child: _buildCourierMarker(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPinMarker({
    required Color color,
    required IconData icon,
    required String tooltip,
    String? label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            margin: const EdgeInsets.only(bottom: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, size: 16, color: Colors.white),
        ),
        CustomPaint(
          size: const Size(8, 5),
          painter: _TrianglePainter(color: color),
        ),
      ],
    );
  }

  Widget _buildCourierMarker() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Floating ETA callout badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primaryGreen.withOpacity(0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.two_wheeler, size: 15, color: AppColors.primaryGreen),
              const SizedBox(width: 4),
              Text(
                widget.etaText,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.charcoal,
                ),
              ),
            ],
          ),
        ),
        CustomPaint(
          size: const Size(8, 4),
          painter: _TrianglePainter(color: AppColors.white),
        ),
        const SizedBox(height: 2),

        // Live Courier Scooter Pin
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF1E88E5),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E88E5).withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.delivery_dining, size: 18, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildTestFallbackPainter() {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _MapRoutePainter(),
          ),
        ),
        // Courier callout badge
        Positioned(
          top: (widget.height ?? 280) * 0.28,
          left: 100,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.two_wheeler, size: 16, color: AppColors.primaryGreen),
                    const SizedBox(width: 6),
                    Text(
                      widget.etaText,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.charcoal,
                      ),
                    ),
                  ],
                ),
              ),
              CustomPaint(
                size: const Size(10, 6),
                painter: _TrianglePainter(color: AppColors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _mapButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: (isDark ? AppColors.cardDark : AppColors.white).withOpacity(0.95),
      shape: const CircleBorder(),
      elevation: 3,
      shadowColor: Colors.black26,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(7.0),
            child: Icon(
              icon,
              size: 17,
              color: isDark ? AppColors.textDarkPrimary : AppColors.charcoal,
            ),
          ),
        ),
      ),
    );
  }
}

class _MapRoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Street grid lines
    final streetPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    final minorStreetPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Draw main streets
    canvas.drawLine(Offset(0, h * 0.4), Offset(w, h * 0.35), streetPaint);
    canvas.drawLine(Offset(0, h * 0.7), Offset(w, h * 0.65), streetPaint);
    canvas.drawLine(Offset(w * 0.3, 0), Offset(w * 0.35, h), streetPaint);
    canvas.drawLine(Offset(w * 0.7, 0), Offset(w * 0.65, h), streetPaint);

    // Draw minor streets
    canvas.drawLine(Offset(0, h * 0.15), Offset(w, h * 0.2), minorStreetPaint);
    canvas.drawLine(Offset(0, h * 0.85), Offset(w, h * 0.8), minorStreetPaint);
    canvas.drawLine(Offset(w * 0.15, 0), Offset(w * 0.12, h), minorStreetPaint);
    canvas.drawLine(Offset(w * 0.85, 0), Offset(w * 0.82, h), minorStreetPaint);

    // Park / Green zones
    final parkPaint = Paint()
      ..color = const Color(0xFFCCE3D2)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.05, h * 0.22, w * 0.22, h * 0.15),
        const Radius.circular(8),
      ),
      parkPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.72, h * 0.45, w * 0.22, h * 0.18),
        const Radius.circular(8),
      ),
      parkPaint,
    );

    // Route path (From Donor to Shelter)
    final p1 = Offset(w * 0.18, h * 0.65);
    final p2 = Offset(w * 0.45, h * 0.42);
    final p3 = Offset(w * 0.82, h * 0.32);

    final routeBgPaint = Paint()
      ..color = const Color(0xFF1E88E5).withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final routePaint = Paint()
      ..color = const Color(0xFF1E88E5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final routePath = Path();
    routePath.moveTo(p1.dx, p1.dy);
    routePath.lineTo(p2.dx, p2.dy);
    routePath.lineTo(p3.dx, p3.dy);

    canvas.drawPath(routePath, routeBgPaint);
    canvas.drawPath(routePath, routePaint);

    // Pin 1: Pickup Pin (Red)
    _drawPin(canvas, p1, AppColors.errorRed);

    // Pin 2: Delivery Pin (Green)
    _drawPin(canvas, p3, AppColors.primaryGreen);
  }

  void _drawPin(Canvas canvas, Offset pos, Color color) {
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(Offset(pos.dx, pos.dy + 4), 10, shadowPaint);

    final circlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pos, 11, circlePaint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(pos, 11, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
