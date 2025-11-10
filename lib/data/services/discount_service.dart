import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/discount.dart';

class DiscountService {
  final SupabaseClient _client;
  DiscountService(this._client);

  String _d(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  /// Lấy danh sách mã hợp lệ theo tour + ngày đi
  Future<List<Discount>> fetchValidDiscounts({
    required int tourId,
    required DateTime atDate,
  }) async {
    final dateStr = _d(atDate);
    final rows = await _client
        .from('discounts')
        .select()
        .eq('tour_id', tourId)
        .eq('is_active', true)
        .lte('start_date', dateStr)
        .gte('end_date', dateStr)
        .order('value', ascending: false);

    if (rows is! List) return [];
    return rows.map((e) => Discount.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Kiểm tra 1 mã cụ thể
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
