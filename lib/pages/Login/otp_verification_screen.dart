import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:timer_count_down/timer_count_down.dart';

class OtpSmsVerificationScreen extends StatelessWidget {
  const OtpSmsVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Giả sử số điện thoại của user
    String phoneNumber = "+84971231234";

    // Ẩn số: chỉ hiện +84 97***1234
    String maskedPhone = phoneNumber.replaceRange(5, 8, "***");

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 80),

              // Title
              const Text(
                "OTP Verification",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle (SMS, ẩn số)
              Text(
                "Please check your SMS sent to $maskedPhone\nto see the verification code",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54, fontSize: 14),
              ),

              const SizedBox(height: 32),

              // OTP Input (4 số)
              PinCodeTextField(
                appContext: context,
                length: 4,
                keyboardType: TextInputType.number,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(12),
                  fieldHeight: 56,
                  fieldWidth: 64,
                  activeFillColor: const Color(0xFFF7F7F9),
                  inactiveFillColor: const Color(0xFFF7F7F9),
                  selectedFillColor: Colors.white,
                  inactiveColor: Colors.grey.shade300,
                  selectedColor: Colors.lightBlue,
                  activeColor: Colors.lightBlue,
                ),
                enableActiveFill: true,
                onChanged: (value) {
                  // xử lý khi nhập code
                },
              ),

              const SizedBox(height: 32),

              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: () {
                    // TODO: Xử lý xác thực OTP
                  },
                  child: const Text(
                    "Verify",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Resend Code
              // Resend Code
              Countdown(
                seconds: 90, // 1:30 = 90 giây
                interval: const Duration(seconds: 1),
                build: (_, double time) {
                  final minutes = (time ~/ 60).toString().padLeft(2, '0');
                  final seconds =
                      (time % 60).toInt().toString().padLeft(2, '0');
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Resend code in ",
                        style: TextStyle(color: Colors.black54),
                      ),
                      Text(
                        "$minutes:$seconds",
                        style: const TextStyle(color: Colors.black),
                      ),
                    ],
                  );
                },
                onFinished: () {
                  // đó dùng provider sau 
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
