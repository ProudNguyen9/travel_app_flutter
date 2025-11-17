import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travel_app/data/services/tour_service.dart';
import '../models/booking.dart';

class BookingService {
  final SupabaseClient _client;

  BookingService([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  final String _table = 'bookings';

  /// ======================================
  /// 🟢 Tạo booking mới và trả về booking_id
  /// ======================================
  Future<int?> createBooking(Booking booking) async {
    try {
      final jsonData = booking.toJson();
      jsonData.remove('booking_id'); // để DB tự tăng

      // Nếu discount_id = 0 → set null
      if (jsonData['discount_id'] == 0) {
        jsonData['discount_id'] = null;
      }

      final data = await _client
          .from(_table)
          .insert(jsonData)
          .select('booking_id')
          .single();

      return data['booking_id'] as int?;
    } catch (e) {
      print('❌ Error creating booking: $e');
      return null;
    }
  }

  /// ======================================
  /// 🟡 Update trạng thái booking
  /// ======================================
  Future<bool> updateBookingStatus(int bookingId, String newStatus) async {
    try {
      await _client
          .from(_table)
          .update({
            'status': newStatus,
            'updated_at': DateTime.now().toIso8601String()
          })
          .eq('booking_id', bookingId);

      return true;
    } catch (e) {
      print("❌ Update Booking Status Error: $e");
      return false;
    }
  }

  /// ====================================================
  /// 🟢 Lấy danh sách booking đã thanh toán + thông tin tour
  /// ====================================================
  Future<List<Map<String, dynamic>>> getPaidBookingsWithTour(int userId) async {
    try {
      final rows = await _client
          .from(_table)
          .select()
          .eq('user_id', userId)
          .eq('status', 'DA_THANH_TOAN');

      if (rows.isEmpty) return [];

      List<Map<String, dynamic>> result = [];

      for (final row in rows) {
        final int tourId = row['tour_id'];
        final DateTime startDate = DateTime.parse(row['start_date']);
        final DateTime endDate = DateTime.parse(row['end_date']);

        final tour = await TourService.instance.getTourFullById(tourId);

        if (tour != null) {
          result.add({
            "startDate": startDate,
            "endDate": endDate,
            "tour": tour,
          });
        }
      }

      return result;
    } catch (e) {
      print("❌ Lỗi getPaidBookingsWithTour: $e");
      return [];
    }
  }

  /// ======================================
  /// 🟢 Lấy booking đầy đủ theo booking_id
  /// ======================================
  Future<Booking?> getBookingById(int bookingId) async {
    try {
      final res = await _client
          .from(_table)
          .select()
          .eq('booking_id', bookingId)
          .maybeSingle();

      if (res == null) return null;

      return Booking.fromJson(res);
    } catch (e) {
      print("❌ Lỗi getBookingById: $e");
      return null;
    }
  }
}
