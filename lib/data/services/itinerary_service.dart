import 'package:supabase_flutter/supabase_flutter.dart';

class ItineraryService {
  final supabase = Supabase.instance.client;

  // ----------------------------------------------------------
  // ⭐ LẤY LỊCH TRÌNH THEO TÊN TOUR
  // ----------------------------------------------------------
  Future<List<Map<String, dynamic>>> getItinerary(String tourName) async {
    try {
      final response = await supabase.rpc(
        'get_itinerary',
        params: {'tour_name': tourName},
      );

      if (response == null) return [];

      return List<Map<String, dynamic>>.from(
        (response as List).map((e) => e as Map<String, dynamic>),
      );
    } catch (e) {
      print("❌ RPC get_itinerary error: $e");
      return [];
    }
  }
}
