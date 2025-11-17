import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travel_app/authenticaion/auth_provider.dart';
import 'package:travel_app/pages/home_screen.dart';

import '../../widget/widget.dart';
import '../screen.dart';

class ForgotpasswordScreen extends StatefulWidget {
  const ForgotpasswordScreen({super.key});

  @override
  State<ForgotpasswordScreen> createState() => _ForgotpasswordScreenState();
}

class _ForgotpasswordScreenState extends State<ForgotpasswordScreen> {
  final emailCtrl = TextEditingController();
  String? emailError; // ❗ Lỗi email realtime
  bool loading = false;

  final supabase = Supabase.instance.client;

  // VALIDATE EMAIL
  void validateEmail(String value) {
    if (value.isEmpty) {
      setState(() => emailError = "Email không được để trống");
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      setState(() => emailError = "Email không hợp lệ");
    } else {
      setState(() => emailError = null);
    }
  }

  // GỬI EMAIL QUÊN MẬT KHẨU
  Future<void> _SendEmailForgot() async {
    // Check email trước khi gửi
    validateEmail(emailCtrl.text.trim());
    if (emailError != null) return;

    setState(() => loading = true);

    try {
      final auth = context.read<AuthProvider>();
      final msg = await auth.sendForgotPasswordEmail(emailCtrl.text.trim());

      if (msg == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "✅ Đã gửi email đặt lại mật khẩu! Hãy kiểm tra hộp thư của bạn.",
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lỗi: $msg"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Text("Quên mật khẩu",
                    style: GoogleFonts.poppins(
                        fontSize: 24, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    "Hãy nhập địa chỉ email của bạn để đặt lại mật khẩu.",
                    style: GoogleFonts.poppins(
                        fontSize: 16, color: const Color(0xFF7D848D)),
                  ),
                ),
                const SizedBox(height: 40),

                // EMAIL FIELD + VALIDATE
                TextField(
                  controller: emailCtrl,
                  onChanged: validateEmail,
                  decoration: InputDecoration(
                    hintText: "Nhập Email của bạn ....",
                    filled: true,
                    fillColor: const Color(0xFFF7F7F9),
                    errorText: emailError,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: Color(0xFF24BAEC), width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(34),
                            ),
                          ),
                          child: const Text(
                            "Quay lại",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF24BAEC),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // NÚT QUÊN MẬT KHẨU
                    Expanded(
                      flex: 3,
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: loading || emailError != null
                              ? null
                              : _SendEmailForgot,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF24BAEC),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(34),
                            ),
                          ),
                          child: loading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text(
                                  "Quên mật khẩu",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                const Gap(10),

                Image.asset(
                  "assets/images/imgforgot.png",
                  width: 250,
                  height: 300,
                  fit: BoxFit.contain,
                ),

                const Gap(10),

                /// SOCIAL LOGIN (giữ nguyên)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SocialIcon(
                      path: "assets/icons/facebook.svg",
                      ontap: () async {
                        try {
                          await Supabase.instance.client.auth.signInWithOAuth(
                            OAuthProvider.facebook,
                            redirectTo: 'travelapp://login-callback',
                            authScreenLaunchMode:
                                LaunchMode.externalApplication,
                          );

                          final session =
                              Supabase.instance.client.auth.currentSession;

                          if (session != null) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>  const SimpleBottomScaffold()),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text("Lỗi đăng nhập Facebook: $e")),
                          );
                        }
                      },
                    ),
                    const SizedBox(width: 10),
                    SocialIcon(
                        path: "assets/icons/google.svg",
                        ontap: () async {
                          await context.read<AuthProvider>().googleSignIn();

                          final session =
                              Supabase.instance.client.auth.currentSession;
                          if (session != null) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const HomeScreen()));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Đăng nhập thất bại')),
                            );
                          }
                        }),
                    const SizedBox(width: 10),
                    SocialIcon(
                      path: "assets/icons/X.svg",
                      ontap: () async {
                        try {
                          await Supabase.instance.client.auth.signInWithOAuth(
                            OAuthProvider.twitter,
                            redirectTo: 'travelapp://login-callback',
                            authScreenLaunchMode:
                                LaunchMode.externalApplication,
                          );

                          final session =
                              Supabase.instance.client.auth.currentSession;

                          if (session != null) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HomeScreen()),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text("Lỗi đăng nhập Twitter: $e")),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
