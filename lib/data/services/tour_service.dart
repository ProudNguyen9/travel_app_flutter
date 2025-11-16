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
    // 1️⃣ Dùng cache nếu có
    if (_cachedTours != null) {
      // print("🔥 Trả về cache RAM, không gọi lại API");
      return _cachedTours!;
    }

    // 2️⃣ Gọi API Supabase
    // print("🌐 Gọi API Supabase...");
    final rows = await _db.from(_view).select();

    // 3️⃣ Map dữ liệu cơ bản
    final tours = (rows as List)
        .map((e) => TourFull.fromMap(e as Map<String, dynamic>))
        .toList();

    // 4️⃣ Gán ảnh cho từng tour
    for (final tour in tours) {
      try {
        final images = await _fetchImagesByTourId(tour.tourId);
        tour.images = images;
      } catch (e) {
        // Có thể log nhẹ nếu muốn
        // print("⚠️ Lỗi tải ảnh cho tour ${tour.tourId}: $e");
        tour.images = [];
      }
    }

    // 5️⃣ Cache lại
    _cachedTours = tours;
    _lastFetch = DateTime.now();

    return _cachedTours!;
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

  Future<List<String>> fetchDistinctTourTypes() async {
    final rows = await _db
        .from(_view)
        .select('tour_type_name')
        .not('tour_type_name', 'is', null) // bỏ null
        .order('tour_type_name', ascending: true);

    // rows: List<dynamic>
    final types = (rows as List)
        .map((e) => (e['tour_type_name'] ?? '').toString().trim())
        .where((s) => s.isNotEmpty)
        .toSet() // unique
        .toList();

    return types;
  }

  Future<List<String>> fetchDistinctDurations() async {
    final rows = await _db
        .from(_view)
        .select('duration_days')
        .not('duration_days', 'is', null)
        .order('duration_days', ascending: true);

    final durations = (rows as List)
        .map((e) {
          final raw = e['duration_days'];
          if (raw == null) return '';
          final doubleVal = double.tryParse(raw.toString()) ?? 0;
          final days = doubleVal.floor();
          final nights = ((doubleVal - days) * 10).round();

          if (days > 0 && nights > 0) return '$days ngày $nights đêm';
          if (days > 0) return '$days ngày';
          if (nights > 0) return '$nights đêm';
          return 'Không xác định';
        })
        .where((s) => s.isNotEmpty && s != 'Không xác định')
        .toSet()
        .toList();

    return durations;
  }
 /// 🟦 Lấy chi tiết tour theo tour_id
  Future<TourFull?> getTourFullById(int tourId) async {
    // 1️⃣ Nếu đã cache → tìm trong cache luôn
    if (_cachedTours != null) {
      try {
        return _cachedTours!.firstWhere((t) => t.tourId == tourId);
      } catch (_) {}
    }

    // 2️⃣ Gọi Supabase để lấy thông tin cơ bản
    final rows = await _db
        .from(_view)
        .select()
        .eq('tour_id', tourId)
        .maybeSingle();

    if (rows == null) return null;

    final tour = TourFull.fromMap(rows);

    // 3️⃣ Lấy ảnh
    try {
      final images = await _fetchImagesByTourId(tourId);
      tour.images = images;
    } catch (_) {
      tour.images = [];
    }

    return tour;
  }

  ///  Reset cache (ví dụ khi logout)
  void clearCache() {
    _cachedTours = null;
    _lastFetch = null;
  }
}
