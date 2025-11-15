import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_zalopay_sdk/flutter_zalopay_sdk.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travel_app/data/models/booking.dart';
import 'package:travel_app/data/models/user_model.dart';
import 'package:travel_app/data/services/booking_service.dart';
import 'package:travel_app/pages/finish_action_noctice.dart';
import 'package:travel_app/utils/extensions.dart';
import 'package:http/http.dart' as http;
import 'package:travel_app/utils/sendmail.dart';

class ChooseMethodPayScreen extends StatefulWidget {
  final Booking booking;
  final UserModel user;
  final String pdfurl;

  const ChooseMethodPayScreen(
      {super.key,
      required this.booking,
      required this.user,
      required this.pdfurl});

  @override
  State<ChooseMethodPayScreen> createState() => _ChooseMethodPayScreenState();
}

class _ChooseMethodPayScreenState extends State<ChooseMethodPayScreen> {
  String? selected;

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF9F9F9),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: GoogleFonts.lato(color: Colors.grey.shade500),
    );
  }

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
        title: Text('Chọn Phương Thức Thanh Toán',
            style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Payment Method
              Text(
                "Chọn phương loại thanh toán online",
                style: GoogleFonts.lato(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF151111),
                ),
              ),
              const Gap(15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ==== zalopay ====
                  GestureDetector(
                    onTap: () {
                      setState(() => selected = "zalopay");
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(21),
                        border: Border.all(
                          color: selected == "zalopay"
                              ? primary
                              : Colors.transparent,
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(21),
                        child: Image.asset(
                          'assets/icons/zalopay.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  const Gap(20),

                  // ==== VNPAY ====
                  GestureDetector(
                    onTap: () {
                      setState(() => selected = "vnpay");
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(21),
                        border: Border.all(
                          color: selected == "vnpay"
                              ? primary
                              : Colors.transparent,
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
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Image.asset(
                          'assets/images/vnpay.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const Gap(25),

              // 🔹 Select Card
              Text(
                "Chọn loại thẻ",
                style: GoogleFonts.lato(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF151111),
                ),
              ),
              const Gap(15),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    for (var icon in [
                      'visa.png',
                      'paypal.png',
                      'mastercard.png',
                      'applepay.png'
                    ])
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/icons/$icon',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const Gap(30),

              // 🔹 Card Info
              TextField(
                decoration: inputDecoration("Nguyen Huu Hao"),
              ),
              const Gap(15),
              TextField(
                decoration: inputDecoration("9990 3456 2104 8999"),
                keyboardType: TextInputType.number,
              ),
              const Gap(15),
              TextField(
                decoration: inputDecoration("03/28"),
                keyboardType: TextInputType.datetime,
              ),
              const Gap(15),
              TextField(
                decoration: inputDecoration("CVV"),
                obscureText: true,
                keyboardType: TextInputType.number,
              ),

              const Gap(30),

              // 🔹 Continue button
              Center(
                child: SizedBox(
                  width: context.deviceSize.width * 0.9,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF24BAEC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(34),
                      ),
                      elevation: 3,
                    ),
                    onPressed: () async {
                      if (selected == "zalopay") {
                        await _payWithZaloPay(widget.booking.finalAmount,
                            "Thanh toán tour du lịch");
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text("Vui lòng chọn phương thức thanh toán")),
                        );
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

      // =========================
      //    CHẶN LỖI TOKEN NULL
      // =========================
      if (zpToken == null || zpToken.toString().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Không nhận được mã giao dịch")),
        );
        return;
      }

      // =========================
      // tránh freeze → crash
      // =========================
      await Future.delayed(const Duration(milliseconds: 150));

      FlutterZaloPayStatus result;

      // =========================
      //    BỌC SDK ZALOPAY (FIX CRASH)
      // =========================
      try {
        result = await FlutterZaloPaySdk.payOrder(zpToken: zpToken);
      } catch (e) {
        debugPrint("⚠️ ZaloPay SDK crash: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("⚠ Lỗi khi mở ZaloPay, thử lại!")),
        );
        return;
      }

      // =========================
      //       XỬ LÝ KẾT QUẢ
      // =========================
      switch (result) {
        case FlutterZaloPayStatus.success:
          // Cập nhật booking
          await BookingService().updateBookingStatus(
            widget.booking.bookingId!,
            "DA_THANH_TOAN",
          );
          sendBookingSuccessEmail(
              bookingId: widget.booking.bookingId!,
              userEmail: widget.user.email!,
              contractUrl: widget.pdfurl);
          // Chuyển sang màn thành công
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
}
