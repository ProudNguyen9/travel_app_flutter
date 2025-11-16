// lib/screens/itinerary_map_screen.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travel_app/data/services/activity_service.dart';
import 'package:travel_app/data/services/tour_location_service.dart';
import 'package:travel_app/data/models/map_location.dart';
import 'package:travel_app/widget/location_card.dart';
import 'package:travel_app/widget/tour_bottom_sheet.dart';

class ItineraryMapScreen extends StatefulWidget {
  final int tourId;
  final DateTime startDate;
  final DateTime endDate;

  const ItineraryMapScreen({
    super.key,
    required this.tourId,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<ItineraryMapScreen> createState() => _ItineraryMapScreenState();
}

class _ItineraryMapScreenState extends State<ItineraryMapScreen>
    with TickerProviderStateMixin {
  late final AnimatedMapController _animatedMapController;
  final PopupController _popupController = PopupController();

  Timer? _timer;

  int _segmentIndex = 0;
  int _stepIndex = 0;

  List<LatLng> routePoints = [];
  final List<LatLng> _animatedPoints = [];
  List<MapLocation> _locations = [];

  bool _mapReady = false;
  bool _dataReady = false;

  @override
  void initState() {
    super.initState();
    _animatedMapController = AnimatedMapController(vsync: this);
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    try {
      final client = Supabase.instance.client;
      final service = TourLocationService(client);

      final locs = await service.getLocationsByTourId(widget.tourId);

      if (!mounted) return;

      setState(() {
        _locations = locs;
        routePoints = locs.map((e) => LatLng(e.latitude, e.longitude)).toList();

        _animatedPoints.clear();
        if (routePoints.isNotEmpty) {
          _animatedPoints.add(routePoints.first);
        }
      });

      _dataReady = true;
      _tryStartAnimation();
    } catch (e) {
      debugPrint("Load location error: $e");
    }
  }

  void _tryStartAnimation() {
    if (_mapReady && _dataReady && routePoints.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 200), () {
        _fitAllPoints();
        _startSmoothAnimation();
      });
    }
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
        timer.cancel();
        return;
      }

      final start = routePoints[_segmentIndex];
      final end = routePoints[_segmentIndex + 1];

      final t = _stepIndex / stepsPerSegment;
      final lat = start.latitude + (end.latitude - start.latitude) * t;
      final lng = start.longitude + (end.longitude - start.longitude) * t;

      setState(() => _animatedPoints.add(LatLng(lat, lng)));

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

  // =====================================================================
  // UI
  // =====================================================================

  @override
  Widget build(BuildContext context) {
    final currentCarPosition = _animatedPoints.isNotEmpty
        ? _animatedPoints.last
        : (routePoints.isNotEmpty ? routePoints.first : const LatLng(0, 0));

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _animatedMapController.mapController,
            options: MapOptions(
              initialCenter: routePoints.isNotEmpty
                  ? routePoints.first
                  : const LatLng(0, 0),
              initialZoom: 14,
              onTap: (_, __) => _popupController.hideAllPopups(),
              onMapReady: () {
                _mapReady = true;
                _tryStartAnimation();
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=QP5NRxkCF6PG3PvLdYl2",
                userAgentPackageName: "com.travel.app",
              ),

              // LINE ANIMATION
              if (_animatedPoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _animatedPoints,
                      strokeWidth: 5,
                      color: const Color(0xFF24BAEC),
                    ),
                  ],
                ),

              // CAR MARKER
              MarkerLayer(
                markers: [
                  Marker(
                    point: currentCarPosition,
                    width: 60,
                    height: 60,
                    child: Image.asset("assets/icons/car.png"),
                  ),
                ],
              ),

              // LOCATION POPUP
              PopupMarkerLayerWidget(
                options: PopupMarkerLayerOptions(
                  popupController: _popupController,
                  markers: routePoints
                      .map(
                        (p) => Marker(
                          point: p,
                          width: 70,
                          height: 70,
                          child: Image.asset("assets/icons/marker.png"),
                        ),
                      )
                      .toList(),
                  popupDisplayOptions: PopupDisplayOptions(
                    builder: (context, marker) {
                      final index = routePoints.indexOf(marker.point);
                      final loc = _locations[index];

                      return LocationCard(
                        imagePath:
                            loc.imageUrl ?? 'assets/images/mountain2.png',
                        title: loc.name,
                        day: "Địa điểm ${index + 1}",
                        date: "",
                        onTap: () async {
                          final service =
                              ActivityService(Supabase.instance.client);

                          final acts = await service.getByTourId(widget.tourId);

                          // Convert → ActivityItem
                          final items = acts
                              .map((a) => ActivityItem(
                                    originalDate: a.startTime!,
                                    time: DateFormat("HH:mm")
                                        .format(a.startTime!),
                                    title: a.name,
                                    subtitle: a.activityType ?? "",
                                  ))
                              .toList();

                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => BottomSheetContent(
                              startDate: widget.startDate,
                              endDate: widget.endDate,
                              activities: items,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),

          // APPBAR
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
                  Text(
                    'Lịch trình Tour',
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: const Color(0xFF1B1E28),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
