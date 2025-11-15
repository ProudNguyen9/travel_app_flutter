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
