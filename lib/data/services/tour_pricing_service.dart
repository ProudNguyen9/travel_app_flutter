import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data.dart';

class TourPricingService {
  final SupabaseClient _client;
  TourPricingService(this._client);

  /// RPC: get_tour_activity_prices_min(in_tour_id, in_travel_date)
  Future<List<TourActivityPrice>> getActivityPrices({
    required int tourId,
    required DateTime travelDate,
  }) async {
    final sw = Stopwatch()..start();
    final dateStr = DateFormat('yyyy-MM-dd').format(travelDate);

    // ===== Log input & session =====
    final sess = _client.auth.currentSession;
    final uid = sess?.user.id;
    final email = sess?.user.email;
    print('🧾 [PRICING] call get_tour_activity_prices_min '
        'tourId=$tourId date=$dateStr uid=$uid email=$email');

    try {
      final res = await _client.rpc(
        // ❗ Không prefix 'public.' để tránh 'public.public...'
        'get_tour_activity_prices_min',
        params: {
          'in_tour_id': tourId,
          'in_travel_date': dateStr, // YYYY-MM-DD
        },
      );

      sw.stop();

      if (res == null) {
        print('ℹ️ [PRICING] RPC returned null in ${sw.elapsedMilliseconds}ms');
        return [];
      }

      if (res is! List) {
        print(
            '⚠️ [PRICING] RPC returned non-list in ${sw.elapsedMilliseconds}ms: $res');
        return [];
      }

      print('✅ [PRICING] rows=${res.length} in ${sw.elapsedMilliseconds}ms');
      for (var i = 0; i < res.length && i < 3; i++) {
        print('   ↳ row[$i]=${res[i]}');
      }
      if (res.isEmpty) {
        print('ℹ️ [PRICING] Empty result. Kiểm tra: '
            'activities, base_pricing(price_type="base"), seasons phủ $dateStr, RLS policy.');
      }

      final list = TourActivityPrice.listFromJson(res);

      // Tổng nhanh để đối chiếu
      final adultSum = list.fold<num>(0, (s, r) => s + (r.adultPrice ?? 0));
      final childSum = list.fold<num>(0, (s, r) => s + (r.childPrice ?? 0));
      final seniorSum = list.fold<num>(0, (s, r) => s + (r.seniorPrice ?? 0));
      print(
          '🧮 [PRICING] sums → adult=$adultSum, child=$childSum, senior=$seniorSum');

      return list;
    } on PostgrestException catch (e, st) {
      sw.stop();
      print('❌ [PRICING][PG] code=${e.code} message=${e.message}'
          '${e.details != null ? ' details=${e.details}' : ''}'
          '${e.hint != null ? ' hint=${e.hint}' : ''} '
          '(${sw.elapsedMilliseconds}ms)');
      // Quyền/RLS thường gặp
      if (e.code == '42501') {
        print(
            '🔐 Gợi ý: GRANT EXECUTE ON FUNCTION public.get_tour_activity_prices_min(bigint, date) '
            'TO anon, authenticated; và cấp SELECT cho activities, tour_locations, base_pricing, seasons, participant_types '
            'HOẶC định nghĩa hàm SECURITY DEFINER + SET search_path.');
      }
      if (e.code == 'PGRST202') {
        print(
            '🔄 Gợi ý: NOTIFY pgrst, \'reload schema\'; hoặc REPLACE function để refresh schema cache.');
      }
      print(st);
      return [];
    } catch (e, st) {
      sw.stop();
      print('❌ [PRICING][ERR] $e (${sw.elapsedMilliseconds}ms)');
      print(st);
      return [];
    }
  }
}
