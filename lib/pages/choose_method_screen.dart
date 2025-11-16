import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_zalopay_sdk/flutter_zalopay_sdk.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travel_app/data/models/booking.dart';
import 'package:travel_app/data/models/user_model.dart';
import 'package:travel_app/data/services/booking_service.dart';
import 'package:travel_app/data/services/stripe_service.dart';
import 'package:travel_app/pages/finish_action_noctice.dart';
import 'package:travel_app/utils/extensions.dart';
import 'package:http/http.dart' as http;
import 'package:travel_app/utils/sendmail.dart';

class ChooseMethodPayScreen extends StatefulWidget {
  final Booking booking;
  final UserModel user;
  final String pdfurl;

  const ChooseMethodPayScreen({
    super.key,
    required this.booking,
    required this.user,
    required this.pdfurl,
  });

  @override
  State<ChooseMethodPayScreen> createState() => _ChooseMethodPayScreenState();
}

class _ChooseMethodPayScreenState extends State<ChooseMethodPayScreen> {
  String? selected;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF24BAEC);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Chọn Phương Thức Thanh Toán',
          style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //-----------------------------------------------------------
              // 🔵 NHÓM 1: THANH TOÁN NỘI ĐỊA
              //-----------------------------------------------------------
              Text(
                "Thanh toán trong nước",
                style: GoogleFonts.lato(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF151111),
                ),
              ),
              const Gap(10),
              Text(
                "Hỗ trợ thanh toán qua ví và ngân hàng tại Việt Nam",
                style:
                    GoogleFonts.lato(fontSize: 14, color: Colors.grey.shade600),
              ),
              const Gap(30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPayCard(
                    id: "zalopay",
                    asset: "assets/icons/zalopay.png",
                    selected: selected,
                    primary: primary,
                    cover: true,
                  ),
                  const Gap(40),
                  _buildPayCard(
                    id: "vnpay",
                    asset: "assets/images/vnpay.png",
                    selected: selected,
                    primary: primary,
                  ),
                ],
              ),

              const Gap(50),

              //-----------------------------------------------------------
              // 🟣 NHÓM 2: THANH TOÁN QUỐC TẾ
              //-----------------------------------------------------------
              Text(
                "Thanh toán quốc tế",
                style: GoogleFonts.lato(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF151111),
                ),
              ),
              const Gap(10),
              Text(
                "Hỗ trợ Visa / MasterCard / PayPal / ApplePay / GooglePay",
                style:
                    GoogleFonts.lato(fontSize: 14, color: Colors.grey.shade600),
              ),
              const Gap(50),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPayCard(
                    id: "stripe",
                    asset: "assets/images/stripe.gif",
                    selected: selected,
                    primary: primary,
                    cover: true,
                  ),
                  const Gap(40),
                  _buildPayCard(
                    id: "paypal",
                    asset: "assets/images/paypal.gif",
                    selected: selected,
                    primary: primary,
                    cover: true,
                  ),
                ],
              ),

              const Gap(80),

              //-----------------------------------------------------------
              // BUTTON
              //-----------------------------------------------------------
              Center(
                child: SizedBox(
                  width: context.deviceSize.width * 0.9,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(34),
                      ),
                    ),
                    onPressed: () async {
                      if (selected == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text("Vui lòng chọn phương thức thanh toán"),
                          ),
                        );
                        return;
                      }

                      // ===========================
                      // ZALOPAY
                      // ===========================
                      if (selected == "zalopay") {
                        await _payWithZaloPay(
                          widget.booking.finalAmount,
                          "Thanh toán tour du lịch",
                        );
                        return;
                      }

                      // ===========================
                      // STRIPE
                      // ===========================
                      if (selected == "stripe") {
                        await _payWithStripe(
                          widget.booking.finalAmount,
                          "Thanh toán tour du lịch",
                        );
                        return;
                      }
                    },
                    child: Text(
                      'Tiếp tục',
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------
  // UI COMPONENT
  // ------------------------
  Widget _buildPayCard({
    required String id,
    required String asset,
    required String? selected,
    required Color primary,
    bool cover = false,
  }) {
    return GestureDetector(
      onTap: () => setState(() => this.selected = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(21),
          border: Border.all(
            color: selected == id ? primary : Colors.transparent,
            width: 1.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.asset(
          asset,
          fit: cover ? BoxFit.cover : BoxFit.contain,
        ),
      ),
    );
  }

  // ----------------------
  // ZALOPAY FUNCTION
  // ----------------------
  Future<void> _payWithZaloPay(double amount, String description) async {
    const functionUrl =
        "https://yszeuemcqrydkfbhvdhj.supabase.co/functions/v1/create_zalopay_order";

    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Bạn chưa đăng nhập")),
        );
        return;
      }

      final accessToken = session.accessToken;

      final body = jsonEncode({
        "amount": amount,
        "app_user": "user_${session.user.id}",
        "description": description
      });

      final res = await http.post(
        Uri.parse(functionUrl),
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json",
        },
        body: body,
      );

      if (res.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Lỗi Supabase: ${res.body}")),
        );
        return;
      }

      final data = jsonDecode(res.body);
      final zpToken = data["zp_trans_token"];

      if (zpToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Không nhận được mã giao dịch")),
        );
        return;
      }

      await Future.delayed(const Duration(milliseconds: 150));

      FlutterZaloPayStatus result;

      try {
        result = await FlutterZaloPaySdk.payOrder(zpToken: zpToken);
      } catch (e) {
        debugPrint("⚠️ ZaloPay SDK crash: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("⚠ Lỗi khi mở ZaloPay, thử lại!")),
        );
        return;
      }

      switch (result) {
        case FlutterZaloPayStatus.success:
          await BookingService().updateBookingStatus(
            widget.booking.bookingId!,
            "DA_THANH_TOAN",
          );
          sendBookingSuccessEmail(
            bookingId: widget.booking.bookingId!,
            userEmail: widget.user.email!,
            contractUrl: widget.pdfurl,
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => FinishActionNoticeScreen(
                email: widget.user.email!,
              ),
            ),
          );
          break;

        case FlutterZaloPayStatus.cancelled:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("❌ Bạn đã hủy giao dịch")),
          );
          break;

        case FlutterZaloPayStatus.failed:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("⚠ Thanh toán thất bại")),
          );
          break;

        default:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("⏳ Đang xử lý…")),
          );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❗ Lỗi tổng: $e")),
      );
    }
  }

  // ----------------------
// STRIPE FUNCTION (PaymentSheet)
// ----------------------
  Future<void> _payWithStripe(double amount, String description) async {
    try {
      final session = Supabase.instance.client.auth.currentSession;

      if (session == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Bạn chưa đăng nhập")),
        );
        return;
      }

      // Convert to integer for Stripe
      final int amountInt = amount.toInt();

      // -------------------------
      // 1. Gọi service thanh toán
      // -------------------------
      final success = await StripeService.pay(
        amount: amountInt,
        currency: "vnd",
      );

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("⚠ Thanh toán thất bại")),
        );
        return;
      }

      // -------------------------
      // 2. Cập nhật booking sau khi thanh toán OK
      // -------------------------
      await BookingService().updateBookingStatus(
        widget.booking.bookingId!,
        "DA_THANH_TOAN",
      );

      // -------------------------
      // 3. Gửi email + điều hướng
      // -------------------------
      sendBookingSuccessEmail(
        bookingId: widget.booking.bookingId!,
        userEmail: widget.user.email!,
        contractUrl: widget.pdfurl,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => FinishActionNoticeScreen(
            email: widget.user.email!,
          ),
        ),
      );
    } catch (e) {
      print("Stripe error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❗ Lỗi thanh toán Stripe: $e")),
      );
    }
  }
}
