import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travel_app/data/models/map_location.dart';

class TourLocationService {
  final SupabaseClient client;

  TourLocationService(this.client);

  /// Lấy danh sách địa điểm thuộc tour
  Future<List<MapLocation>> getLocationsByTourId(int tourId) async {
    // 1️⃣ Lấy list location_id từ bảng join tour_locations
    final joinData = await client
        .from('tour_locations')
        .select('location_id')
        .eq('tour_id', tourId);

    if (joinData.isEmpty) return [];

    final ids = joinData.map((e) => e['location_id']).toList();

    // 2️⃣ Query bảng "locations" để lấy latitude / longitude
    final locData = await client
        .from('locations')
        .select('location_id, name, latitude, longitude, image_url')
        .inFilter('location_id', ids);

    // 3️⃣ convert sang model
    return locData.map((e) => MapLocation.fromJson(e)).toList();
  }
}
