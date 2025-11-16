// lib/data/services/activity_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/activity.dart';

class ActivityService {
  final SupabaseClient client;
  ActivityService(this.client);

  /// Lấy danh sách tour_location_id theo tour_id
  Future<List<int>> getTourLocationIds(int tourId) async {
    final res = await client
        .from('tour_locations')
        .select('tour_location_id')
        .eq('tour_id', tourId);

    return (res as List)
        .map((e) => e['tour_location_id'] as int)
        .toList();
  }

  /// Lấy activities theo 1 tour_location_id (nếu cần dùng riêng)
  Future<List<Activity>> getByTourLocationId(int tourLocationId) async {
    final res = await client
        .from('activities')
        .select('activity_id, tour_location_id, name, activity_type, start_time')
        .eq('tour_location_id', tourLocationId)
        .order('start_time', ascending: true);

    return (res as List).map((e) => Activity.fromJson(e)).toList();
  }

  /// Lấy activities theo nhiều tour_location_id
  Future<Map<int, List<Activity>>> getByTourLocationIds(List<int> ids) async {
    if (ids.isEmpty) return {};
    final res = await client
        .from('activities')
        .select('activity_id, tour_location_id, name, activity_type, start_time')
        .inFilter('tour_location_id', ids)
        .order('start_time', ascending: true);

    final map = <int, List<Activity>>{};
    for (final raw in res as List) {
      final act = Activity.fromJson(raw);
      map.putIfAbsent(act.tourLocationId, () => []);
      map[act.tourLocationId]!.add(act);
    }
    return map;
  }

  /// TIỆN LỢI: chỉ cần tour_id là lấy được tất cả activities
  Future<List<Activity>> getByTourId(int tourId) async {
    final ids = await getTourLocationIds(tourId); // ví dụ [1,2,3,4]
    if (ids.isEmpty) return [];
    final map = await getByTourLocationIds(ids);
    // gộp lại 1 list & sort theo thời gian
    final all = map.values.expand((e) => e).toList();
    all.sort((a, b) {
      final at = a.startTime?.millisecondsSinceEpoch ?? -1;
      final bt = b.startTime?.millisecondsSinceEpoch ?? -1;
      return at.compareTo(bt);
    });
    return all;
  }
}
