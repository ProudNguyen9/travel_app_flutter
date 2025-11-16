// lib/data/models/activity.dart
class Activity {
  final int activityId;
  final int tourLocationId;
  final String name;
  final String? activityType;
  final DateTime? startTime;

  Activity({
    required this.activityId,
    required this.tourLocationId,
    required this.name,
    this.activityType,
    this.startTime,
  });

  factory Activity.fromJson(Map<String, dynamic> j) => Activity(
        activityId: j['activity_id'] as int,
        tourLocationId: j['tour_location_id'] as int,
        name: (j['name'] as String?) ?? '',               // tránh null -> ''
        activityType: j['activity_type'] as String?,       // có thể null
        startTime: j['start_time'] == null                 // tránh null parse
            ? null
            : DateTime.parse(j['start_time'] as String),
      );
}
