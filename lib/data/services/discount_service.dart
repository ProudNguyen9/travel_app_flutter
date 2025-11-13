import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/discount.dart';

class DiscountService {
  final SupabaseClient _client;
  DiscountService(this._client);

  String _d(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  /// Lấy các discount hợp lệ cho tour
  Future<List<Discount>> fetchValidDiscounts({
    required int tourId,
  }) async {
    final today = DateTime.now();
    final dateStr = _d(today);

    final rows = await _client
        .from('discounts')
        .select()
        .eq('tour_id', tourId)
        .eq('is_active', true)
        .eq('hidden', false)
        // usage_limit null (unlimited) hoặc != 0
        .or('usage_limit.is.null,usage_limit.neq.0')
        // start_date <= today và (end_date >= today OR end_date IS NULL)
        .lte('start_date', dateStr)
        .or('end_date.gte.$dateStr,end_date.is.null')
        .order('start_date', ascending: true);

    return rows.map((e) => Discount.fromJson(e)).toList();
  }

  /// Kiểm tra mã (chỉ cần start_date >= today)
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
        .gte('start_date', dateStr)
        .maybeSingle();

    if (row == null) return null;
    return Discount.fromJson(row);
  }
}
