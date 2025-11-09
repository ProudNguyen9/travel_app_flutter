// lib/services/tour_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/tour_full.dart';

class TourService {
  TourService._();
  static final TourService instance = TourService._();

  final SupabaseClient _db = Supabase.instance.client;
  static const String _view = 'vw_tours_full';

  // Cache trong RAM
  List<TourFull>? _cachedTours;
  DateTime? _lastFetch;

  /// 🟦 Lấy danh sách tour
  /// - Lần đầu: gọi API → lưu cache
  /// - Các lần sau: trả về cache luôn
  Future<List<TourFull>> fetchAllTours() async {
    if (_cachedTours != null) {
      // print("🔥 Trả về cache RAM, không gọi lại API");
      return _cachedTours!;
    }

    // print("🌐 Gọi API Supabase...");
    final rows = await _db.from(_view).select();

    _cachedTours = (rows as List)
        .map((e) => TourFull.fromMap(e as Map<String, dynamic>))
        .toList();

    _lastFetch = DateTime.now();

    return _cachedTours!;
  }

  /// 🟦 Lấy 1 tour theo ID (dùng cache nếu có)
  Future<TourFull?> fetchTourById(int tourId) async {
    // Nếu đã có danh sách cache → tìm trong RAM
    if (_cachedTours != null) {
      try {
        return _cachedTours!.firstWhere((t) => t.tourId == tourId);
      } catch (_) {}
    }

    // Nếu chưa có cache → gọi API 1 lần để tạo cache
    await fetchAllTours();

    try {
      return _cachedTours!.firstWhere((t) => t.tourId == tourId);
    } catch (_) {
      return null;
    }
  }

  /// 🧹 Reset cache (ví dụ khi logout)
  void clearCache() {
    _cachedTours = null;
    _lastFetch = null;
  }
}
