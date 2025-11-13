import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key, required this.phoneNumber});
  final String phoneNumber;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController otpController = TextEditingController();
  bool isVerifying = false;
  bool canResend = false;
  int resendCountdown = 90;

  Future<void> verifyOtp() async {
    setState(() => isVerifying = true);
    final supabase = Supabase.instance.client;
    final otpCode = otpController.text.trim();

    try {
      final res = await supabase.auth.verifyOTP(
        phone: widget.phoneNumber,
        token: otpCode,
        type: OtpType.sms,
      );

      if (res.session != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Xác thực OTP thành công!")),
        );
        Navigator.pop(context, true); // trả về true khi xác thực thành công
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Mã OTP không hợp lệ")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Lỗi xác thực OTP: $e")),
      );
    } finally {
      setState(() => isVerifying = false);
    }
  }

  Future<void> resendOtp() async {
    setState(() {
      canResend = false;
      resendCountdown = 90;
    });

    try {
      await Supabase.instance.client.auth
          .signInWithOtp(phone: widget.phoneNumber);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🔁 Đã gửi lại mã OTP")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Lỗi gửi lại OTP: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String maskedPhone = widget.phoneNumber.replaceRange(5, 8, "***");

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.4,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context, false), // quay lại màn trước
        ),
        title: Text(
          "Xác thực OTP",
          style: GoogleFonts.lato(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                "Vui lòng kiểm tra tin nhắn SMS gửi đến số $maskedPhone",
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 40),

              // 🔢 OTP input
              PinCodeTextField(
                appContext: context,
                controller: otpController,
                length: 6,
                keyboardType: TextInputType.number,
                animationType: AnimationType.fade,
                enablePinAutofill: false,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(12),
                  fieldHeight: 56,
                  fieldWidth: 48,
                  activeFillColor: const Color(0xFFF7F7F9),
                  inactiveFillColor: const Color(0xFFF7F7F9),
                  selectedFillColor: Colors.white,
                  inactiveColor: Colors.grey.shade300,
                  selectedColor: const Color(0xFF24BAEC),
                  activeColor: const Color(0xFF24BAEC),
                ),
                enableActiveFill: true,
                onChanged: (_) {},
              ),
              const SizedBox(height: 30),

              // 🟦 Verify button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: isVerifying ? null : verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF24BAEC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 2,
                  ),
                  child: isVerifying
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.3,
                          ),
                        )
                      : Text(
                          "Xác nhận OTP",
                          style: GoogleFonts.lato(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // 🔁 Countdown hoặc Resend
              canResend
                  ? TextButton(
                      onPressed: resendOtp,
                      child: Text(
                        "Gửi lại mã OTP",
                        style: GoogleFonts.lato(
                          fontSize: 15,
                          color: const Color(0xFF24BAEC),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : Countdown(
                      seconds: resendCountdown,
                      interval: const Duration(seconds: 1),
                      build: (_, double time) {
                        final minutes = (time ~/ 60).toString().padLeft(2, '0');
                        final seconds =
                            (time % 60).toInt().toString().padLeft(2, '0');
                        return Text(
                          "Gửi lại sau $minutes:$seconds",
                          style: GoogleFonts.lato(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        );
                      },
                      onFinished: () {
                        setState(() => canResend = true);
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
