import 'package:supabase_flutter/supabase_flutter.dart';

class EmailTemplates {
  static String paymentSuccess({
    required int bookingId,
    required String contractUrl,
  }) {
    return """
      <div style="font-family: Arial, sans-serif; padding: 24px; max-width: 600px; margin: auto; background: #ffffff; border-radius: 12px; border: 1px solid #eee;">
        
        <h2 style="color: #0abf4f; margin-bottom: 12px;">
          ✅ THANH TOÁN THÀNH CÔNG!
        </h2>

        <p style="font-size: 15px; color: #444;">
          Cảm ơn bạn đã thanh toán cho booking tại <b>DiDauNow</b>. Hợp đồng tham gia tour đã sẵn sàng.
        </p>

        <div style="
          margin: 20px 0;
          padding: 16px;
          background: #f3fff6;
          border-left: 4px solid #0abf4f;
          border-radius: 8px;
        ">
          <p style="margin: 0; color: #333; font-size: 16px;">
            Mã booking của bạn:
            <span style="font-weight: bold; color: #0abf4f;">#$bookingId</span>
          </p>
        </div>

        <p style="font-size: 15px; color: #444;">📄 Xem hợp đồng:</p>
        
        <a href="$contractUrl"
           style="
             display: inline-block;
             padding: 12px 18px;
             background: #0abf4f;
             color: white;
             text-decoration: none;
             border-radius: 8px;
             font-weight: bold;
             margin: 10px 0 20px 0;
           ">
          Xem hợp đồng
        </a>

        <p style="font-size: 14px; color: #666; margin-top: 24px;">
          Nếu bạn cần hỗ trợ thêm, bạn có thể phản hồi lại email này để được hỗ trợ nhanh nhất.
        </p>

        <p style="margin-top: 28px; color: #444;">
          Trân trọng,<br>
          <b>DiDauNow</b>
        </p>
      </div>
    """;
  }

  // ============================================================
  // 🔥 EMAIL HỦY BOOKING
  // ============================================================
  static String cancelBooking({
    required int bookingId,
    required String tourName,
    required String reason,
    required bool refundPending,
  }) {
    return """
      <div style="font-family: Arial, sans-serif; padding: 24px; max-width: 600px; margin: auto; background: #ffffff; border-radius: 12px; border: 1px solid #eee;">
        
        <h2 style="color: #d9534f; margin-bottom: 12px;">
          ❌ BOOKING ĐÃ ĐƯỢC HỦY
        </h2>

        <p style="font-size: 15px; color: #444;">
          Chúng tôi rất tiếc khi nhận được yêu cầu hủy booking của bạn tại <b>DiDauNow</b>.
        </p>

        <div style="
          margin: 20px 0;
          padding: 16px;
          background: #fff5f5;
          border-left: 4px solid #d9534f;
          border-radius: 8px;
        ">
          <p style="margin: 0; color: #333; font-size: 16px;">
            Mã booking:
            <span style="font-weight: bold; color: #d9534f;">#$bookingId</span>
          </p>
          <p style="margin: 6px 0 0 0; color: #555; font-size: 15px;">
            Tên tour: <b>$tourName</b>
          </p>
        </div>

        <p style="font-size: 15px; color: #444;">
          <b>Lý do hủy:</b> $reason
        </p>

        ${refundPending ? """
          <div style="
            margin: 20px 0;
            padding: 14px;
            background: #fffbea;
            border-left: 4px solid #f0ad4e;
            border-radius: 8px;
          ">
            <p style="margin: 0; color: #8a6d3b; font-size: 15px;">
              Booking đã được hủy và đang chờ xử lý hoàn tiền.  
              Chúng tôi sẽ gửi thông báo tiếp theo khi quá trình hoàn tiền hoàn tất.
            </p>
          </div>
        """ : """
          <div style="
            margin: 20px 0;
            padding: 14px;
            background: #eef5ff;
            border-left: 4px solid #337ab7;
            border-radius: 8px;
          ">
            <p style="margin: 0; color: #2e6da4; font-size: 15px;">
              Booking đã được hủy thành công.
            </p>
          </div>
        """}

        <p style="font-size: 14px; color: #666; margin-top: 24px;">
          Nếu bạn không thực hiện yêu cầu này hoặc cần hỗ trợ, vui lòng phản hồi email này để được hỗ trợ nhanh nhất.
        </p>

        <p style="margin-top: 28px; color: #444;">
          Trân trọng,<br>
          <b>DiDauNow</b>
        </p>
      </div>
    """;
  }
}

Future<bool> sendBookingSuccessEmail({
  required int bookingId,
  required String userEmail,
  required String contractUrl,
}) async {
  final supabase = Supabase.instance.client;

  final html = EmailTemplates.paymentSuccess(
    bookingId: bookingId,
    contractUrl: contractUrl,
  );

  try {
    final res = await supabase.functions.invoke(
      'send_mail',
      body: {
        "to": userEmail,
        "subject": "✅ Thanh toán thành công – Hợp đồng của bạn",
        "message": html,
      },
    );

    return res.data["success"] == true;
  } catch (e) {
    print("❌ Send email failed: $e");
    return false;
  }
}

Future<bool> sendBookingCancelEmail({
  required int bookingId,
  required String userEmail,
  required String tourName,
  required String reason,
  required bool refundPending, // true = đang chờ hoàn tiền
}) async {
  final supabase = Supabase.instance.client;

  final html = EmailTemplates.cancelBooking(
    bookingId: bookingId,
    tourName: tourName,
    reason: reason,
    refundPending: refundPending,
  );

  try {
    final res = await supabase.functions.invoke(
      'send_mail',
      body: {
        "to": userEmail,
        "subject": refundPending
            ? "⏳ Booking đã hủy – Đang chờ hoàn tiền"
            : "❌ Booking đã được hủy",
        "message": html,
      },
    );

    return res.data["success"] == true;
  } catch (e) {
    print("❌ Send cancel email failed: $e");
    return false;
  }
}
