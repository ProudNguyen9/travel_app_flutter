import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/discount.dart';

class DiscountService {
  final SupabaseClient _client;
  DiscountService(this._client);

  String _d(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  /// ✅ Lấy danh sách mã hợp lệ theo tour + ngày đi + số người (nếu có)
  Future<List<Discount>> fetchValidDiscounts({
    required int tourId,
    required DateTime atDate,
    int? people,
  }) async {
    final dateStr = _d(atDate);

    // Gọi select() TRƯỚC để tạo PostgrestFilterBuilder
    var query = _client
        .from('discounts')
        .select()
        .eq('tour_id', tourId)
        .eq('is_active', true)
        .lte('start_date', dateStr)
        .gte('end_date', dateStr);

    // ✅ Nếu có truyền số người -> lọc theo số người hoặc null
    if (people != null) {
      query = query.or('people.eq.$people,people.is.null');
      // 🧠 tương đương SQL: WHERE people = $people OR people IS NULL
    }

    // ✅ Thứ tự: lọc xong rồi mới order
    final rows = await query.order('value', ascending: false);

    if (rows is! List) return [];
    return rows.map((e) => Discount.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// ✅ Kiểm tra 1 mã cụ thể
  Future<Discount?> validateCode({
    required int tourId,
    required String code,
    required DateTime atDate,
  }) async {
    final dateStr = _d(atDate);
    final row = await _client
        .from('discounts')
        .select()
        .eq('tour_id', tourId)
        .eq('code', code)
        .eq('is_active', true)
        .lte('start_date', dateStr)
        .gte('end_date', dateStr)
        .maybeSingle();

    if (row == null) return null;
    return Discount.fromJson(row);
  }
}
