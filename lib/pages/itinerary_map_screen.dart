import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';
import 'package:gap/gap.dart';
import 'package:travel_app/widget/location_card.dart';
import 'package:travel_app/widget/reuseable_text.dart';

import '../widget/widget.dart';

class MyMapPage extends StatefulWidget {
  const MyMapPage({super.key});

  @override
  State<MyMapPage> createState() => _MyMapPageState();
}

class _MyMapPageState extends State<MyMapPage> with TickerProviderStateMixin {
  late final AnimatedMapController _animatedMapController;
  final PopupController _popupController = PopupController();
  Timer? _timer;
  int _segmentIndex = 0;
  int _stepIndex = 0;

  final List<LatLng> routePoints = [
    const LatLng(10.7945, 106.7218), // Landmark 81
    const LatLng(10.7801, 106.6997), // Bưu điện TP
    const LatLng(10.7733, 106.7040), // Nguyễn Huệ
    const LatLng(10.7725, 106.6981), // Chợ Bến Thành
  ];

  final List<LatLng> _animatedPoints = [];

  @override
  void initState() {
    super.initState();
    _animatedMapController = AnimatedMapController(vsync: this);
    _animatedPoints.add(routePoints.first);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fitAllPoints();
      Future.delayed(const Duration(seconds: 4), _startSmoothAnimation);
    });
  }

  void _fitAllPoints() {
    if (routePoints.isEmpty) return;
    final bounds = LatLngBounds(routePoints.first, routePoints.first);
    for (final p in routePoints) {
      bounds.extend(p);
    }
    _animatedMapController.mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(60)),
    );
  }

  void _startSmoothAnimation() {
    const stepsPerSegment = 60;
    const stepDuration = Duration(milliseconds: 60);

    _timer = Timer.periodic(stepDuration, (timer) {
      if (_segmentIndex >= routePoints.length - 1) {
        final last = routePoints.last;
        final prev = routePoints[routePoints.length - 2];
        final dx = last.longitude - prev.longitude;
        final dy = last.latitude - prev.latitude;
        final len = sqrt(dx * dx + dy * dy);
        if (len == 0) {
          timer.cancel();
          return;
        }
        const extraDist = 0.0019;
        final overshoot = LatLng(
          last.latitude + dy / len * extraDist,
          last.longitude + dx / len * extraDist,
        );
        setState(() => _animatedPoints.add(overshoot));
        timer.cancel();
        return;
      }

      final start = routePoints[_segmentIndex];
      final end = routePoints[_segmentIndex + 1];
      final t = _stepIndex / stepsPerSegment;
      final lat = start.latitude + (end.latitude - start.latitude) * t;
      final lng = start.longitude + (end.longitude - start.longitude) * t;
      final next = LatLng(lat, lng);
      setState(() => _animatedPoints.add(next));

      _stepIndex++;
      if (_stepIndex > stepsPerSegment) {
        _stepIndex = 0;
        _segmentIndex++;
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentCarPosition =
        _animatedPoints.isNotEmpty ? _animatedPoints.last : routePoints.first;

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _animatedMapController.mapController,
            options: MapOptions(
              initialCenter: routePoints.first,
              initialZoom: 14,
              onTap: (_, __) => _popupController.hideAllPopups(),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=QP5NRxkCF6PG3PvLdYl2',
                userAgentPackageName: 'com.example.app',
              ),

              // Đường đi
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _animatedPoints,
                    strokeWidth: 5,
                    color: const Color(0xFF24BAEC),
                  ),
                ],
              ),

              // Marker xe
              MarkerLayer(
                markers: [
                  Marker(
                    point: currentCarPosition,
                    width: 60,
                    height: 60,
                    child: Image.asset(
                      'assets/icons/car.png',
                      width: 50,
                      height: 50,
                    ),
                  ),
                ],
              ),

              // ✅ Popup marker (có thể bấm được onTap trong card)
              // ignore: deprecated_member_use
              PopupMarkerLayerWidget(
                options: PopupMarkerLayerOptions(
                  popupController: _popupController,
                  markers: routePoints
                      .map(
                        (p) => Marker(
                          point: p,
                          width: 70,
                          height: 70,
                          child: Image.asset(
                            'assets/icons/marker.png',
                            width: 70,
                            height: 70,
                            fit: BoxFit.contain,
                          ),
                        ),
                      )
                      .toList(),
                  popupDisplayOptions: PopupDisplayOptions(
                    builder: (context, marker) {
                      final index = routePoints.indexOf(marker.point);
                      return LocationCard(
                        imagePath: 'assets/images/mountain2.png',
                        title: 'Lemon Garden',
                        distance: '2.09 mi',
                        day: 'Day ${index + 1}',
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => const BottomSheetContent(),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),

          // 🧭 AppBar
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Gap(60),
                  const AppText(
                    text: 'Tour Schedule',
                    size: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
