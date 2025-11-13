import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/discount.dart';

class DiscountService {
  final SupabaseClient _client;
  DiscountService(this._client);

  String _d(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  /// 👉 Lấy các mã:
  /// - tour đúng
  /// - active
  /// - start_date >= today (TỪ HÔM NAY TRỞ ĐI)
  Future<List<Discount>> fetchValidDiscounts({
    required int tourId,
  }) async {
    final today = DateTime.now();

    final rows = await _client
        .from('discounts')
        .select()
        // ✅ trùng tour id
        .eq('tour_id', tourId)
        // ✅ đang active
        .eq('is_active', true)
        // ✅ không bị ẩn
        .eq('hidden', false)
        // ✅ còn lượt sử dụng
        .neq('usage_limit', 0)
        // ✅ start_date <= today và (end_date >= today OR end_date IS NULL)
        .lte('start_date', today.toIso8601String())
        .or('end_date.gte.${today.toIso8601String()},end_date.is.null')
        // ✅ sắp xếp theo start_date
        .order('start_date', ascending: true);
    return rows.map((e) => Discount.fromJson(e)).toList();
  }

  /// 👉 Kiểm tra mã (chỉ cần start_date >= today)
  Future<Discount?> validateCode({
    required int tourId,
    required String code,
  }) async {
    final today = DateTime.now();
    final dateStr = _d(today);

    final row = await _client
        .from('discounts')
        .select()
        .eq('tour_id', tourId)
        .eq('code', code)
        .eq('is_active', true)
        .gte('start_date', dateStr) // 👈 mã từ hôm nay trở đi mới hợp lệ
        .maybeSingle();

    if (row == null) return null;
    return Discount.fromJson(row);
  }
}
