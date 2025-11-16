class MapLocation {
  final int tourLocationId;
  final int locationId;
  final double latitude;
  final double longitude;
  final String name;
  final String? imageUrl;

  MapLocation({
    required this.tourLocationId,
    required this.locationId,
    required this.latitude,
    required this.longitude,
    required this.name,
    this.imageUrl,
  });

  factory MapLocation.fromJson(Map<String, dynamic> json) {
    // 👉 Bắt mọi trường hợp có thể: id, tour_location_id, null, num, string…
    final rawTourLocId = json['id'] ?? json['tour_location_id'] ?? 0;
    final rawLocId = json['location_id'] ?? 0;

    final int safeTourLocId = _toSafeInt(rawTourLocId);
    final int safeLocId = _toSafeInt(rawLocId);

    return MapLocation(
      tourLocationId: safeTourLocId,
      locationId: safeLocId,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      name: (json['name'] ?? '') as String,
      imageUrl: json['image_url'] as String?,
    );
  }

  // 👇 helper tránh mọi vụ Null → int
  static int _toSafeInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}
