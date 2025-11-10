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

  // 🟦 Lấy 1 tour theo ID (dùng cache nếu có) + luôn tải ảnh mới nhất
  Future<TourFull?> fetchTourForDetailById(int tourId) async {
    TourFull? tour;

    // 1) Tìm trong cache nếu có
    if (_cachedTours != null) {
      try {
        tour = _cachedTours!.firstWhere((t) => t.tourId == tourId);
      } catch (_) {}
    }

    // 2) Nếu chưa có → tạo cache
    if (tour == null) {
      await fetchAllTours();
      try {
        tour = _cachedTours!.firstWhere((t) => t.tourId == tourId);
      } catch (_) {
        return null;
      }
    }

    // 3) Luôn tải list ảnh mới nhất từ VIEW
    try {
      final images = await _fetchImagesByTourId(tourId);
      tour.images = images; // gán trực tiếp (images KHÔNG final)
    } catch (_) {
      // optional: log
    }

    return tour;
  }

  /// 🖼️ Lấy danh sách ảnh theo tour_id từ VIEW (tour_locations → locations)
  Future<List<String>> _fetchImagesByTourId(int tourId) async {
    final rows = await Supabase.instance.client
        .from('vw_tour_images')
        .select('image_url')
        .eq('tour_id', tourId);

    // rows là List<dynamic>
    final urls = rows
        .map<String?>((r) => r['image_url'] as String?)
        .where((u) => u != null && u.trim().isNotEmpty)
        .map((u) => u!.trim())
        .toSet() // khử trùng lặp
        .toList();

    return urls;
  }

  ///  Reset cache (ví dụ khi logout)
  void clearCache() {
    _cachedTours = null;
    _lastFetch = null;
  }
}
