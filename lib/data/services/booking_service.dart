import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/booking.dart';

class BookingService {
  final SupabaseClient _client;

  BookingService([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  final String _table = 'bookings';

  /// Tạo booking mới
  Future<bool> createBooking(Booking booking) async {
    try {
      // Chuyển booking thành JSON nhưng bỏ bookingId để DB tự tăng
      final jsonData = booking.toJson();
      jsonData.remove('booking_id'); // bỏ bookingId nếu có

      // Nếu discount_id là 0, set null
      if (jsonData['discount_id'] == 0) {
        jsonData['discount_id'] = null;
      }

      final data =
          await _client.from(_table).insert(jsonData).select().maybeSingle();

      // Nếu có dữ liệu trả về => thành công
      return data != null;
    } catch (e) {
      print('Error creating booking: $e');
      return false;
    }
  }
}
