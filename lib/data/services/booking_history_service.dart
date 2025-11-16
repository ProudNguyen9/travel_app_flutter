import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/booking_history_item.dart';

class BookingHistoryService {
  final SupabaseClient _client = Supabase.instance.client;

  /// status ở đây là status UI: 'upcoming' | 'completed' | 'canceled'
  Future<List<BookingHistoryItem>> getMyBookingsByStatus({
    required String status,
  }) async {
    final authUser = _client.auth.currentUser;

    if (authUser == null) {
      print('[BookingHistory] ❌ auth.currentUser = null (chưa đăng nhập?)');
      return [];
    }

    final authId = authUser.id; // uuid khớp users.auth_id
    print('[BookingHistory] 🔐 current auth_id = $authId');
    print('[BookingHistory] 🔍 UI status cần load = $status');

    try {
      // 1️⃣ Map auth_id -> user_id
      final userRow = await _client
          .from('users')
          .select('user_id')
          .eq('auth_id', authId)
          .maybeSingle();

      if (userRow == null) {
        print(
            '[BookingHistory] ❌ Không tìm thấy user trong bảng users với auth_id = $authId');
        return [];
      }

      final userId = (userRow['user_id'] as num).toInt();
      print('[BookingHistory] ✅ user_id = $userId');

      // 2️⃣ Lấy tất cả bookings của user này (kèm tours, tour_locations, locations, activities)
      final data = await _client.from('bookings').select(r'''
            booking_id,
            start_date,
            end_date,
            adult_count,
            child_count,
            elderly_count,
            final_amount,
            status,
            created_at,
            tours (
              tour_id,
              name,
              image_url,
              tour_locations (
                locations ( name ),
                activities ( start_time )
              )
            )
          ''').eq('user_id', userId).order('start_date', ascending: false);

      final allItems = data
          .map(
            (row) => BookingHistoryItem.fromJson(row),
          )
          .toList();

      print(
          '[BookingHistory] 📦 Tổng bookings của user $userId = ${allItems.length}');

      final now = DateTime.now();

      bool isFuture(BookingHistoryItem b) {
        // ưu tiên start_date, fallback end_date
        final ref = b.startDate ?? b.endDate;
        if (ref == null) return false;
        return !ref.isBefore(now);
      }

      bool isPast(BookingHistoryItem b) {
        // ưu tiên end_date, fallback start_date
        final ref = b.endDate ?? b.startDate;
        if (ref == null) return false;
        return ref.isBefore(now);
      }

      List<BookingHistoryItem> filtered;

      switch (status) {
        case 'upcoming':
          // Sắp tới: ngày còn ở tương lai + trạng thái chưa/đã thanh toán
          filtered = allItems.where((b) {
            final s = b.status;
            return isFuture(b) && (s == 'DA_THANH_TOAN');
          }).toList();
          break;

        case 'completed':
          // Hoàn tất: tour đã kết thúc và đã thanh toán
          filtered = allItems.where((b) {
            final s = b.status;
            return isPast(b) && s == 'DA_THANH_TOAN';
          }).toList();
          break;

        case 'canceled':
          // Đã hủy: chuẩn bị sẵn
          filtered = allItems.where((b) {
            final s = b.status;
            return s == 'DA_HUY' ||
                s == 'HUY' ||
                s == 'DA_HUY_TOUR' ||
                s == 'CHUA_THANH_TOAN';
          }).toList();
          break;

        default:
          filtered = allItems;
      }

      print(
          '[BookingHistory] ✅ UI status=$status -> ${filtered.length} bookings sau khi lọc');
      return filtered;
    } catch (e, st) {
      print('[BookingHistory] 💥 Lỗi khi load bookings: $e');
      print(st);
      return [];
    }
  }
}
