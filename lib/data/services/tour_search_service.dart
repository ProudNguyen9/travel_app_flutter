import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travel_app/data/data.dart'; // ⭐ chứa class TourFull

class TourSearchService {
  final supabase = Supabase.instance.client;

  // ----------------------------------------------------------
  // 1) TÌM TOUR GIẢM GIÁ
  // ----------------------------------------------------------
  Future<List<Map<String, dynamic>>> searchDiscountTours({
    required String keyword,
    required num minDiscount,
  }) async {
    try {
      final result = await supabase.rpc(
        'search_tours',
        params: {
          'keyword_input': keyword, // ⭐ ĐÚNG
          'min_discount_input': minDiscount, // ⭐ ĐÚNG
        },
      );

      if (result == null) return [];
      return List<Map<String, dynamic>>.from(result as List);
    } catch (e) {
      print("❌ search_tours error: $e");
      return [];
    }
  }

  // ----------------------------------------------------------
  // 2) TÌM TOUR THEO NGÂN SÁCH — dưới giá X
  // ----------------------------------------------------------
  Future<List<Map<String, dynamic>>> searchByBudget({
    required num maxPrice,
  }) async {
    try {
      final result = await supabase.rpc(
        'budget_search',
        params: {'max_price': maxPrice},
      );

      if (result == null) return [];
      return List<Map<String, dynamic>>.from(result as List);
    } catch (e) {
      print("❌ budget_search error: $e");
      return [];
    }
  }

  // ----------------------------------------------------------
  // 3) TÌM TOUR GIÁ TỪ min_price TRỞ LÊN (tour trên X)
  // ----------------------------------------------------------
  Future<List<Map<String, dynamic>>> searchMinBudget({
    required num minPrice,
  }) async {
    try {
      final result = await supabase.rpc(
        'min_budget_search',
        params: {'min_price': minPrice},
      );

      if (result == null) return [];
      return List<Map<String, dynamic>>.from(result as List);
    } catch (e) {
      print("❌ min_budget_search error: $e");
      return [];
    }
  }

  // ----------------------------------------------------------
  // 4) TÌM TOUR TRONG KHOẢNG GIÁ (X → Y)
  // ----------------------------------------------------------
  Future<List<Map<String, dynamic>>> searchRangeBudget({
    required num minPrice,
    required num maxPrice,
  }) async {
    try {
      final result = await supabase.rpc(
        'range_budget_search',
        params: {
          'min_price': minPrice,
          'max_price': maxPrice,
        },
      );

      if (result == null) return [];
      return List<Map<String, dynamic>>.from(result as List);
    } catch (e) {
      print("❌ range_budget_search error: $e");
      return [];
    }
  }

  // ----------------------------------------------------------
  // 5) TÌM TOUR THEO SỐ NGÀY
  // ----------------------------------------------------------
  Future<List<Map<String, dynamic>>> searchByDuration(int days) async {
    try {
      final result = await supabase.rpc(
        'search_tours_by_duration',
        params: {'days_input': days}, // ⭐ đúng param
      );

      if (result == null) return [];
      return List<Map<String, dynamic>>.from(result as List);
    } catch (e) {
      print("❌ duration_search error: $e");
      return [];
    }
  }

  // ----------------------------------------------------------
  // 6) TÌM TOP TOUR RẺ NHẤT
  // ----------------------------------------------------------
  Future<List<Map<String, dynamic>>> searchCheapTours({
    required int limit,
  }) async {
    try {
      final result = await supabase.rpc(
        'cheap_tours',
        params: {'limit_input': limit}, // ⭐ đúng param
      );

      if (result == null) return [];
      return List<Map<String, dynamic>>.from(result as List);
    } catch (e) {
      print("❌ cheap_tours error: $e");
      return [];
    }
  }

  // ----------------------------------------------------------
  // 7) LẤY GIÁ TOUR (base người lớn)
  // ----------------------------------------------------------
  Future<num> getTourPrice(int tourId) async {
    try {
      final result = await supabase.rpc(
        'get_tour_price',
        params: {'tour_id_input': tourId}, // ⭐ đúng param
      );

      if (result == null) return 0;
      return result as num;
    } catch (e) {
      print("❌ get_tour_price error: $e");
      return 0;
    }
  }

  // ----------------------------------------------------------
  // 8) ⭐ LẤY ĐẦY ĐỦ THÔNG TIN TOUR ĐỂ MỞ DETAIL SCREEN
  // ----------------------------------------------------------
  Future<TourFull> getFullTour(int tourId) async {
    try {
      final result = await supabase
          .from("vw_tours_full")
          .select()
          .eq("tour_id", tourId)
          .maybeSingle();

      if (result == null) {
        throw "Không tìm thấy tour ID = $tourId";
      }

      return TourFull.fromMap(result); // ⭐ CHUẨN
    } catch (e) {
      print("❌ getFullTour error: $e");
      rethrow;
    }
  }

  // ----------------------------------------------------------
  // 9) LẤY FULL TOUR CHO DANH SÁCH ID
  // ----------------------------------------------------------
  Future<List<TourFull>> getFullTours(List<int> ids) async {
    if (ids.isEmpty) return [];

    try {
      final result = await supabase
          .from("vw_tours_full")
          .select()
          .inFilter("tour_id", ids); // ⭐ đúng hàm

      return List<Map<String, dynamic>>.from(result as List)
          .map((e) => TourFull.fromMap(e)) // ⭐ CHUẨN
          .toList();
    } catch (e) {
      print("❌ getFullTours error: $e");
      return [];
    }
  }
}
